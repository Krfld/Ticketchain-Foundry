// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/structs/EnumerableSet.sol";
import "@openzeppelin/utils/Address.sol";
import "@openzeppelin/utils/Strings.sol";

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Structs.sol";

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Strings for uint256;
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /* types */

    /* variables */

    Structs.TicketchainConfig private _ticketchainConfig;
    Structs.NFTConfig private _nftConfig;
    Structs.EventConfig private _eventConfig;
    Structs.PackageConfig[] private _packages;
    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _validators;

    bool private _eventCanceled;
    bool private _internalTransfer;

    uint256 private _fees;
    mapping(uint256 => EnumerableSet.UintSet) private _packageTicketsBought;
    EnumerableSet.UintSet private _ticketsValidated;

    /* events */

    event Buy(address indexed user, address indexed to, uint256 indexed ticket, uint256 value);
    event Gift(address indexed user, address indexed to, uint256 indexed ticket);
    event Refund(address indexed user, uint256 indexed ticket, uint256 value);
    event ValidateTicket(address indexed validator, uint256 indexed ticket);
    event CancelEvent();

    /* errors */

    error NoTickets();
    error NotTicketchain();
    error NotAdmin();
    error NotValidator(address user);
    error NothingToWithdraw();
    error InvalidInputs();

    error EventNotOnline();
    // error EventOnline();
    error EventNotOffline();
    error EventOffline();
    error NoRefund();
    error EventCanceled();

    error TicketDoesNotExist(uint256 ticket);
    error UserNotTicketOwner(address user, uint256 ticket);
    error TicketValidated(uint256 ticket);

    error WrongValue(uint256 current, uint256 expected);

    /* constructor */

    constructor(
        address owner,
        Structs.Percentage memory feePercentage,
        Structs.EventConfig memory eventConfig,
        // Structs.PackageConfig[] memory packages,
        Structs.NFTConfig memory nftConfig
    ) Ownable(owner) ERC721(nftConfig.name, nftConfig.symbol) {
        _ticketchainConfig = Structs.TicketchainConfig(_msgSender(), feePercentage);
        _setEventConfig(eventConfig);
        // _packages = packages; //! change back
        _nftConfig = nftConfig;
    }

    /* modifiers */

    modifier onlyTicketchain() {
        if (_msgSender() != _ticketchainConfig.ticketchainAddress) {
            revert NotTicketchain();
        }
        _;
    }

    modifier onlyAdmins() {
        if (!_admins.contains(_msgSender()) && _msgSender() != owner()) {
            revert NotAdmin();
        }
        _;
    }

    modifier checkValidator(address validator) {
        if (!_validators.contains(validator)) revert NotValidator(validator);
        _;
    }

    modifier internalTransfer() {
        _internalTransfer = true;
        _;
        _internalTransfer = false;
    }

    /* ticketchain */

    function withdrawFees() external onlyTicketchain {
        if (block.timestamp < _eventConfig.offlineDate) {
            revert EventNotOffline();
        }

        if (_fees == 0) revert NothingToWithdraw();
        uint256 fees = _fees;
        _fees = 0;
        payable(_ticketchainConfig.ticketchainAddress).sendValue(fees);
    }

    /* admins */

    function withdrawProfit() external onlyAdmins {
        if (block.timestamp < _eventConfig.offlineDate) {
            revert EventNotOffline();
        }

        uint256 profit = address(this).balance - _fees;
        if (profit == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(profit);
    }

    // function deployTickets(address to, Structs.PackageConfig[] memory packages) external onlyAdmins {
    //     for (uint256 i; i < packages.length; i++) {
    //         uint256 totalSupply = getTicketsSupply();

    //         for (uint256 j; j < packages[i].supply; j++) {
    //             _safeMint(to, totalSupply + j);
    //         }

    //         _packages.push(packages[i]);
    //     }
    // }

    function cancelEvent() external onlyAdmins {
        _eventCanceled = true;

        emit CancelEvent();
    }

    /* validator */

    function validateTickets(uint256[] memory tickets) external checkValidator(_msgSender()) {
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            _ticketsValidated.add(ticket);

            emit ValidateTicket(_msgSender(), ticket);
        }
    }

    /* user */

    function buyTickets(address to, uint256[] memory tickets) external payable internalTransfer {
        uint256 totalPrice;
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];
            uint256 packageId = _getTicketPackageId(ticket);

            // give ticket to user
            _safeMint(to, ticket);

            _packageTicketsBought[packageId].add(ticket);

            // get ticket price
            uint256 price = _packages[packageId].price;
            totalPrice += price;

            // update fees
            _fees += _getPercentage(price, _ticketchainConfig.feePercentage);

            emit Buy(_msgSender(), to, ticket, price);
        }

        // check if user paid the correct amount
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function giftTickets(address to, uint256[] memory tickets) external internalTransfer {
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // transfer ticket to user
            safeTransferFrom(_msgSender(), to, ticket);

            emit Gift(_msgSender(), to, ticket);
        }
    }

    function refundTickets(uint256[] memory tickets) external internalTransfer {
        if (
            (block.timestamp >= _eventConfig.noRefundDate || _eventConfig.refundPercentage.value == 0)
                && !_eventCanceled
        ) revert NoRefund();

        uint256 totalPrice;
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];
            uint256 packageId = _getTicketPackageId(ticket);

            if (!_eventCanceled) {
                // check if ticket is validated
                _checkTicketValidated(ticket);

                // burn ticket from user
                _update(address(0), ticket, _msgSender());

                _packageTicketsBought[packageId].remove(ticket);
            }

            // calculate refund
            Structs.Percentage memory refundPercentage =
                !_eventCanceled ? _eventConfig.refundPercentage : Structs.Percentage(100, 0);

            uint256 refundPrice = _getPercentage(_packages[packageId].price, refundPercentage);
            totalPrice += refundPrice;

            // update fees
            _fees -= _getPercentage(refundPrice, _ticketchainConfig.feePercentage);

            emit Refund(_msgSender(), ticket, refundPrice);
        }

        // refund user in one transaction
        payable(_msgSender()).sendValue(totalPrice);
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* tickets */

    function getTicketsSupply() external view returns (uint256) {
        uint256 totalSupply;
        for (uint256 i; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
        }
        return totalSupply;
    }

    function getPackageTicketsBought(uint256 packageId) external view returns (uint256[] memory) {
        return _packageTicketsBought[packageId].values();
    }

    // function _getTicketPrice(uint256 ticket) internal view returns (uint256) {
    //     return _packages[_getTicketPackageId(ticket)].price;
    // }

    function _getTicketPackageId(uint256 ticket) internal view returns (uint256) {
        uint256 totalSupply;
        for (uint256 i; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    /* NFTs */

    function tokenURI(uint256 ticket) public view override returns (string memory) {
        uint256 packageId = _getTicketPackageId(ticket);

        string memory ticketPath = !_packages[packageId].individualNfts ? "" : string.concat("/", ticket.toString());

        return string.concat(_baseURI(), packageId.toString(), ticketPath, ".json");
    }

    function _baseURI() internal view override returns (string memory) {
        return _nftConfig.baseURI;
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* ticketchainConfig */

    function getTicketchainConfig() external view returns (Structs.TicketchainConfig memory) {
        return _ticketchainConfig;
    }

    /* eventConfig */

    function _setEventConfig(Structs.EventConfig memory eventConfig) internal {
        if (
            eventConfig
                // eventConfig.onlineDate > eventConfig.noRefundDate ||
                // block.timestamp >= eventConfig.onlineDate ||
                .noRefundDate > eventConfig.offlineDate
        ) revert InvalidInputs();

        _eventConfig = eventConfig;
    }

    function getEventConfig() external view returns (Structs.EventConfig memory) {
        return _eventConfig;
    }

    /* packages */

    // function setPackageConfigs(Structs.PackageConfig[] memory packages) internal {
    //     if (packages.length == 0) revert InvalidInputs();

    //     _packages = packages;
    // }

    function addPackageConfig(Structs.PackageConfig memory package) external onlyAdmins {
        _packages.push(package);
    }

    function getTicketPackageConfig(uint256 ticket) external view returns (Structs.PackageConfig memory) {
        return _packages[_getTicketPackageId(ticket)];
    }

    function getPackageConfigs() external view returns (Structs.PackageConfig[] memory) {
        return _packages;
    }

    /* nftConfig */

    function setNFTConfigBaseURI(string memory baseURI) external onlyAdmins {
        _nftConfig.baseURI = baseURI;
    }

    function getNFTConfig() external view returns (Structs.NFTConfig memory) {
        return _nftConfig;
    }

    /* admins */

    function addAdmins(address[] memory admins) external onlyAdmins {
        for (uint256 i; i < admins.length; i++) {
            _admins.add(admins[i]);
        }
    }

    function removeAdmins(address[] memory admins) external onlyAdmins {
        for (uint256 i; i < admins.length; i++) {
            _admins.remove(admins[i]);
        }
    }

    function getAdmins() external view returns (address[] memory) {
        return _admins.values();
    }

    /* validators */

    function addValidators(address[] memory validators) external onlyAdmins {
        for (uint256 i; i < validators.length; i++) {
            _validators.add(validators[i]);
        }
    }

    function removeValidators(address[] memory validators) external onlyAdmins {
        for (uint256 i; i < validators.length; i++) {
            _validators.remove(validators[i]);
        }
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    /* eventCanceled */

    function isEventCanceled() external view returns (bool) {
        return _eventCanceled;
    }

    /* ticketsValidated */

    function getTicketsValidated() external view returns (uint256[] memory) {
        return _ticketsValidated.values();
    }

    /* internal */

    function _checkTicketOwner(uint256 ticket) internal view {
        if (_msgSender() != ownerOf(ticket)) {
            revert UserNotTicketOwner(_msgSender(), ticket);
        }
    }

    function _checkTicketValidated(uint256 ticket) internal view {
        if (_ticketsValidated.contains(ticket)) revert TicketValidated(ticket);
    }

    function _getPercentage(uint256 value, Structs.Percentage memory percentage) internal pure returns (uint256) {
        return (value * percentage.value) / (100 * 10 ** percentage.decimals);
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* overrides */

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        if (_eventCanceled) revert EventCanceled();

        // // revert if trying to transfer inside of contract when event has not started
        // if (_internalTransfer && block.timestamp < _eventConfig.onlineDate) {
        //     revert EventNotOnline();
        // }

        // revert if trying to transfer outside of contract when event has not ended
        if (!_internalTransfer && block.timestamp < _eventConfig.offlineDate) {
            revert EventNotOffline();
        }

        // revert if trying to transfer inside of contract when event has ended
        if (_internalTransfer && block.timestamp >= _eventConfig.offlineDate) {
            revert EventOffline();
        }

        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
