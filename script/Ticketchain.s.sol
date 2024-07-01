// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

// source .env && forge script script/Ticketchain.s.sol --rpc-url $RPC_URL --verify -vvvv --broadcast

contract TicketchainScript is Script {
    Ticketchain private _ticketchain;

    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address publicKey = vm.addr(privateKey);

    function setUp() public {
        console.log("publicKey", publicKey);

        vm.startBroadcast(privateKey);
    }

    function run() public {
        _ticketchain = new Ticketchain();
        console.log("ticketchain", address(_ticketchain));

        _ticketchain.addOrganizer(publicKey);

        _deployEvent1();
        _deployEvent2();
        _deployEvent3();

        vm.stopBroadcast();
    }

    function _deployEvent1() private returns (address) {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "<Event 1>",
                "<Event 1 description>",
                "<Event 1 location>",
                1733011200,
                // 1704067200,
                1735603200,
                1727737200,
                Structs.Percentage(50, 0)
            ),
            Structs.NFTConfig("<Event 1 NFT>", "<E1>", "<https://baseURI_1.com/>")
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(
            Structs.PackageConfig("<Event 1 package 1>", "<Event 1 package 1 description>", 0.01 ether, 100, false)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 1 package 2>", "<Event 1 package 2 description>", 0.05 ether, 200, true)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 1 package 3>", "<Event 1 package 3 description>", 0.1 ether, 300, false)
        );

        address[] memory validator = new address[](1);
        validator[0] = address(0xF1c604490a371258f9EA577D787d005B632A5885);

        _event.addValidators(validator);

        return eventAddress;
    }

    function _deployEvent2() private returns (address) {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "<Event 2>",
                "<Event 2 description>",
                "<Event 2 location>",
                1717196400,
                // 1704067200,
                1719702000,
                1711926000,
                Structs.Percentage(0, 0)
            ),
            Structs.NFTConfig("<Event 2 NFT>", "<E2>", "<https://baseURI_2.com/>")
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(
            Structs.PackageConfig("<Event 2 package 1>", "<Event 2 package 1 description>", 0.01 ether, 100, true)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 2 package 2>", "<Event 2 package 2 description>", 0.1 ether, 200, false)
        );

        address[] memory validator = new address[](1);
        validator[0] = address(0xF1c604490a371258f9EA577D787d005B632A5885);

        _event.addValidators(validator);

        return eventAddress;
    }

    function _deployEvent3() private returns (address) {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "<Event 3>",
                "<Event 3 description>",
                "<Event 3 location>",
                1722466800,
                // 1704067200,
                1719788400,
                1711926000,
                Structs.Percentage(100, 0)
            ),
            Structs.NFTConfig("<Event 3 NFT>", "<E3>", "<https://baseURI_3.com/>")
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(
            Structs.PackageConfig("<Event 3 package 1>", "<Event 3 package 1 description>", 0.01 ether, 100, true)
        );

        address[] memory validator = new address[](1);
        validator[0] = address(0xF1c604490a371258f9EA577D787d005B632A5885);

        _event.addValidators(validator);

        return eventAddress;
    }

    // function _buyTickets(address event1, address event2) private {
    //     Event _event1 = Event(event1);
    //     Event _event2 = Event(event2);

    //     uint256[] memory tickets1 = new uint256[](5);
    //     tickets1[0] = 0;
    //     tickets1[1] = 1;
    //     tickets1[2] = 100;
    //     tickets1[3] = 300;
    //     tickets1[4] = 599;

    //     uint256[] memory tickets2 = new uint256[](3);
    //     tickets2[0] = 0;
    //     tickets2[1] = 150;
    //     tickets2[2] = 299;

    //     // _event1.buyTickets{value: 1000}(publicKey, tickets1);
    //     // _event2.buyTickets{value: 500}(publicKey, tickets2);
    // }
}
