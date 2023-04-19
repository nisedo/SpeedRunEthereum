// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 ethAmount);


  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  function withdraw() payable public onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "Nothing to withdraw; contract balance empty");
    address _owner = owner();
    (bool sent, ) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
  }

  function sellTokens(uint256 _amount) public payable {
    uint256 ethAmount = _amount / tokensPerEth;
    require(address(this).balance >= ethAmount, "Not enough ETH in the Vendor contract");
    yourToken.transferFrom(msg.sender, address(this), _amount);
    payable(msg.sender).transfer(ethAmount);
    emit SellTokens(msg.sender, _amount, ethAmount);
  }
}
