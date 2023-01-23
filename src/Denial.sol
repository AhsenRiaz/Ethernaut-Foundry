// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Denial {
    address public partner;
    address public immutable owner;
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances;

    constructor() payable {
        owner = msg.sender;
    }

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw function is called
    // owner can receive funds when the partner does. 
    // what if the attacker implement an attack in which partner can never receive fudns. 
    // Making the service fail each time withdraw is called. 
    // Check the Denial.t.sol for the exampleI
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;

        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
