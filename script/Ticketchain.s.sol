// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

contract TicketchainScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address publicKey = vm.addr(privateKey);
        console.log("publicKey", publicKey);

        vm.startBroadcast(privateKey);

        Ticketchain ticketchain = new Ticketchain();
        ticketchain.addOrganizer(publicKey);
        ticketchain.registerEvent(
            Structs.EventConfig(1735689600, 1767225600, 1759273200, Structs.Percentage(50, 2)),
            Structs.Package("Package1", "P1", 100, 100, false),
            Structs.NFTConfig("Event1", "E1", "https://example.com")
        );

        address eventAddress = ticketchain.getEvents()[0];
        console.log("eventAddress", eventAddress);

        vm.stopBroadcast();
    }
}
