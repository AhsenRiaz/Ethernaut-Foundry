// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract King {
    address king;
    uint public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    // CEI ignored
    receive() external payable {
        // msg.sender should send msg.value greater then the prize
        require(msg.value >= prize || msg.sender == owner);
        // send the msg.value the previous king
        payable(king).transfer(msg.value);

        // become the new king
        king = msg.sender;
        // set the new prize
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}
