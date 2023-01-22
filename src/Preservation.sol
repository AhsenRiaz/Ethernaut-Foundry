// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Preservation {
    address public timeZone1Library; // slot 0
    address public timeZone2Library; // slot 1
    address public owner; // slot 2
    uint storedTime; // slot3
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)")); // slot 4

    constructor(
        address _timeZone1LibraryAddress,
        address _timeZone2LibraryAddress
    ) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    // attacker - first pass the exploiter address

    function setFirstTime(uint _timeStamp) public {
        // call the timeZone1Library code at run time. any changes made will be reflected on  the Preversation contract

        // attacker - pass the owner address as uint
        timeZone1Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }

    // set the time for timezone 2
    function setSecondTime(uint _timeStamp) public {
        timeZone2Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint storedTime;

    function setTime(uint _time) public {
        storedTime = _time;
    }
}
