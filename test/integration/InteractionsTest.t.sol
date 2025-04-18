// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test{

    address USER = makeAddr("user");

    FundMe public fundme;

    uint256 constant AMOUNTTOSEND = 10e18;
    uint256 constant startBalance = 100e18;

    function setUp() external {
        FundMeDeploy deployFundme = new FundMeDeploy();
        fundme = deployFundme.run();
        vm.deal(USER, startBalance);
    }

    function testUserCanFundAndOwnerCanWithdraw() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        assert(address(fundme).balance == 0);
    }
}