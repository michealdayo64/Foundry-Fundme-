// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMeDeploy.s.sol";

contract FundMeTest is Test {
    uint256 number = 0;

    // TO ASSIGN A NEW USER TO BE IN CHARGE CONTRACT
    address USER = makeAddr("user");

    uint256 constant AMOUNTTOSEND = 10e18;
    uint256 constant startBalance = 100e18;

    //uint256 constant GAS_AAMOUNT_SPENT = 1;

    FundMe fundme;

    function setUp() external {
        FundMeDeploy deployFundme = new FundMeDeploy();
        fundme = deployFundme.run();
        vm.deal(USER, startBalance);
    }

    function testMininumUsd() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testGetPriceFeedVersion() public view {
        console.log(fundme.getVersion());
        assertEq(fundme.getVersion(), 4);
    }

    function testOwner() public view {
        console.log(fundme.getOwner());
        console.log(address(this));
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testNotEnoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundAndKeepTrackOfAmount() public {
        vm.prank(USER);
        fundme.fund{value: AMOUNTTOSEND}();
        uint256 amt = fundme.getAmountFunded(USER);
        assertEq(amt, AMOUNTTOSEND);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: AMOUNTTOSEND}();
        _;
    }

    function testOnlyOwnerCanWidthraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }

    function testWithdrawWithSingleOwner() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFunderBalance = address(fundme).balance;

        // Act
        //uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_AAMOUNT_SPENT);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        // Assert
        uint256 endingOwnerbalance = fundme.getOwner().balance;
        uint256 endingFunderBalance = address(fundme).balance;

        assertEq(endingFunderBalance, 0);
        assertEq(
            startingOwnerBalance + startingFunderBalance,
            endingOwnerbalance
        );
    }

    function testWithdrawForMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), AMOUNTTOSEND);
            fundme.fund{value: AMOUNTTOSEND}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFunderBalance = address(fundme).balance;

        // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundme).balance, 0);
        assertEq(
            startingFunderBalance + startingOwnerBalance,
            fundme.getOwner().balance
        );
    }

    function testWithdrawForMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), AMOUNTTOSEND);
            fundme.fund{value: AMOUNTTOSEND}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFunderBalance = address(fundme).balance;

        // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdrawCheaper();
        vm.stopPrank();

        // Assert
        assertEq(address(fundme).balance, 0);
        assertEq(
            startingFunderBalance + startingOwnerBalance,
            fundme.getOwner().balance
        );
    }
}
