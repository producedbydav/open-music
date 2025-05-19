/*
                     ░▒▓███████▓▒░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░        ░▒▓██████▓▒░░▒▓████████▓▒░                                  
                    ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                                         
                    ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                                         
                     ░▒▓██████▓▒░░▒▓█▓▒░▒▓█▓▒▒▓███▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░                                    
                           ░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                                         
                           ░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                                         
                    ░▒▓███████▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░       ░▒▓██████▓▒░░▒▓█▓▒░                                         
                                                                                                                 
                                                                                                                 
     ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░      ░▒▓████████▓▒░▒▓█▓▒░▒▓██████████████▓▒░░▒▓████████▓▒░░▒▓███████▓▒░ 
        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░        
        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░        
        ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓██████▓▒░           ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░  ░▒▓██████▓▒░  
        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░ 
        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░                ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░ 
        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓███████▓▒░                                                                          
*/
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

interface IExternalRenderer {
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

contract Sign_of_the_Times is ERC721, Ownable {

    uint public nextToken = 1;
    uint public maxSupply = 50;
    uint public price = 0.03 ether;

    bool public mintActive;
    bool public mintLock;
    bool public rendererLock;

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    IExternalRenderer public externalRenderer;

    constructor()
        ERC721("Sign of the Times", "SIGN")
        Ownable(msg.sender)
    {}

    function mintAdmin(address _to, uint _amount) public onlyOwner {
        require (nextToken <= maxSupply && mintActive, "Mint has completed");
        for (uint i = 0; i < _amount; i++) {
            _safeMint(_to, nextToken);
            nextToken++;
        }
    }
    
    function mintPublic(address _to, uint _amount) public payable {
        require (msg.value == price * _amount, "Must send 0.03 eth per token");
        require (nextToken <= maxSupply && mintActive, "Mint has completed");
        for (uint i = 0; i < _amount; i++) {
            _safeMint(_to, nextToken);
            nextToken++;
        }
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_tokenId < nextToken, "ERC721Metadata: URI query for nonexistent token");
        return externalRenderer.tokenURI(_tokenId);
    }

    function setRenderer(address _newRenderer) public onlyOwner {
        require(!rendererLock, "This renderer has been locked.");
        externalRenderer = IExternalRenderer(_newRenderer);
        emit BatchMetadataUpdate(1, nextToken - 1);
    }

    function lockRenderer() public onlyOwner {
        rendererLock = true;
    }
    
    function toggleMintActive() public onlyOwner {
        require(!mintLock, "Mint locked");
        mintActive = !mintActive;
    }

    function updateSupply(uint _newSupply) public onlyOwner {
        require(!mintLock, "Mint locked");
        maxSupply = _newSupply;
    }

    function lockMint() public onlyOwner {
        mintLock = true;
    }

    function refreshMetadata() public {
        emit BatchMetadataUpdate(1, nextToken - 1);
    }
}
