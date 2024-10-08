// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/Address.sol";
import "@openzeppelin/utils/structs/EnumerableSet.sol";

import "./Event.sol";
import "./Structs.sol";

contract Ticketchain is Ownable(msg.sender) {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;

    /* variables */

    Structs.Percentage private _feePercentage;

    EnumerableSet.AddressSet private _organizers;
    EnumerableSet.AddressSet private _events;

    /* events */

    event EventRegistered(address indexed organizer, address indexed eventAddress);

    /* errors */

    error NotOrganizer();
    error NoEvent();

    /* constructor */

    /* modifiers */

    modifier onlyOrganizers() {
        if (!_organizers.contains(_msgSender())) revert NotOrganizer();
        _;
    }

    /* owner */

    function withdrawFees(address eventAddress) external onlyOwner {
        if (!_events.contains(eventAddress)) revert NoEvent();

        Event(eventAddress).withdrawFees();

        payable(owner()).sendValue(address(this).balance);
    }

    /* organizers */

    function registerEvent(
        Structs.EventConfig memory eventConfig,
        // Structs.Package[] memory packages,
        Structs.NFTConfig memory nftConfig
    ) external onlyOrganizers returns (address) {
        address eventAddress = address(new Event(_msgSender(), _feePercentage, eventConfig, /*packages,*/ nftConfig));
        _events.add(eventAddress);

        emit EventRegistered(_msgSender(), eventAddress);

        return eventAddress;
    }

    /* owner */

    function addOrganizer(address organizer) external onlyOwner {
        _organizers.add(organizer);
    }

    function removeOrganizer(address organizer) external onlyOwner {
        _organizers.remove(organizer);
    }

    function getOrganizers() external view returns (address[] memory) {
        return _organizers.values();
    }

    /* events */

    function removeEvent(address eventAddress) external onlyOwner {
        _events.remove(eventAddress);
    }

    function getEvents() external view returns (address[] memory) {
        return _events.values();
    }

    /* feePercentage */

    function setFeePercentage(Structs.Percentage memory feePercentage) external onlyOwner {
        _feePercentage = feePercentage;
    }

    function getFeePercentage() external view returns (Structs.Percentage memory) {
        return _feePercentage;
    }
}
