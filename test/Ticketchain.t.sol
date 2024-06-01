// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/Ticketchain.sol";
import "../src/Event.sol";
import "../src/Structs.sol";

contract TicketchainTest is Test {
    Ticketchain public ticketchain;

    address me = address(1);

    function setUp() public {
        vm.startPrank(me);
        ticketchain = new Ticketchain();
        ticketchain.addOrganizer(me);
        ticketchain.registerEvent(
            Structs.EventConfig(1735689600, 1767225600, 1759273200, Structs.Percentage(50, 0)),
            Structs.NFTConfig("Event1", "E1", "https://example.com")
        );
    }
}
