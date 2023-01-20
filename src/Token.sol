// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

contract Token {
    // address to uint mapping
    mapping(address => uint) balances;
    uint public totalSupply;

    constructor(uint _initialSupply) public {
        // set initial to msg.sender
        // set total supply
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        // check balance of msg.sender - value greater than zero
        // 20 - 21 => => underflow returns max value => 2^256-1 >= 0 => true
        require(balances[msg.sender] - _value >= 0);
        // cut value from msg.sender

        // 20 - 21 => -1 => uint().max => 2^256-1 =>  underflow attack results to maximum value
        balances[msg.sender] -= _value;
        // add value to `to` address
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}
