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
                "NOS Alive",
                "NOS Alive is one of the biggest music festivals in Portugal. The festival features a mix of rock, indie, and electronic music, with performances from both established and up-and-coming artists.",
                "Passeio Maritimo de Alges, Portugal",
                1717196400, // 1 jun 24
                1730332800, // 31 oct 24
                1733011200, // 1 dec 24
                1735603200, // 31 dec 24
                Structs.Percentage(50, 0)
            ),
            Structs.NFTConfig(
                "NOS Alive NFT", "NOSA", "https://ipfs.io/ipfs/Qmaayxv9D5u4C6AXZLfMh4wC7LKiw2oiKpB36u8yxcasTM/"
            )
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(Structs.PackageConfig("Normal package", "Normal tickets", 0.001 ether, 100, false));
        _event.addPackageConfig(Structs.PackageConfig("VIP package", "VIP tickets", 0.005 ether, 200, false));
        _event.addPackageConfig(Structs.PackageConfig("Premium package", "Premium tickets", 0.01 ether, 300, false));

        address[] memory validator = new address[](1);
        validator[0] = address(0xF1c604490a371258f9EA577D787d005B632A5885);

        _event.addValidators(validator);

        return eventAddress;
    }

    function _deployEvent2() private returns (address) {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "Sumol Summer Fest",
                "This beach festival is all about good vibes, summer fun, and electronic music. It takes place on the Praia da Rocha beach in Algarve, a stunning location known for its golden sands and dramatic cliffs.",
                "Praia da Rocha, Algarve, Portugal",
                1717196400, // 1 jun 24
                1727737200, // 1 oct 24
                1734220800, // 15 dec 24
                1735603200, // 31 dec 24
                Structs.Percentage(0, 0)
            ),
            Structs.NFTConfig(
                "Sumol Summer Fest NFT", "SSF", "https://ipfs.io/ipfs/Qmaayxv9D5u4C6AXZLfMh4wC7LKiw2oiKpB36u8yxcasTM/"
            )
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(Structs.PackageConfig("Normal package", "Normal tickets", 0.001 ether, 100, false));
        _event.addPackageConfig(Structs.PackageConfig("VIP package", "VIP tickets", 0.01 ether, 200, false));

        address[] memory validator = new address[](1);
        validator[0] = address(0xF1c604490a371258f9EA577D787d005B632A5885);

        _event.addValidators(validator);

        return eventAddress;
    }

    function _deployEvent3() private returns (address) {
        address eventAddress = _ticketchain.registerEvent(
            Structs.EventConfig(
                "RFM SOMNII",
                "This massive electronic music festival is a major highlight of the Portuguese summer. The festival features renowned DJs, along with stunning visuals, pyrotechnics, and a vibrant party atmosphere.",
                "Praia da Vieira, Leiria, Portugal",
                1722466800, // 1 aug 24
                1730332800, // 31 oct 24
                1734739200, // 21 dec 24
                1735603200, // 31 dec 24
                Structs.Percentage(100, 0)
            ),
            Structs.NFTConfig(
                "RFM SOMNII NFT", "RFMS", "https://ipfs.io/ipfs/Qmaayxv9D5u4C6AXZLfMh4wC7LKiw2oiKpB36u8yxcasTM/"
            )
        );

        Event _event = Event(eventAddress);

        _event.addPackageConfig(Structs.PackageConfig("Normal package", "Normal tickets", 0.001 ether, 100, false));

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
