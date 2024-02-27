// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Ticketchain} from "../src/Ticketchain.sol";
import {Event} from "../src/Event.sol";
import {Structs} from "../src/Structs.sol";

contract TicketchainScript is Script {
    function setUp() public {}

    Structs.Package[] packages;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address publicKey = vm.addr(privateKey);
        console.log("publicKey", publicKey);

        vm.startBroadcast(privateKey);

        Ticketchain ticketchain = new Ticketchain();
        ticketchain.addOrganizer(publicKey);
        ticketchain.registerEvent(Structs.NFTConfig("Event", "EVT", "https://example.com"));
        address eventAddress = ticketchain.getEvents()[0];

        packages.push(Structs.Package("General", "General Admission", 100, 100, false));
        Event(eventAddress).addPackages(packages);

        vm.stopBroadcast();
    }
}
