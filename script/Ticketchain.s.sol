// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

// forge script script/Ticketchain.s.sol --rpc-url $RPC_URL --verify -vvvv --broadcast

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

        _buyTickets(_deployEvent1(), _deployEvent2());
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
            Structs.PackageConfig("<Event 1 package 1>", "<Event 1 package 1 description>", 100, 100, false)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 1 package 2>", "<Event 1 package 2 description>", 200, 200, true)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 1 package 3>", "<Event 1 package 3 description>", 300, 300, false)
        );

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
            Structs.PackageConfig("<Event 2 package 1>", "<Event 2 package 1 description>", 100, 100, true)
        );
        _event.addPackageConfig(
            Structs.PackageConfig("<Event 2 package 2>", "<Event 2 package 2 description>", 200, 200, false)
        );

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
            Structs.PackageConfig("<Event 3 package 1>", "<Event 3 package 1 description>", 100, 100, true)
        );

        return eventAddress;
    }

    function _buyTickets(address event1, address event2) private {
        Event _event1 = Event(event1);
        Event _event2 = Event(event2);

        uint256[] memory tickets1 = new uint256[](5);
        tickets1[0] = 0;
        tickets1[1] = 1;
        tickets1[2] = 100;
        tickets1[3] = 300;
        tickets1[4] = 599;

        uint256[] memory tickets2 = new uint256[](3);
        tickets2[0] = 0;
        tickets2[1] = 150;
        tickets2[2] = 299;

        _event1.buyTickets{value: 1000}(publicKey, tickets1);
        _event2.buyTickets{value: 500}(publicKey, tickets2);
    }
}
