// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title LedgerBridge
 * @dev Simple mapping bridge between external ledger identifiers and on-chain accounts
 * @notice Links off-chain ledger IDs (bytes32) to Ethereum addresses and optional metadata
 */
contract LedgerBridge {
    address public owner;

    struct Link {
        bytes32 ledgerId;     // external ledger/account identifier
        address account;      // mapped on-chain account
        string  network;      // e.g. "L1", "L2-OP", "Solana-bridge-id"
        string  note;         // optional note/description
        uint256 createdAt;
        uint256 updatedAt;
        bool    exists;
    }

    // ledgerId => Link
    mapping(bytes32 => Link) public linksByLedgerId;

    // account => list of ledgerIds
    mapping(address => bytes32[]) public ledgerIdsOf;

    event LinkCreated(
        bytes32 indexed ledgerId,
        address indexed account,
        string network,
        uint256 timestamp
    );

    event LinkUpdated(
        bytes32 indexed ledgerId,
        address indexed account,
        string network,
        string note,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier linkExists(bytes32 ledgerId) {
        require(linksByLedgerId[ledgerId].exists, "Link not found");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new link between an external ledger id and an on-chain account
     * @param ledgerId External ledger identifier (must be unique)
     * @param account On-chain account to associate
     * @param network Short label of the external network
     * @param note Optional description
     */
    function createLink(
        bytes32 ledgerId,
        address account,
        string calldata network,
        string calldata note
    ) external onlyOwner {
        require(ledgerId != 0, "Invalid ledgerId");
        require(account != address(0), "Zero address");
        require(!linksByLedgerId[ledgerId].exists, "Link exists");

        linksByLedgerId[ledgerId] = Link({
            ledgerId: ledgerId,
            account: account,
            network: network,
            note: note,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            exists: true
        });

        ledgerIdsOf[account].push(ledgerId);

        emit LinkCreated(ledgerId, account, network, block.timestamp);
        emit LinkUpdated(ledgerId, account, network, note, block.timestamp);
    }

    /**
     * @dev Update metadata (account, network, note) for an existing link
     * @param ledgerId External ledger identifier
     * @param account New on-chain account
     * @param network New network label
     * @param note New note
     */
    function updateLink(
        bytes32 ledgerId,
        address account,
        string calldata network,
        string calldata note
    ) external onlyOwner linkExists(ledgerId) {
        require(account != address(0), "Zero address");

        Link storage l = linksByLedgerId[ledgerId];

        // if account changes, append id to new account list
        if (l.account != account) {
            ledgerIdsOf[account].push(ledgerId);
        }

        l.account = account;
        l.network = network;
        l.note = note;
        l.updatedAt = block.timestamp;

        emit LinkUpdated(ledgerId, account, network, note, block.timestamp);
    }

    /**
     * @dev Get full link data by ledgerId
     */
    function getLink(bytes32 ledgerId)
        external
        view
        linkExists(ledgerId)
        returns (
            address account,
            string memory network,
            string memory note,
            uint256 createdAt,
            uint256 updatedAt
        )
    {
        Link memory l = linksByLedgerId[ledgerId];
        return (l.account, l.network, l.note, l.createdAt, l.updatedAt);
    }

    /**
     * @dev Get all ledgerIds associated with an on-chain account
     */
    function getLedgerIdsOf(address account)
        external
        view
        returns (bytes32[] memory)
    {
        return ledgerIdsOf[account];
    }

    /**
     * @dev Transfer contract ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
