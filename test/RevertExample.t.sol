// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {RevertExample} from "../src/RevertExample.sol";

contract RevertExampleTest is Test {
    RevertExample public revertExample;

    function setUp() public {
        revertExample = new RevertExample();
    }

    function testRevertOnEnterNumLessThan10() public {
        vm.expectRevert(bytes("Number must be greater than 10"));
        revertExample.setNumber(5);
    }

    function testSetNumber() public {
        revertExample.setNumber(45);
        assertEq(revertExample.number(), 45);
    }

    function testRevertOnEnterNameLessThanTwoCharacter() public {
        string memory name = "s";
        vm.expectRevert(
            abi.encodeWithSelector(RevertExample.NameTooShort.selector, 1)
        );
        revertExample.setName(name);
    }

    function testSetName() public {
        revertExample.setName("Govinda");
        assertEq(revertExample.name(), "Govinda");
    }

    function testDangarousMaths() public {
        uint256 result = revertExample.dangarousMath(2);
        assertGe(result, 2);
        assertEq(result, 200);
    }

    function testBuggyFun() public {
        uint256 sum = revertExample.buggyFunction(5, 10);
        assertGe(sum, 5);
        assertEq(sum, 15);
    }
}
