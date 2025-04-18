// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public networkPriceAddress;

    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000.00

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            networkPriceAddress = getSepoliaEthPriceFeedAddress();
        } else {
            networkPriceAddress = getOrCreateAnvilEthPriceFeedAddress();
        }
    }

    function getSepoliaEthPriceFeedAddress()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory _priceFeed = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return _priceFeed;
    }

    function getOrCreateAnvilEthPriceFeedAddress()
        public
        returns (NetworkConfig memory)
    {
        if (networkPriceAddress.priceFeed != address(0)) {
            return networkPriceAddress;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory _priceFeed = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return _priceFeed;
    }
}
