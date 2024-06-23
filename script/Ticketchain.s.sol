// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

// forge script script/Ticketchain.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv

contract TicketchainScript is Script {
    Ticketchain private _ticketchain;

    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address publicKey = vm.addr(privateKey);

    function setUp() public {
        console.log("publicKey", publicKey);

        vm.startBroadcast(privateKey);

        _ticketchain = new Ticketchain();
    }

    function _deployEvent1() private {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "Event 1",
                "Event 1 description",
                "Event 1 location",
                1733011200,
                // 1704067200,
                1735603200,
                1727737200,
                Structs.Percentage(50, 0)
            ),
            Structs.NFTConfig("Event 1 NFT", "E1", "https://baseURI.com/")
        );
        // console.log("eventAddress", eventAddress);

        Event _event = Event(eventAddress);

        _event.addPackage(Structs.Package("Package 1", "Package 1 description", 100, 100, false));
        _event.addPackage(Structs.Package("Package 2", "Package 2 description", 200, 200, true));
        _event.addPackage(Structs.Package("Package 3", "Package 3 description", 300, 300, false));
    }

    function _deployEvent2() private {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "Event 2",
                "Event 2 description",
                "Event 2 location",
                1717196400,
                // 1704067200,
                1719702000,
                1711926000,
                Structs.Percentage(0, 0)
            ),
            Structs.NFTConfig("Event 2 NFT", "E2", "https://baseURI.com/")
        );
        // console.log("eventAddress", eventAddress);

        Event _event = Event(eventAddress);

        _event.addPackage(Structs.Package("Package 1", "Package 1 description", 100, 100, false));
        _event.addPackage(Structs.Package("Package 2", "Package 2 description", 200, 200, true));
        _event.addPackage(Structs.Package("Package 3", "Package 3 description", 300, 300, false));
    }

    function run() public {
        // console.log("ticketchain", address(ticketchain));

        _ticketchain.addOrganizer(publicKey);

        _deployEvent1();
        _deployEvent2();

        vm.stopBroadcast();
    }
}
