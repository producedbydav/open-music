// SPDX-License-Identifier: MIT

import "./LibString.sol";

pragma solidity ^0.8.20;

contract visualizerV1 {

    function generateVisualizer(string memory _colorBg, string memory _colorFg, string memory _input1, string memory _input2, uint _size1, uint _size2) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "const ctx=canvas.getContext('2d');let sW=window.innerWidth,sH=window.innerHeight;function resizeCanvas(){let e=window.devicePixelRatio||1;canvas.width=window.innerWidth*e,canvas.height=window.innerHeight*e,canvas.style.width=window.innerWidth+'px',canvas.style.height=window.innerHeight+'px',ctx.setTransform(e,0,0,e,0,0),sW=window.innerWidth,sH=window.innerHeight}resizeCanvas(),window.addEventListener('resize',resizeCanvas);const analyser1=new Tone.Analyser('waveform',",
                LibString.toString(_size1),
                "),analyser2=new Tone.Analyser('waveform',",
                LibString.toString(_size2),
                ");ctx.fillStyle='",
                _colorBg,
                "', ctx.strokeStyle = '",
                _colorFg,
                "';function draw(){ctx.clearRect(0,0,sW,sH),ctx.fillRect(0,0,sW,sH),"
                "drawWave(analyser1,sH * 0.75,sH/1),",
                "drawWave(analyser2,sH * 0.25,sH/2),",
                "requestAnimationFrame(draw)}function drawWave(e,t,l){let n=e.getValue(),i=sW/20,o=i,a=sW-i,g=a-o;ctx.fillRect(o,t-l/2,g,l),ctx.beginPath(),ctx.lineWidth=1;for(let h=0;h<n.length;h++){let f=o+h/n.length*g,r=t-n[h]*(l/2);0===h?ctx.moveTo(f,r):ctx.lineTo(f,r)}ctx.stroke()}",
                _input1,
                ".connect(analyser1),",
                _input2,
                ".connect(analyser2),draw();"
            )
        );
    }

}
