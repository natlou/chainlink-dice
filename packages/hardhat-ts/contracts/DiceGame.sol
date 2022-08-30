pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

contract DiceGame {

    //  The nonce is the number that blockchain miners are solving to receive the block reward.
    uint256 public nonce = 0;
    uint256 public prize = 0;

    event Roll(address indexed player, uint256 roll);
    event Winner(address winner, uint256 amount);

    constructor() payable {
        // can deposit initial prize
        resetPrize();
    }

    function resetPrize() private {
        // initial prize is 10% of the balance (smart math) 
        prize = ((address(this).balance * 10) / 100);
    }

    function rollTheDice() public payable {
        // makes sure roll is above 0.002 ether 
        require(msg.value >= 0.002 ether, "Failed to send enough value");

        // gets the blockhash of the previous block (current blockhash is not revealed)
        bytes32 prevHash = blockhash(block.number - 1);
        // turns prevHash, address(this), nonce (in that order) to a hash: 0x(prevHash)(address(this))(none)
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce)); // abi.encodePacked() can be decoded
        // turns the hash into an int and takes the mod of 16
        uint256 roll = uint256(hash) % 16;

        console.log("THE ROLL IS ",roll);

        nonce++; //increments nonce
        prize += ((msg.value * 40) / 100);

        emit Roll(msg.sender, roll);

        // ends contract call if player doesnt win 
        if (roll > 2 ) {
            return;
        }

        // otherwise send the player the prize
        uint256 amount = prize;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        resetPrize();
        emit Winner(msg.sender, amount);
    }

    // fallback payable
    receive() external payable {  }
}
