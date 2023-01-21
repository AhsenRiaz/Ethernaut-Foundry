// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/utils/math/SafeMath.sol";

contract Reentrancy {
    // balance of any address
    mapping(address => uint) public balances;

    // donate to an address
    function donate(address _to) public payable {
        balances[_to] = balances[_to] + msg.value;
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    // withdraw funds
    // Ignored CEK (Check, Effect, Interract) pattern
    // updating the state after the transaction results in re-entrancy attack
    // attacker can keep calling the function and steal funds until no funds are leftI
    function withdraw(uint _amount) public {
        // balance greater than or equal to withdraw amount
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            // also underflow attack attack possible. it will result in uint max value
            // 10 - 100 => uint max => 2^256-1 amount can be withdrawn
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}
