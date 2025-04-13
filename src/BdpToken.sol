// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BDPToken is ERC20, Ownable {
    uint256 public constant MAX_MINT_PER_DAY = 1000 * 10**18;
    mapping(address => uint256) public lastMintTimestamp;
    mapping(address => uint256) public dailyMinted;

    constructor() ERC20("Beignet de Plaisir", "BDP") Ownable(msg.sender) {
        _mint(msg.sender, 10000 * 10**18);
    }

    function mint(uint256 amount) external {
        require(amount > 0, "Mint amount must be greater than 0");
        require(amount <= MAX_MINT_PER_DAY, "Exceeds max mint per day");

        uint256 today = block.timestamp / 1 days;

        if (lastMintTimestamp[msg.sender] < today) {
            dailyMinted[msg.sender] = 0;
            lastMintTimestamp[msg.sender] = today;
        }

        require(dailyMinted[msg.sender] + amount <= MAX_MINT_PER_DAY, "Mint limit exceeded for today");

        dailyMinted[msg.sender] += amount;
        _mint(msg.sender, amount);
    }
}
