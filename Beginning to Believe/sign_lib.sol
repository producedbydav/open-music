// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base64.sol";
import "./LibString.sol";

library sign_lib {
    /// @notice Builds a token URI from SVG, HTML code and traits.
    function buildTokenURI(
        uint tokenId,
        string memory svg,
        string memory htmlCode,
        string memory traits
    ) external pure returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"Sign of the Times #', LibString.toString(tokenId),
                        '","image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)),
                        '","animation_url":"data:text/html;base64,', htmlCode,
                        '","attributes": [', traits, ']}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    /// @notice Builds the HTML string that includes the Tone.js code and the generated script.
    function buildHTML(
        string memory tonejsCode,
        string memory script
    ) external pure returns (string memory) {
        return Base64.encode(
            abi.encodePacked(
                "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>",
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
                "<title>Sign of the Times</title>",
                "<style>* {margin: 0; padding: 0; border: 0;} body{overflow:hidden;} ",
                "#playArea{width:100%;height:100vh;display: flex;justify-content:center;align-items:center;cursor:pointer;position:relative;} ",
                ".lighted {animation-name:light;animation-duration:0.2s;animation-iteration-count:infinite;} ",
                "@keyframes light{0%{scale:1;}20%{scale:1.002;}40%{scale:1.004;}50%{scale:1.005;}60%{scale:1.004;}80%{scale:1.002;}100%{scale:1;}}</style>",
                "</head><body><canvas id='myCanvas' width='100%' height='100%'></canvas>",
                tonejsCode,
                "<script>", script, "</script></body></html>"
            )
        );
    }
    
}

