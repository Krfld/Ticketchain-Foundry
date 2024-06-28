// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Structs {
    struct Percentage {
        uint256 value;
        uint256 decimals;
    }

    struct TicketchainConfig {
        address ticketchainAddress;
        Percentage feePercentage;
    }

    struct EventConfig {
        string name;
        string description;
        string location;
        uint256 date;
        // uint256 onlineDate;
        uint256 offlineDate;
        uint256 noRefundDate;
        Percentage refundPercentage;
    }

    struct PackageConfig {
        string name;
        string description;
        uint256 price;
        uint256 supply;
        bool individualNfts;
    }

    struct NFTConfig {
        string name;
        string symbol;
        string baseURI;
    }
}
