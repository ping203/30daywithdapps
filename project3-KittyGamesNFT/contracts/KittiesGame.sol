// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./ERC721Token.sol";

contract KittiesGame is ERC721Token {
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURIBase
    ) public ERC721Token(_name, _token, _tokenURIBase) {
        admin = msg.sender;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return string(abi.encodePacked(tokenURIBase, tokenId));
    }

    struct Kitty {
        uint256 id;
        uint256 generation;
        uint256 genA;
        uint256 genB;
        HairColor hair;
    }

    uint256 public nextId = 1;
    address public admin;
    mapping(uint256 => address) private kitties;

    function breed(uint256 idKitty1, uint256 idKitty2) external {
        require(idKitty1 < nextId && idKitty2 < nextId, "2 kitties must exist");
        require(
            ownerOf[idKitty1] == msg.sender && ownerOf[idKitty2] == msg.sender,
            "msg.sender must own the 2 kitties"
        );
        Kitty storage kitty1 = kitties[idKitty1];
        Kitty storage kitty2 = kitties[idKitty2];
        uint256 maxGen = kitty1.generation > kitty2.generation
            ? kitty1.generation
            : kitty2.generation;
        uint256 genA = _random(4) > 1 ? kitty1.genA : kitty1.genB;
        uint256 genB = _random(4) > 1 ? kitty1.genA : kitty1.genB;
        kitties[nextId] = Kitty(nextId, maxGen, GenA, GenB);
        _mint(msg.sender, nextId);
        nextId++;
    }

    function mint() external {
        require(msg.sender == admin, "admin only");
        kitties[nextId] = Kitty(nextId, 1, _random(8), random(6));
        _mint(msg.sender, nextId);
        nextId++;
    }

    function _random(uint256 max) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % max;
    }
}
