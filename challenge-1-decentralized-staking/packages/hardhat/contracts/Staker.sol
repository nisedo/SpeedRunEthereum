// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

   modifier notCompleted {
      require(!completed);
      _;
   }

  ExampleExternalContract public exampleExternalContract;
  bool public openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping(address => uint256) public balances;
  event Stake(address, uint256);
  uint256 public constant threshold = 1 ether;

  function stake() public payable {
    require(block.timestamp < deadline, "Staking period has ended");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  uint256 public deadline = block.timestamp + 72 hours;
  bool public completed;

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "Deadline has not been reached yet");
    require(!completed, "Already executed");

    if (address(this).balance >= threshold) {
      completed = true;
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  function withdraw() public notCompleted {
    require(openForWithdraw, "Withdrawals are not open");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Nothing to withdraw");
    
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
  }

  function timeLeft() view public returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  receive() external payable {
    stake();
  }
}