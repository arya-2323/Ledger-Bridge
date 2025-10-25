// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LedgerBridge {
    address public owner;

    struct Transaction {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    Transaction[] public transactions;

    event TransactionRecorded(address indexed sender, address indexed receiver, uint256 amount, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    // Function 1: Record a new transaction
    function recordTransaction(address _receiver, uint256 _amount) public {
        transactions.push(Transaction(msg.sender, _receiver, _amount, block.timestamp));
        emit TransactionRecorded(msg.sender, _receiver, _amount, block.timestamp);
    }

    // Function 2: Get total number of transactions
    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    // Function 3: Get transaction details by index
    function getTransaction(uint256 index) public view returns (address, address, uint256, uint256) {
        require(index < transactions.length, "Invalid index");
        Transaction memory txn = transactions[index];
        return (txn.sender, txn.receiver, txn.amount, txn.timestamp);
    }
}
