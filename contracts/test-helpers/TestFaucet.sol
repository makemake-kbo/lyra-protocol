//SPDX-License-Identifier:ISC
pragma solidity ^0.8.0;

import "./TestERC20.sol";
import "hardhat/console.sol";

contract TestFaucet {
  mapping(uint => uint) dripAmounts;
  TestERC20[] public addresses;

  mapping(address => bool) public permitted;
  mapping(address => bool) public received;

  constructor() {
    permitted[msg.sender] = true;
  }

  function permitModify(address user, bool permit) external {
    require(permitted[msg.sender], "only permitted");
    permitted[user] = permit;
  }

  function setDripAmount(TestERC20 token, uint amount) external {
    require(permitted[msg.sender], "only permitted");
    uint index;
    bool found = false;
    for (index = 0; index < addresses.length; ++index) {
      if (addresses[index] == token) {
        found = true;
        break;
      }
    }
    if (!found) {
      // index will be addresses.length here
      addresses.push(token);
    }
    dripAmounts[index] = amount;
  }

  function drip() external {
    require(!received[msg.sender], "already received");

    for (uint i = 0; i < addresses.length; ++i) {
      console.log(address(addresses[i]));
      addresses[i].mint(msg.sender, dripAmounts[i]);
      emit Dripped(addresses[i], dripAmounts[i]);
    }
    received[msg.sender] = true;
  }

  event Dripped(TestERC20 token, uint amount);
}
