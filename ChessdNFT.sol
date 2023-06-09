// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }


    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }


    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }


    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

 
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }


    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

library EnumerableMap {

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;
        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            MapEntry storage lastEntry = map._entries[lastIndex];
            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }


    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor ()  {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_)  {
        _name = name_;
        _symbol = symbol_;
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

abstract contract ERC721Burnable is Context, ERC721 {
    
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ItokenRecipient { 
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external returns (bool); 
}

interface Token {
    
    function totalSupply() external view returns (uint256 supply);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract ChessdNFT is ERC721Burnable,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    address payable public developer;
    event changeDeveloper(address indexed previousAdd, address indexed newAdd);
    
    Token tokenContract;
    event changeToken(Token indexed previousToken, Token indexed newToken);
    
    event addPieces(address player);
    event chgRatio(uint newRatio);

    struct Pieces {
        string name;
        uint atx;
        uint def;
        uint str;
        uint no;
    }
    
    Pieces[] public pieces;
    
    struct Char {
        address owner;
        string name;
        uint color;
    }
    
    mapping (address => Char[]) public charPlayer;
    address [] public players;
    
    uint public price =  0x0;
    uint public customTokenPrc = 0x0;
    uint public chngPrc = 0x0;
    uint public trainPrc = 0x0;
    uint public ratio = 0x2;
    
    constructor(Token _tokenContract) ERC721("Chess Piece dNFT", "PIECE") {
        address msgSender = _msgSender();
        developer = payable(msgSender);
        tokenContract = _tokenContract;
    }
    
    function chessRand(uint mod) public view returns(uint) {
        uint random = uint(keccak256(abi.encodePacked(
            block.timestamp,
            block.difficulty,
            msg.sender)
        )) % mod;

        return random;
    }
    
    function addChar(string memory _name,uint _color) external payable {
        address senderAdr = msg.sender;
        developer.transfer(msg.value);
        require(msg.value >= price);
        charPlayer[senderAdr].push(Char(senderAdr,_name,_color));
        players.push(senderAdr);
    }
    
    function getChar(address _charPlayer) public view returns (address,string memory,uint) {
        Char storage char = charPlayer[_charPlayer][0];
        return (char.owner,char.name,char.color);
    } 
    
    function changeChar(string memory _name,uint _color) external payable {
        address senderAdr = msg.sender;
        developer.transfer(msg.value);
        require(msg.value >= price);
        Char storage char = charPlayer[senderAdr][0];
        char.name = _name;
        char.color = _color;
    }  
    
    function newPiece() external payable returns (uint256) {
        address senderAdr = msg.sender;
        developer.transfer(msg.value);
        require(msg.value >= price);
        emit addPieces(senderAdr);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory nameNumb = uint2str(chessRand(0x270F));
        string memory tokenURI = string(abi.encodePacked("Pieces-", nameNumb));
        _mint(senderAdr, newItemId);
        _setTokenURI(newItemId, tokenURI);
        string memory _name = tokenURI;
        uint _atx = chessRand(0x23);
        uint _def = chessRand(0x24);
        uint _str = chessRand(0x25);
        uint _no = chessRand(0x63);
        pieces.push(Pieces(_name,_atx,_def,_str,_no));
        return newItemId;
    }
    
    function getPiece(uint _piece) public view returns (string memory,uint,uint,uint,uint) {
        Pieces storage piece = pieces[_piece];
        return (piece.name,piece.atx,piece.def,piece.str,piece.no);
    }
    
    function addNewPiece(address player) internal returns (uint256) {
        emit addPieces(player);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory nameNumb = uint2str(chessRand(0x270F));
        string memory tokenURI = string(abi.encodePacked("Pieces-", nameNumb));
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        string memory _name = tokenURI;
        uint _atx = chessRand(0x23);
        uint _def = chessRand(0x24);
        uint _str = chessRand(0x25);
        uint _no = chessRand(0x63);
        pieces.push(Pieces(_name,_atx,_def,_str,_no));
        return newItemId;
    }
    
    function changePieces(uint256 tokenId, string memory _name) internal {
        uint arrayId = tokenId - 1;
        Pieces storage piece = pieces[arrayId];
        piece.name = _name;
    }    
    
    function training(uint256 tokenId, uint _atx, uint _def, uint _str) internal {
        uint arrayId = tokenId - 1;
        Pieces storage piece = pieces[arrayId];
        piece.atx = _atx;
        piece.def = _def;
        piece.str = _str;
    }
    
    function addNewPieces(address player) public onlyOwner returns (uint256) {
        emit addPieces(player);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory nameNumb = uint2str(chessRand(0x270F));
        string memory tokenURI = string(abi.encodePacked("Pieces-", nameNumb));
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        string memory _name = tokenURI;
        uint _atx = chessRand(0x23);
        uint _def = chessRand(0x24);
        uint _str = chessRand(0x25);
        uint _no = chessRand(0x63);
        pieces.push(Pieces(_name,_atx,_def,_str,_no));
        return newItemId;
    }
    
    
    function addChars(address _player,string memory _name,uint _color) public onlyOwner {
        charPlayer[_player].push(Char(_player,_name,_color));
        players.push(_player);
    }
    
    function changeChars(address _player,string memory _name,uint _color) public onlyOwner {
        Char storage char = charPlayer[_player][0];
        char.name = _name;
        char.color = _color;
    }     
    
    function changeSkill(uint256 tokenId, uint _atx, uint _def, uint _str) public onlyOwner {
        uint arrayId = tokenId - 1;
        Pieces storage piece = pieces[arrayId];
        piece.atx = _atx;
        piece.def = _def;
        piece.str = _str;
    }
        
    function changeNo(uint256 tokenId, uint _no) public onlyOwner {
        uint arrayId = tokenId - 1;
        Pieces storage piece = pieces[arrayId];
        piece.no = _no;
    }
    
    function changeName(uint256 tokenId, string memory _name) public onlyOwner {
        uint arrayId = tokenId - 1;
        Pieces storage piece = pieces[arrayId];
        piece.name = _name;
    }
        
    function getPrice() public view returns (uint) {
        return price;
    } 
    
    function changePrice(uint _price) public onlyOwner {
        emit chgRatio(_price);
        price = _price;
    }
    
    function getPiecePrice() public view returns (uint) {
        return customTokenPrc;
    } 
    
    function changeCustomTokenPrice(uint _price) public onlyOwner {
        customTokenPrc = _price;
    }
    
    function getPieceChgPrice() public view returns (uint) {
        return chngPrc;
    } 
    
    function changeCustomTokenChgPrice(uint _price) public onlyOwner {
        chngPrc = _price;
    }
    
    function getTrainPrice() public view returns (uint) {
        return trainPrc;
    } 
    
    function changeTrainPrice(uint _price) public onlyOwner {
        trainPrc = _price;
    }
    
    function getRatio() public view returns (uint) {
        return ratio;
    } 
    
    function changeRatio(uint _ratio) public onlyOwner {
        ratio = _ratio;
    }

    function getDev() public view returns (address) {
        return developer;
    }
    
    function changeDev(address newAddress) public onlyOwner {
        emit changeDeveloper(developer, newAddress);
        developer = payable(newAddress);
    }
    
    function getTokenAdr() public view returns (address) {
        return address(tokenContract);
    }
    
    function changeTokenAdr(Token newToken) public onlyOwner {
        emit changeToken(tokenContract, newToken);
        tokenContract = newToken;
    }
    
    function transferToken() public onlyOwner{
        require(tokenContract.transfer(developer, tokenContract.balanceOf(address(this))));
    }
    
    function burnPiece(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }
    
    
    fallback () external payable {}
    
    receive() external payable {
        developer.transfer(msg.value);
    }
    
    function bytes2str(bytes memory _bytes) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < _bytes.length && _bytes[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (uint z = 0; z < 32 && _bytes[z] != 0; z++) {
            bytesArray[i] = _bytes[i];
        }
        return string(bytesArray);
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory uinStr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            uinStr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(uinStr);
    }

    function getPiece() external returns (bool){
        address senderAdr = msg.sender;
        address contractAdd = address(this);
        uint256 senderBalance = tokenContract.balanceOf(senderAdr);
        tokenContract.approve(contractAdd,senderBalance);
        uint256 allowance = tokenContract.allowance(senderAdr, contractAdd);
        require(allowance >= customTokenPrc, "Check the token allowance.");
        require(senderBalance >= customTokenPrc, "You have not enough balance.");
        bool transferData = tokenContract.transferFrom(senderAdr, contractAdd, customTokenPrc);
        require(transferData, "There is a problem about transfer.");
        addNewPieces(senderAdr);
        return transferData;
    }
    
    function changePiece(uint256 tokenId, string memory _name) external returns (bool) {
        address senderAdr = msg.sender;
        address contractAdd = address(this);
        uint256 senderBalance = tokenContract.balanceOf(senderAdr);
        tokenContract.approve(contractAdd,senderBalance);
        uint256 allowance = tokenContract.allowance(senderAdr, contractAdd);
        require(allowance >= chngPrc, "Check the token allowance.");
        require(senderBalance >= chngPrc, "You have not enough balance.");
        bool transferData = tokenContract.transferFrom(senderAdr, contractAdd, chngPrc);
        require(transferData, "There is a problem about transfer.");
        require(ownerOf(tokenId) == senderAdr, "ERC721: Change of token that is not own");
        changePieces(tokenId,_name);
        return transferData;
    }
    
    function trainingPiece(uint256 tokenId) external returns (bool) {
        address senderAdr = msg.sender;
        address contractAdd = address(this);
        uint256 senderBalance = tokenContract.balanceOf(senderAdr);
        tokenContract.approve(contractAdd,senderBalance);
        uint256 allowance = tokenContract.allowance(senderAdr, contractAdd);
        require(allowance >= trainPrc, "Check the token allowance.");
        require(senderBalance >= trainPrc, "You have not enough balance.");
        bool transferData = tokenContract.transferFrom(senderAdr, contractAdd, trainPrc);
        require(transferData, "There is a problem about transfer.");
        require(ownerOf(tokenId) == senderAdr, "ERC721: Change of token that is not own");
        Pieces storage piece = pieces[tokenId];
        uint _atx = piece.atx + chessRand(ratio);
        uint _def = piece.def + chessRand(ratio);
        uint _str = piece.str + chessRand(ratio);
        training(tokenId,_atx,_def,_str);
        return transferData;
    }
        
}
