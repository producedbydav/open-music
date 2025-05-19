// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./LibString.sol";

contract beginningSVG {

    function generateSVG(string memory _text, bytes[2] memory _colors, uint[6][] memory _values) public pure returns (string memory) {
        string memory textForSVG = _text;

        string memory svgStart = "<svg id='mySVG' viewBox='0 0 600 600' preserveAspectRatio='xMidYMid meet' style='width: 100%; height: 100%;' xmlns='http://www.w3.org/2000/svg'> <rect width='100%' height='100%' fill='var(--background-color)' /> <defs> <filter id='blurFilter1'> <feGaussianBlur stdDeviation='2' /> </filter> </defs> <defs> <filter id='blurFilter2'> <feGaussianBlur stdDeviation='6' /> </filter> </defs> <defs> <filter id='blurFilter3'> <feGaussianBlur stdDeviation='12' /> </filter> </defs> <style> :root {--background-color: ";
        string memory svgEnd = "</svg>";
        string memory textElements;

        bytes memory addrBytes = bytes(textForSVG);
        bytes[2] memory colorsSVG = _colors;

        uint[6][] memory svgValues = _values;

        for (uint k = 0; k < svgValues.length; k++) {

            string memory fontSize = LibString.toString(svgValues[k][0]);
            string memory filterId = LibString.toString(svgValues[k][1]);
            string memory xPos = LibString.toString(svgValues[k][2]);
            string memory yOffset = LibString.toString(svgValues[k][0]);
            string memory fromY = LibString.toString(svgValues[k][3]);
            string memory toY = LibString.toString(svgValues[k][4]);
            string memory duration = LibString.toString(svgValues[k][5]);

            textElements = string(abi.encodePacked(
                textElements,
                "<text font-size='", fontSize,
                "' fill='", colorsSVG[1],
                "' text-anchor='start' filter='url(#blurFilter", filterId, ")'>"
            ));

            for (uint i = 0; i < addrBytes.length; i++) {
                string memory char = string(abi.encodePacked(addrBytes[i]));
                textElements = string(abi.encodePacked(
                    textElements,
                    '<tspan x="', xPos,
                    '" dy="', yOffset, '">', 
                    char, 
                    '</tspan>'
                ));
            }

            textElements = string(abi.encodePacked(
                textElements,
                "<animateTransform class='textAnimation' attributeName='transform' type='translate' from='0 -", fromY,
                "' to='0 ", toY, "' dur='", duration,
                "s' repeatCount='indefinite' fill='freeze' begin='0s'/> </text>"
            ));
        }

        bytes memory svg = abi.encodePacked(svgStart, colorsSVG[0], ";--foreground-color:", colorsSVG[1], ";}text { font-family: 'Courier New', monospace; } </style>", textElements, svgEnd);
        return string(svg);
    }

}
