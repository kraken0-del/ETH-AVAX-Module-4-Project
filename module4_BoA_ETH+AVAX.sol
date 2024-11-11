// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Degen", "DGN") {}
    
    struct Hero {
    string name;
    uint256 price;
    }

    mapping(uint256 => Hero) public heroes;
    uint256 public nextHeroId;

    mapping(address => mapping(uint256 => uint256)) public userInventory; // User's inventory

    event HeroAdded(uint256 heroId, string name, uint256 price);
    event HeroPurchased(address indexed buyer, uint256 heroId, string name, uint256 price);

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return super.transfer(recipient, amount);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function addHero(string memory _name, uint256 _price) external onlyOwner {
        heroes[nextHeroId] = Hero(_name, _price);
        emit HeroAdded(nextHeroId, _name, _price);
        nextHeroId++;
    }

    function buyHero(uint256 _heroId) external {
        require(_heroId < nextHeroId, "Invalid drink ID");
        Hero storage hero = heroes[_heroId];
        require(balanceOf(msg.sender) >= hero.price, "Not enough Degen Tokens");

        transfer(owner(), hero.price);
        userInventory[msg.sender][_heroId]++;

        emit HeroPurchased(msg.sender, _heroId, hero.name, hero.price);
        burn(hero.price);
    }
}
