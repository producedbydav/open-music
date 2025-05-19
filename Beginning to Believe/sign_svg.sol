// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library signSVGLib {
        
    function generateSVG(string memory _bgColor, string memory _fgColor, string memory _block) public pure returns (string memory) {

        string memory svgReturn = string(abi.encodePacked(
            "<svg width='600' height='600' xmlns='http://www.w3.org/2000/svg'><animate attributeName='viewBox' values='0 0 600 600; 100 100 400 400; ",
            "0 0 100 100;0 0 600 600; 140 140 400 400; 40 40 100 100' keyTimes='0;0.47;0.5;0.53;0.95;0.97' dur='2s' repeatCount='indefinite' ",
            "calcMode='discrete' /><defs><filter id='a'><feTurbulence type='fractalNoise' baseFrequency='.8' ",
            "numOctaves='4' result='noise'/><feColorMatrix in='noise' type='saturate' values='0' result='grayscale'/><feComponentTransfer in='grayscale' ",
            "result='contrast'><feFuncR type='linear' slope='6' intercept='-2.5'/><feFuncG type='linear' slope='4' intercept='-2.5'/><feFuncB type='linear' ",
            "slope='5' intercept='-2.5'/></feComponentTransfer><feDisplacementMap in='SourceGraphic' in2='contrast' scale='20' xChannelSelector='R' ",
            "yChannelSelector='G'/><feGaussianBlur in='halftone' stdDeviation='1' result='blurred'/></filter><filter id='b'><feTurbulence type='fractalNoise' baseFrequency='.8' numOctaves='4' result='noise'/><feColorMatrix in='noise' type='saturate' values='0' result='grayscale'/><feComponentTransfer in='grayscale' result='contrast'><feFuncR type='linear' slope='7' intercept='-2.5'/><feFuncG type='linear' slope='1' intercept='-2.2'/><feFuncB type='linear' slope='5' intercept='-2.5'/></feComponentTransfer><feDisplacementMap in='SourceGraphic' in2='contrast' scale='20' xChannelSelector='R' yChannelSelector='G'/><feGaussianBlur in='halftone' stdDeviation='1.7' result='blurred'/></filter></defs><path fill='",
            _bgColor,
            "' d='M0 0h600v600H0z'/>",
            "<text x='50%' y='50%' text-anchor='middle' fill='",
            _fgColor,
            "' font-size='80' font-family='monospace' filter='url(#a)'><tspan x='50%' dy='-.3em'>",
            "Sign of</tspan><tspan x='50%' dy='1em'>the Times</tspan></text><text x='50%' y='85%' text-anchor='middle' fill='",
            _fgColor,
            "' font-size='28' font-family='sans-serif'  filter='url(#b)'>",
            _block,
            "</text></svg>"
            )
        );
        return svgReturn;
    }

}
