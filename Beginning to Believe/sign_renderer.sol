// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base64.sol";
import "./IT0nev1.sol";
import "./ILens.sol";
import "./sign_lib.sol";
import "./sign_svg.sol";

interface IERC721 {
    function ownerOf(uint tokenId) external view returns (address);
    function refreshMetadata() external;
}

interface IVisualizer {
    function name() external view returns (string memory);
    function generateVisualizer(string memory _colorBg, string memory _colorFg, string memory _input1, string memory _input2, uint _size1, uint _size2) external pure returns (string memory);
}

interface IBeginningRenderer {
    function generateSVG(string memory _text, bytes[2] memory _colors) external view returns (string memory);
    function lenses(uint) external view returns (ILens);
    function currentLens() external view returns (uint);
    function getTonejs() external view returns (string memory);
}

interface ISignScript {
    function generateScript(uint _tokenId) external view returns (string memory);
    function generateNotes(uint _tokenId) external view returns (string memory);
    function generateSynths() external view returns (string memory);
    function generateSignalChains() external view returns (string memory);
    function generateLFOs() external view returns (string memory);
    function generatePlayers() external view returns (string memory);
    function buildScript(
        string memory notes,
        string memory synths,
        string memory signalChains,
        string memory lfos,
        string memory players,
        string memory footer,
        string memory visualizer
    ) external pure returns (string memory);
}

contract sign_renderer {

    address public Owner;
    IERC721 public immutable tokenContract;
    IBeginningRenderer public immutable btbRenderer;
    IT0neV1 public immutable t0neV1;
    ISignScript public script;
    IVisualizer public visualizer;
    address v1Visualizer;

    string private constant notAuth = "Not authorized";

    struct freezeStruct {
        bool isFrozen;
        uint8[32] melody;
        uint8[4] bass;
        bytes[2] colors;
        address visual;
        uint freezeBlock;
        string lensName;
    }
    
    mapping (uint => freezeStruct) public freezeData;

    constructor () {
        Owner = msg.sender;
        tokenContract = IERC721(0xc8AC71704276ca9e0c81707d1C77da99607e2bb5);
        btbRenderer = IBeginningRenderer(0x6B7E07cE896c7DFfDC936BAe8060A0F7fF71A3b2);
        t0neV1 = IT0neV1(0xC7C69be443404aa8CA9889914231e06d5631D32e);
        v1Visualizer = 0x704d2278bCdD90b42b2f8e77690E027FA8B201F3;
        visualizer = IVisualizer(v1Visualizer);
    }

    function tokenURI(uint256 _tokenId) external view returns(string memory) {

        string memory bgC = string(getColors(_tokenId)[0]);
        string memory fgC = string(getColors(_tokenId)[1]);
        string memory tBlock = freezeData[_tokenId].isFrozen ? LibString.toString(freezeData[_tokenId].freezeBlock) : "";
        
        string memory svg = signSVGLib.generateSVG(bgC, fgC, tBlock);
        string memory traits = tokenToTraits(_tokenId);
        string memory htmlCode = sign_lib.buildHTML(
            btbRenderer.getTonejs(),
            generateScript(_tokenId)
        );
        return sign_lib.buildTokenURI(_tokenId, svg, htmlCode, traits);
    }

    function tokenToTraits(uint _tokenId) private view returns (string memory) {
        string memory froze = freezeData[_tokenId].isFrozen ? "Frozen" : "Live";
        string memory blockTrait = freezeData[_tokenId].isFrozen ? string.concat(',{"trait_type": "Block", "value": "', LibString.toString(freezeData[_tokenId].freezeBlock), '"}') : "";
        string memory lensStr = freezeData[_tokenId].isFrozen ? freezeData[_tokenId].lensName : getCurrentLens().name();
        address addrVis = freezeData[_tokenId].isFrozen ? address(freezeData[_tokenId].visual) : address(visualizer);
        string memory visStr = addrVis == v1Visualizer ? 'v1' : IVisualizer(addrVis).name();
        return string(abi.encodePacked(
            '{"trait_type": "Status", "value": "', froze, '"}, ',
            '{"trait_type": "Visualizer", "value": "', visStr, '"}, ',
            '{"trait_type": "Lens", "value": "', lensStr, '"} ',
            blockTrait
        ));
    }

    function generateScript(uint _tokenId) public view returns (string memory) {
        string memory notes = script.generateNotes(_tokenId);
        string memory synths = script.generateSynths();
        string memory chains = script.generateSignalChains();
        string memory lfos = script.generateLFOs();
        string memory players = script.generatePlayers();
        string memory footer = string(t0neV1.generateFooterCode("draw();", ""));
        string memory visualizerCode = generateVisualizer(_tokenId);
        return script.buildScript(notes, synths, chains, lfos, players, footer, visualizerCode);
    }

    function generateVisualizer(uint _tokenId) public view returns (string memory) {
        bytes[2] memory tempColors = getColors(_tokenId);
        string memory colorBg = string(tempColors[0]);
        string memory colorFg = string(tempColors[1]);
        return visualizer.generateVisualizer(colorBg, colorFg, "effect14", "effect1", 2048, 64);
    }
       
    function getCurrentLens() private view returns (ILens) {
        return btbRenderer.lenses(btbRenderer.currentLens());
    }

    //-----------------------------------------------------------------------------
    //------------- Get select notes from current Lens (or freeze data) -----------
    //-----------------------------------------------------------------------------

    function getColors(uint _tokenId) public view returns (bytes[2] memory) {
        ILens lens = getCurrentLens();
        return freezeData[_tokenId].isFrozen ? freezeData[_tokenId].colors : lens.colors();
    }

    function transferOwnership(address _newOwner) public {
        require (msg.sender == Owner, notAuth);
        Owner = _newOwner;
    }
    
    function updateVisualizer(address _newVis) public {
        require (msg.sender == Owner, notAuth);
        visualizer = IVisualizer(_newVis);
    }

    function holderFreezeToken(uint _tokenId) public {
        require(msg.sender == tokenContract.ownerOf(_tokenId), "Must be token holder");
        require(!freezeData[_tokenId].isFrozen, "Token already frozen");
        freezeData[_tokenId].isFrozen = true;
        freezeData[_tokenId].bass = ILens(getCurrentLens()).notesBass();
        freezeData[_tokenId].melody = ILens(getCurrentLens()).notesMelody2();
        freezeData[_tokenId].colors = ILens(getCurrentLens()).colors();
        freezeData[_tokenId].visual = address(visualizer);
        freezeData[_tokenId].freezeBlock = block.number;
        freezeData[_tokenId].lensName = getCurrentLens().name();
        tokenContract.refreshMetadata();
    }

    function getFreezeData(uint _tokenId) external view returns (freezeStruct memory) {
        return freezeData[_tokenId];
    }
    

    function setScript(address _script) public {
        require (msg.sender == Owner, notAuth);
        script = ISignScript(_script);
    }

}
