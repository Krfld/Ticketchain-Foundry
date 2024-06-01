// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

// forge script script/Ticketchain.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv

contract TicketchainScript is Script {
    Event private _event;

    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address publicKey = vm.addr(privateKey);

    function setUp() public {
        console.log("publicKey", publicKey);

        vm.startBroadcast(privateKey);
    }

    function run() public {
        Ticketchain ticketchain = new Ticketchain();
        // console.log("ticketchain", address(ticketchain));

        ticketchain.addOrganizer(publicKey);

        address eventAddress = ticketchain.registerEvent(
            Structs.EventConfig(1735689600, 1767225600, 1759273200, Structs.Percentage(50, 0)),
            Structs.NFTConfig("Event 1", "E1", "https://baseURI.com/")
        );
        // console.log("eventAddress", eventAddress);

        _event = Event(eventAddress);

        _event.addPackage(Structs.Package("Package 1", "Package 1 description", 100, 100, false));
        _event.addPackage(Structs.Package("Package 2", "Package 2 description", 200, 200, true));
        _event.addPackage(Structs.Package("Package 3", "Package 3 description", 300, 300, false));

        vm.stopBroadcast();
    }
}
