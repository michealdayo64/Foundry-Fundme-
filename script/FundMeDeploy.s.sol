// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// 0x694AA1769357215DE4FAC081bf1f309aDC325306

contract FundMeDeploy is Script {
    function run() external returns (FundMe) {
        HelperConfig newHelper = new HelperConfig();
        address helperAddress = newHelper.networkPriceAddress();
        vm.startBroadcast();
        FundMe fundme = new FundMe(helperAddress);
        vm.stopBroadcast();
        return fundme;
    }
}
