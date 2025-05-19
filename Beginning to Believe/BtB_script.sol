// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./ILens.sol";

interface IBeginningRenderer {
    function generateSVG(string memory _text, bytes[2] memory _colors) external view returns (string memory);
    function lenses(uint) external view returns (ILens);
    function currentLens() external view returns (uint);
}

interface IN0tesV1 {
    function getNotesArrayMono(
        uint8[] memory notes,
        uint _rate, 
        string memory _duration, 
        bool _addLabel, 
        uint _partNum
    ) external pure returns (string memory);

    function getNotesArrayPoly(
        uint8[][] memory chords,
        uint _rate,
        string memory _duration,
        bool _addLabel,
        uint _partNum
    ) external pure returns (string memory);
}

contract beginningJS {

    IBeginningRenderer public mainRenderer;
    IT0neV1 public t0neV1;
    IN0tesV1 public n0tesV1;

    uint[] _playerCode1Type;
    uint[] _playerCode2Type;
    uint[] _playerCode3Type;

    uint[] _playerCodeLabel1;    //BASS
    uint[] _playerCodeLabel2;    //MELODY 1
    uint[] _playerCodeLabel3;    //MELODY 2
    uint[] _playerCodeLabel5;    //MELODY 3
    uint[] _playerCodeLabel6;    //MELODY 4
    uint[] _playerCodeLabel7;    //CHORDS

    constructor ()
    {
        t0neV1 = IT0neV1(0xc36BF4cD8a38d6De43546040dd3AE02252722092);
        n0tesV1 = IN0tesV1(0x3eb4D09e51E2A40d1a5a3EC5f98AA7dffa426577);
        mainRenderer = IBeginningRenderer(0x2b3cEa2Ca287AF18C291eB40d5B8A0Db0cc2e2fd);

        
        _playerCode1Type.push(0);                        //monosynth
        _playerCode1Type.push(0);                        //monosynth
        _playerCode2Type.push(1);                        //polysynth
        _playerCode2Type.push(1);                        //polysynth
        _playerCode3Type.push(0);                        //monosynth

        _playerCodeLabel1.push(1);
        _playerCodeLabel1.push(2);
        _playerCodeLabel2.push(3);
        _playerCodeLabel2.push(4);
        _playerCodeLabel3.push(5);
        _playerCodeLabel3.push(6);
        _playerCodeLabel5.push(8);
        _playerCodeLabel6.push(9);
        _playerCodeLabel7.push(1);
        _playerCodeLabel7.push(2);
    }

    function generateScript() public view returns (string memory) {

        return string(abi.encodePacked(
            "const canvas = document.getElementById('mySVG');const animations = canvas.querySelectorAll('.textAnimation');animations.forEach(anim => anim.setAttribute('begin', 'indefinite'));canvas.pauseAnimations();",
            generateNotes(),
            generateSynths(),
            generateSignalChains(),
            generateLFOs(),
            "lfo1.connect(monoSynth3.detune);lfo1.connect(monoSynth5.detune);lfo2.connect(monoSynth1.filter.frequency);lfo3.connect(monoSynth8.filter.frequency);lfo3.connect(monoSynth9.filter.frequency);",
            generatePlayers(),
            t0neV1.generateFooterCode("startSVGAnimation();canvas.unpauseAnimations();", "stopSVGAnimation();"),
            "function startSVGAnimation() {animations.forEach(animation => {animation.beginElement();});} function stopSVGAnimation() {animations.forEach(animation => {animation.endElement();});}"
        ));
    }

    function getCurrentLens() private view returns (ILens) {
        return mainRenderer.lenses(mainRenderer.currentLens());
    }

    function generateNotes() public view returns (string memory) {

        ILens lens = getCurrentLens();

        uint8[] memory notesBassTemp = new uint8[](4);
        for (uint i = 0; i < 4; i++) {
            notesBassTemp[i] = lens.notesBass()[i];
        }
        uint8[] memory notesMel1Temp = new uint8[](8);
        for (uint i = 0; i < 8; i++) {
            notesMel1Temp[i] = lens.notesMelody1()[i];
        }
        uint8[] memory notesMel2Temp = new uint8[](32);
        for (uint i = 0; i < 32; i++) {
            notesMel2Temp[i] = lens.notesMelody2()[i];
        }
        uint8[] memory notesMel3Temp = new uint8[](32);
        for (uint i = 0; i < 32; i++) {
            notesMel3Temp[i] = lens.notesMelody3()[i];
        }
        uint8[] memory notesMel4Temp = new uint8[](32);
        for (uint i = 0; i < 32; i++) {
            notesMel4Temp[i] = lens.notesMelody4()[i];
        }

        uint8[][] memory chords = new uint8[][](4); // Outer array of length 4

        for (uint i = 0; i < 4; i++) {
            chords[i] = new uint8[](3); // Allocate an inner array of length 3

            for (uint j = 0; j < 3; j++) {
                chords[i][j] = lens.notesChord()[i][j];
            }
        }

        return string(abi.encodePacked(
            n0tesV1.getNotesArrayMono(notesBassTemp,32, "2:0:0", true,1),
            n0tesV1.getNotesArrayMono(notesMel1Temp,16, "1:0:0", true,2),
            n0tesV1.getNotesArrayMono(notesMel2Temp,4, "0:1:0", true,3),
            n0tesV1.getNotesArrayMono(notesMel3Temp,4, "0:1:0", true,4),
            n0tesV1.getNotesArrayMono(notesMel4Temp,4, "0:1:0", true,5),
            n0tesV1.getNotesArrayPoly(chords,32, "2:0:0", true,6)
        ));
    }

    function generateSynths() public view returns (string memory) {
        
        ILens lens = getCurrentLens();

        return string(abi.encodePacked(
            t0neV1.createMonoSynth(1, lens.paramsBass()[0]),            //bass osc1
            t0neV1.createMonoSynth(2, lens.paramsBass()[1]),            //bass osc2
            t0neV1.createMonoSynth(3, lens.paramsMelody1()[0]),         //mel1 osc1
            t0neV1.createMonoSynth(4, lens.paramsMelody1()[1]),         //mel1 osc2
            t0neV1.createMonoSynth(5, lens.paramsMelody2()[0]),         //mel2 osc1
            t0neV1.createMonoSynth(6, lens.paramsMelody2()[1]),         //mel2 osc2
            t0neV1.createMonoSynth(7, lens.paramsArp()),                //chaos arp
            t0neV1.createMonoSynth(8, lens.paramsMelody3()),            //mel3
            t0neV1.createMonoSynth(9, lens.paramsMelody4()),            //mel4
            t0neV1.createDetunedPolySynth(1, true, lens.paramsChord()), //chords
            t0neV1.createDetunedPolySynth(2, false, lens.paramsChord()) //chords
        ));
    }
        
    function generateSignalChains() public view returns (string memory) {

        ILens lens = getCurrentLens();

        return string(abi.encodePacked(
            t0neV1.createSignalChain(lens.signalChainMelody1(), 1, 0, 3),   //fx index start, synth type, synth index
            "monoSynth4.connect(effect1);",
            t0neV1.createSignalChain(lens.signalChainMelody2(), 5, 0, 5),
            "monoSynth6.connect(effect5);",
            t0neV1.createSignalChain(lens.signalChainMelody3(), 7, 0, 8),
            t0neV1.createSignalChain(lens.signalChainMelody4(), 8, 0, 9),
            t0neV1.createSignalChain(lens.signalChainArp(), 9, 0, 7),
            t0neV1.createSignalChain(lens.signalChainChords1(), 10, 1, 1),
            t0neV1.createSignalChain(lens.signalChainChords2(), 12, 1, 2),
            t0neV1.createSignalChain(lens.signalChainBass(), 14, 0, 1),
            "monoSynth2.connect(effect14);"
        ));
    }

    function generateLFOs() public view returns (string memory) {

        ILens lens = getCurrentLens();

        return string(abi.encodePacked(
            t0neV1.generateLFO(1, lens.paramsLFO()[0]),
            t0neV1.generateLFO(2, lens.paramsLFO()[1]),
            t0neV1.generateLFO(3, lens.paramsLFO()[2])
        ));
    }

    function generatePlayers() public view returns (string memory) {

        bytes memory p1 =  abi.encodePacked(
            t0neV1.generatePlayerCode(1, _playerCode1Type, _playerCodeLabel1, 0, 8, true),      //BASS
            t0neV1.generatePlayerCode(2, _playerCode1Type, _playerCodeLabel2, 0, 8, true),      //MELODY 1
            t0neV1.generatePlayerCode(3, _playerCode1Type, _playerCodeLabel3, 8, 24, true),     //MELODY 2
            t0neV1.generatePlayerCode(4, _playerCode3Type, _playerCodeLabel5, 16, 32, true),    //MELODY 3
            t0neV1.generatePlayerCode(5, _playerCode3Type, _playerCodeLabel6, 48, 48, true)     //MELODY 4
        );

        bytes memory p2 =  abi.encodePacked(
            t0neV1.generatePlayerCode(6, _playerCode2Type, _playerCodeLabel7, 0, 8, true),
            generateChaosArp()
        );

        return string(abi.encodePacked(p1, p2));
    }

    function generateChaosArp() internal view returns (bytes memory) {
        ILens lens = getCurrentLens();
        uint8[3][4] memory arpNotesTemp = lens.notesArp();
        return t0neV1.generateChaosArp(0,7, arpNotesTemp, 4, 32, 63, 2);
    }

    bool t0neLocked;

    function setT0neContract(address _t0ne) public {
        require (msg.sender == 0xCB7504C4cb986E80AB4983b44263381F21273482, "Not authorized");
        require (!t0neLocked, "Locked");
        t0neV1 = IT0neV1(_t0ne);
    }

    function lockT0ne() public {
        require (msg.sender == 0xCB7504C4cb986E80AB4983b44263381F21273482, "Not authorized");
        t0neLocked = true;
    }

}
