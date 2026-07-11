// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Time-Locked Personal Vault
/// @notice Personal vault yang mengunci ETH hingga waktu tertentu.
contract PersonalVault {
    address public owner;
    uint256 public unlockTime;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);
    event LockExtended(uint256 previousUnlockTime, uint256 newUnlockTime);

    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    constructor(uint256 _unlockTime) {
        if (_unlockTime <= block.timestamp) {
            revert InvalidUnlockTime();
        }

        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        uint256 amount = address(this).balance;
        require(amount > 0, "No balance");

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(owner, amount);
    }

    function extendLock(uint256 newTime) external onlyOwner {
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        uint256 previousUnlockTime = unlockTime;
        unlockTime = newTime;

        emit LockExtended(previousUnlockTime, newTime);
    }
}
