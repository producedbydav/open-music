// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./base64.sol";
import "./IFileStore.sol";

interface IComputeScript {
    function generateScript(uint _tokenId) external view returns (string memory);
    function generateTraits(uint _tokenId) external view returns (string memory);
}

interface ISVG {
    function generateSVG(uint _tokenId) external view returns (string memory);
}

interface IForeverLibrary {
    function ownerOf(uint _tokenId) external view returns (address);
}

contract External_Compute_Renderer_FL {

    IFileStore fileStore;
    IForeverLibrary FL;

    bool lockedAddress;

    constructor() {
        fileStore = IFileStore(0xFe1411d6864592549AdE050215482e4385dFa0FB);
    }

    struct tokenDataStruct {
        address script;
        address svg;
        address artist;
        string title;
        string description;
        bool usesETHFS;
        bool unzip;
        string fileName;
    }

    mapping (uint => tokenDataStruct) public tokenData;

    function setForeverLibraryAddress(address _FL) public {
        require (msg.sender == 0xCB7504C4cb986E80AB4983b44263381F21273482 && !lockedAddress, "Not authorized");
        FL = IForeverLibrary(_FL);
        lockedAddress = true;
    }

    function setData(
            uint _tokenId, 
            address _scriptAddress, 
            address _svgAddress, 
            string memory _title,
            string memory _description,
            bool _usesETHFS,
            bool _unzip,
            string memory _fileName
        ) public {

        require (msg.sender == FL.ownerOf(_tokenId) && tokenData[_tokenId].artist == address(0) ||
            msg.sender == tokenData[_tokenId].artist && tokenData[_tokenId].artist != address(0));
        tokenData[_tokenId].script      = _scriptAddress;
        tokenData[_tokenId].svg         = _svgAddress;
        tokenData[_tokenId].title       = _title;
        tokenData[_tokenId].description = _description;
        tokenData[_tokenId].artist      = msg.sender;
        tokenData[_tokenId].usesETHFS   = _usesETHFS;
        tokenData[_tokenId].unzip       = _unzip;
        tokenData[_tokenId].fileName    = _fileName;
    }

    function tokenURI(uint256 _tokenId) public view returns(string memory) {
        
        string memory svg = ISVG(tokenData[_tokenId].svg).generateSVG(_tokenId);
        string memory traits   = generateTraits(_tokenId);
        string memory file = getFile(_tokenId);
        string memory htmlCode = buildHTML(
            _tokenId,
            file,
            IComputeScript(tokenData[_tokenId].script).generateScript(_tokenId)
        );
        return buildTokenURI(_tokenId, svg, htmlCode, traits);
    }

    function generateTraits(uint _tokenId) private view returns (string memory) {
        return IComputeScript(tokenData[_tokenId].script).generateTraits(_tokenId);
    }

    function buildTokenURI(
        uint _tokenId,
        string memory svg,
        string memory htmlCode,
        string memory traits
    ) public view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"', tokenData[_tokenId].title,
                        '","image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)),
                        '","animation_url":"data:text/html;base64,', htmlCode,
                        '","attributes": [', traits, ']}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function buildHTML(
        uint _tokenId,
        string memory file,
        string memory script
    ) public view returns (string memory) {
        return Base64.encode(
            abi.encodePacked(
                "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>",
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
                "<title>",
                tokenData[_tokenId].title,
                "</title>",
                "<style>* {margin: 0; padding: 0; border: 0;} body{overflow:hidden;} ",
                "#playArea{width:100%;height:100vh;display: flex;justify-content:center;align-items:center;cursor:pointer;position:relative;} ",
                ".lighted {animation-name:light;animation-duration:0.2s;animation-iteration-count:infinite;} ",
                "@keyframes light{0%{scale:1;}20%{scale:1.002;}40%{scale:1.004;}50%{scale:1.005;}60%{scale:1.004;}80%{scale:1.002;}100%{scale:1;}}</style>",
                "</head><body><canvas id='myCanvas' width='100%' height='100%'></canvas>",
                file,
                "<script>", script, "</script></body></html>"
            )
        );
    }

    function getFile(uint _tokenId) public view returns (string memory) {
        string memory unzip = tokenData[_tokenId].unzip ? getUnzip() : "";
        string memory file = tokenData[_tokenId].fileName;

        return string.concat(
            "<script type=\"text/javascript+gzip\" src=\"data:text/javascript;base64,",
            fileStore.getFile(file).read(),
            "\"></script>",
            unzip
        );
    }

    function getUnzip() internal view returns (string memory) {
        return string.concat(
            "<script src=\"data:text/javascript;base64,",
            fileStore.getFile("gunzipScripts-0.0.1.js").read(),
            "\"></script>"
        );
    }

}
