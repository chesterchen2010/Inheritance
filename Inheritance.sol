// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InheritanceContract {
    address public owner;
    address public heir;
    uint256 public lastInteraction;
    uint256 constant oneMonth = 30 days;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event HeirChanged(address indexed previousHeir, address indexed newHeir);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    constructor(address _heir) {
        require(_heir != address(0), "Heir cannot be the zero address");
        owner = msg.sender;
        heir = _heir;
        lastInteraction = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyHeir() {
        require(msg.sender == heir, "Only the heir can call this function");
        require(block.timestamp > lastInteraction + oneMonth, "Owner is still active");
        _;
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance in contract");
        payable(owner).transfer(amount);
        lastInteraction = block.timestamp;
        emit Withdrawal(owner, amount);
    }

    function takeOwnership() public onlyHeir {
        owner = heir;
        lastInteraction = block.timestamp;
        emit OwnershipTransferred(owner, heir);
    }

    function designateNewHeir(address newHeir) public onlyOwner {
        require(newHeir != address(0), "New heir cannot be the zero address");
        heir = newHeir;
        emit HeirChanged(heir, newHeir);
    }

    receive() external payable {}

    fallback() external payable {}
}
