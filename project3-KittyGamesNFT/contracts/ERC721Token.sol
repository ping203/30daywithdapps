// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library Address {
    function isContract(address _addr)
        internal
        view
        returns (bool addressCheck)
    {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        } // solhint-disable-line
        addressCheck = size > 0;
    }
}

interface ERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

/* is ERC165 */
interface ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

contract ERC721Token is ERC721 {
    using Address for address;
    mapping(address => uint256) private ownerToTokenCount;
    mapping(uint256 => address) private idToOwner;
    mapping(uint256 => address) private idToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    string public name;
    string public symbol;
    string public tokenURIBase;
    mapping(uint256 => address) private tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURIBase
    ) public {
        name = _name;
        symbol = _symbol;
        tokenURIBase = _tokenURIBase;
    }

    function _mint(address _owner, uint256 _tokenId) internal {
        require(idToOnwer[_tokenId] == address(0), "this token already exist");
        idToOwner[_tokenId] = owner;
        ownerToTokenCount[onwer] += 1;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return string(abi.encodePacked(tokenURIBase, tokenId));
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerToTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return idToOwner[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = idToOwner[_tokenId];
        require(msg.sender == owner, "Not authorized");
        idToApproved[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return idToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return ownerToOperators[_owner][_operator];
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        _transfer(_from, _to, _tokenId);

        if (_to.isContract()) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                data
            );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                "recipient SC cannot handle ERC721 tokens"
            );
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal canTransfer(_tokenId) {
        ownerToTokenCount[_from] -= 1;
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    modifier canTransfer(uint256 _tokenId) {
        address owner = idToOwner[_tokenId];
        require(
            owner == msg.sender ||
                idToApproved[_tokenId] == msg.sender ||
                ownerToOperators[owner][msg.sender] == true,
            "Transfer not authorized"
        );
        _;
    }
}
