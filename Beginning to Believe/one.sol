// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

interface IExternalRenderer {
    function tokenURI(uint256 _tokenId) external view returns (string memory);
    function transferFunction(address from, address to) external;
    function getSatellite(uint _sat) external view returns (address);
}

contract one is ERC721, Ownable {

    uint public nextToken = 1;
    uint public currentPublicMint;
    mapping (uint => bool) public functionalTransfer;
    mapping (uint => bool) public rendererLock;
    mapping (uint => uint) public price;
    uint[] public reviveOmit;
    address burner = 0x000000000000000000000000000000000000dEaD;

    event MetadataUpdate(uint256 _TokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    mapping (uint => IExternalRenderer) public externalRenderer;

    constructor()
        ERC721("one", "ONE")
        Ownable(msg.sender)
    {}

    function mintAdminToOther(address to) public onlyOwner {
        _safeMint(to, nextToken);
        nextToken++;
    }

    function mintPublic(address _to) public payable {
        require (msg.value == price[nextToken], "Price incorrect");
        require (currentPublicMint >= nextToken, "Token not available");
        _safeMint(_to, nextToken);
        nextToken++;
    }

    function mintAdmin() public onlyOwner {
        _safeMint(msg.sender, nextToken);
        nextToken++;
    }

    function burn(uint _tokenId) public {
        require (ownerOf(_tokenId) == msg.sender, "Must be current token holder.");
        safeTransferFrom(msg.sender, burner, _tokenId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_tokenId < nextToken, "ERC721Metadata: URI query for nonexistent token");
        return externalRenderer[_tokenId].tokenURI(_tokenId);
    }

    function setRenderer(uint _index, address _newRenderer) public onlyOwner {
        require(!rendererLock[_index], "This renderer has been locked.");
        externalRenderer[_index] = IExternalRenderer(_newRenderer);
    }

    function lockRenderer(uint _index) public onlyOwner {
        rendererLock[_index] = true;
    }

    function setPrice(uint _id, uint _price) public onlyOwner {
        price[_id] = _price;
    }

    function setCurrentPublicMintable(uint _index) public onlyOwner {
        currentPublicMint = _index;
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {

        address from = super._update(to, tokenId, auth);

        if (functionalTransfer[tokenId]) {
            externalRenderer[tokenId].transferFunction(from, to);
        }

        emit MetadataUpdate(tokenId);

        return from;
    }

    function revive(uint _tokenId, address _to) external {
        require (msg.sender == address(externalRenderer[_tokenId]), "Not authorized");
        require (indexOf(_tokenId) == -1, "Token omitted from revive");
        require (ownerOf(_tokenId) == burner, "Token must be burned first");
        _transfer(burner, _to, _tokenId);
    }

    function omitTokenFromRevive(uint _tokenId) public onlyOwner{
        reviveOmit.push(_tokenId);
    }

    function indexOf(uint _value) internal view returns (int) {
        for (uint i = 0; i < reviveOmit.length; i++) {
            if (reviveOmit[i] == _value) {
                return int(i);
            }
        }
        return -1;
    }
    
    function refreshMetadata(uint _tokenId) public {
        emit MetadataUpdate(_tokenId);
    }

    function getSatellite(uint _tokenId, uint _sat) public view returns (address) {
        return externalRenderer[_tokenId].getSatellite(_sat);
    }

    function toggleFunctionalTransfer(uint _tokenId) public onlyOwner {
        require (!rendererLock[_tokenId], "Function has been locked");
        functionalTransfer[_tokenId] = !functionalTransfer[_tokenId];
    }

    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");

        (bool success, ) = owner().call{value: contractBalance}("");
        require(success, "Withdrawal failed");
    }

}

