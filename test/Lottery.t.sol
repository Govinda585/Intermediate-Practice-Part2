// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "../src/Lottery.sol";

contract LotteryTest is Test {
    event EnteredLottery(address indexed user);
    event WinnerSelected(address indexed winner);
    Lottery public lottery;
    address USER;
    address OWNER;
    function setUp() public {
        USER = makeAddr("user");
        OWNER = makeAddr("owner");
        vm.prank(OWNER);
        lottery = new Lottery();
    }

    function testRevertOnInvalidEntryFee() public {
        vm.deal(USER, 10 ether);
        vm.startPrank(USER);
        vm.expectRevert(Lottery.InvalidAmount.selector);
        lottery.entry{value: 6 ether}();
        vm.stopPrank();
    }

    function testRevertOnParticipiantsGreaterThanDefined() public {
        vm.deal(USER, 10 ether);
        vm.deal(address(0x12), 10 ether);
        vm.deal(address(0x123), 10 ether);
        vm.deal(address(0x1234), 10 ether);

        vm.prank(address(0x12));
        lottery.entry{value: 5 ether}();
        vm.prank(address(0x123));
        lottery.entry{value: 5 ether}();
        vm.prank(address(0x1234));
        lottery.entry{value: 5 ether}();
        vm.expectRevert(Lottery.LotteryClosed.selector);
        vm.prank(USER);
        lottery.entry{value: 5 ether}();
    }

    function testRevertOnUserAlreadyEntered() public {
        vm.deal(USER, 10 ether);

        vm.prank(USER);
        lottery.entry{value: 5 ether}();

        vm.expectRevert(Lottery.AlreadyEntered.selector);
        vm.prank(USER);
        lottery.entry{value: 5 ether}();
    }

    function testEntry() public {
        vm.deal(USER, 10 ether);
        vm.prank(USER);
        lottery.entry{value: 5 ether}();
        assertTrue(lottery.isEntered(USER));
        assertEq(lottery.participantsLength(), 1);
        assertEq(lottery.participants(0), USER);
    }

    function testEmitEventOnLotteryEntered() public {
        vm.deal(USER, 10 ether);
        vm.startPrank(USER);
        vm.expectEmit(true, false, false, false, address(lottery));
        emit EnteredLottery(USER);
        lottery.entry{value: 5 ether}();
        vm.stopPrank();
    }
    function testRevertIfNoParticipants() public {
        // OnlyOwner check is separate; first we try empty lottery
        vm.expectRevert(Lottery.NoParticipants.selector);
        vm.prank(OWNER);
        lottery.selectWinner();
    }

    function testRevertIfNotOwner() public {
        // Fund user and enter
        vm.deal(USER, 10 ether);
        vm.prank(USER);
        lottery.entry{value: 5 ether}();

        // USER tries to call selectWinner -> should revert
        vm.expectRevert(Lottery.NotOwner.selector);
        vm.prank(USER);
        lottery.selectWinner();
    }
    function testSelectWinnerEmitsEvent() public {
        // Add 3 participants
        address user1 = USER;
        address user2 = makeAddr("user2");
        address user3 = makeAddr("user3");

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
 vm.prank(user1);
        lottery.entry{value: 5 ether}();

        vm.prank(user2);
        lottery.entry{value: 5 ether}();

        vm.prank(user3);
        lottery.entry{value: 5 ether}();

        // Expect event from the lottery contract
        vm.expectEmit(false, false, false, true, address(lottery));
        emit WinnerSelected(address(0)); // dummy address, will match any

        vm.prank(OWNER);
        address winner = lottery.selectWinner();

        // Check that winner is actually in participants
        bool found;
         address[3] memory participants = [
            user1,
            user2,
            user3
        ];
        for (uint i = 0; i < 3; i++) {
            if (winner == participants[i]) {
                found = true;
                break;
            }
        }
        assertTrue(found, "Winner must be one of the participants");
    }

    function testSelectWinnerMultipleTimes() public {
        // Add 2 participants
        address user1 = USER;
        address user2 = makeAddr("user2");

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        vm.prank(user1);
        lottery.entry{value: 5 ether}();

        vm.prank(user2);
        lottery.entry{value: 5 ether}();

        // First selection
        vm.prank(OWNER);
        address winner1 = lottery.selectWinner();
        // Second selection (may be different, random based on block.timestamp & prevrandao)
        vm.prank(OWNER);
        address winner2 = lottery.selectWinner();

        // Both winners must be in participants
        address[2] memory participants = [user1, user2];
        bool found1;
        bool found2;
        for (uint i = 0; i < 2; i++) {
            if (winner1 == participants[i]) found1 = true;
            if (winner2 == participants[i]) found2 = true;
        }
        assertTrue(found1 && found2, "Winners must be participants");
    }
