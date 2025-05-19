// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base64.sol";
import "./IT0nev1.sol";
import "./ILens.sol";

interface IBeginningRenderer {
    function generateSVG(string memory _text, bytes[2] memory _colors) external view returns (string memory);
    function lenses(uint) external view returns (ILens);
    function currentLens() external view returns (uint);
    function getTonejs() external view returns (string memory);
}

interface IN0tesV1 {
    function getNotesArrayMono(
        uint8[] memory notes,
        uint _rate,
        string memory _duration,
        bool _addLabel, 
        uint _partNum
    ) external pure returns (string memory);
}

interface ISignRenderer {
    struct freezeStruct {
        bool isFrozen;
        uint8[32] melody;
        uint8[4] bass;
        bytes[2] colors;
        address visual;
        uint freezeBlock;
        string lensName;
    }
    function freezeData(uint _tokenId) external view returns (freezeStruct memory);
    function getFreezeData(uint _tokenId) external view returns (freezeStruct memory);
}
contract sign_script {

    uint[] _playerCode1Type;
    uint[] public _playerCodeLabel1;    // BASS
    uint[] public _playerCodeLabel2;    // MELODY 1
    IT0neV1 public immutable t0neV1;
    IN0tesV1 public immutable n0tesV1;
    ISignRenderer public immutable signRenderer;

    IBeginningRenderer public immutable btbRenderer;
    ILens public initLens;

    constructor () {

        t0neV1  = IT0neV1 (0xC7C69be443404aa8CA9889914231e06d5631D32e);
        n0tesV1 = IN0tesV1(0x2bbE3DFc621Bb068d912f824de090fd47A5BaE1C);
        signRenderer = ISignRenderer(0x77D4Bf87e885FaEd31207C1dfBA739edCfcDd6c4);
        btbRenderer = IBeginningRenderer(0x6B7E07cE896c7DFfDC936BAe8060A0F7fF71A3b2);
        initLens = ILens(0x57c8D600F80AA5334437c71848efD509C09290e9);
        
        _playerCode1Type.push(0);  // monosynth
        _playerCode1Type.push(0);

        _playerCodeLabel1.push(1);
        _playerCodeLabel1.push(2);
        _playerCodeLabel2.push(3);
        _playerCodeLabel2.push(4);
    }

    function buildScript(
        string memory notes,
        string memory synths,
        string memory signalChains,
        string memory lfos,
        string memory players,
        string memory footer,
        string memory visualizer
    ) external pure returns (string memory) {
         return string(abi.encodePacked(
            "const canvas = document.getElementById('myCanvas');",
            notes,
            synths,
            signalChains,
            lfos,
            "lfo1.connect(monoSynth3.detune);lfo2.connect(monoSynth1.filter.frequency);",
            "const pitchEnv1=new Tone.Envelope({attack:.001,decay:.2,sustain:0,release:.1}),",
            "pitchEnv1Scale=new Tone.Multiply(1e3);",
            "pitchEnv1.connect(pitchEnv1Scale),",
            "pitchEnv1Scale.connect(monoSynth1.detune);",
            players,
            "let pitchEnvSeq=new Tone.Part(function(t,e){new Tone.Midi(e.midi).toNote(),",
            "pitchEnv1.triggerAttackRelease(e.duration,t)},notesPart1).start('0m');",
            "pitchEnvSeq.loopEnd='4m',pitchEnvSeq.loop=true;",
            footer,
            visualizer
         ));
    }

    function getCurrentLens() private view returns (ILens) {
        return btbRenderer.lenses(btbRenderer.currentLens());
    }

    function translateBass(uint _tokenId) public view returns (uint8[128] memory) {
        ILens lens = getCurrentLens();
        ISignRenderer.freezeStruct memory tempData = signRenderer.getFreezeData(_tokenId);
        uint8[4] memory notes = tempData.isFrozen ? tempData.bass : lens.notesBass();
        uint8 b1 = notes[0];
        uint8 b2 = notes[1];
        uint8 b3 = notes[2];
        uint8 b4 = notes[3];

        uint8 x = 255;
        return [
            b1,x,x,b1,x,x,b1,x,x,b1,x,x,b2,x,x,b2,x,x,b2,x,x,b3,x,x,x,x,x,x,(b3 + 24),(b3 + 19),(b3 + 12),(b3 + 7),
            b3,x,x,b3,x,x,b3,x,x,b4,x,x,b4,x,x,b4,x,x,b4,x,x,b4,x,x,x,x,x,x,x,x,(b4 + 36),x,
            b1,x,x,b1,x,x,b1,x,x,b1,x,x,b2,x,x,b2,x,x,b2,x,x,b3,x,x,x,x,x,x,(b3),(b3),x,(b3 + 36),
            b3,x,x,b3,x,x,b3,x,x,b4,x,x,b4,x,x,b4,x,x,b4,x,x,b4,x,x,x,x,x,b4,(b4 + 36),x,(b4 + 24),x
        ];
    }

    function translateMelody(uint _tokenId) public view returns (uint8[8] memory) {
        ILens lens = getCurrentLens();
        ISignRenderer.freezeStruct memory tempData = signRenderer.getFreezeData(_tokenId);
        uint8[32] memory notes = tempData.isFrozen ? tempData.melody : lens.notesMelody2();
        uint8 x = 255;
        return [x, notes[4], x, notes[11], x, notes[21], x, notes[27]];
    }

    //-----------------------------------------------------------------------------
    //------------- Get / modify synth & FX params from Init Lens -----------------
    //-----------------------------------------------------------------------------

    function translateBassSynths() public view returns (uint256[18][2] memory) {
        uint256[18][2] memory paramTemp = initLens.paramsBass();
        paramTemp[0][0] -= 6;
        paramTemp[1][0] -= 6;
        paramTemp[0][2] -= 3;
        paramTemp[0][5] -= 999;
        paramTemp[1][5] -= 999;
        paramTemp[0][6] += 500;
        paramTemp[1][6] += 500;
        paramTemp[0][12] -= 999;
        paramTemp[1][12] -= 999;
        paramTemp[0][13] += 700;
        paramTemp[1][13] += 700;
        paramTemp[0][14] += 900;
        paramTemp[1][14] -= 95;
        return paramTemp;
    }

    function translateBassFx() public view returns (IT0neV1.Effect[] memory) {
        IT0neV1.Effect[] memory fxTemp = initLens.signalChainBass();
        fxTemp[0].params[0] += 880;
        fxTemp[0].params[1] += 2;
        fxTemp[0].params[2] += 85;
        return fxTemp;
    }

    function translateMel1Fx() public view returns (IT0neV1.Effect[] memory) {
        IT0neV1.Effect[] memory fxTemp = initLens.signalChainMelody1();
        fxTemp[0].params[0] += 200;
        fxTemp[2].params[2] -= 20;
        fxTemp[3].params[0] += 300;
        return fxTemp;
    }

    function generateNotes(uint _tokenId) public view returns (string memory) {
        uint8[128] memory bassNotes = translateBass(_tokenId);
        uint8[8] memory melNotes = translateMelody(_tokenId);

        uint8[] memory notesBassTemp = new uint8[](bassNotes.length);
        for (uint i = 0; i < bassNotes.length; i++) {
            notesBassTemp[i] = bassNotes[i];
        }
        uint8[] memory notesMel1Temp = new uint8[](melNotes.length);
        for (uint i = 0; i < melNotes.length; i++) {
            notesMel1Temp[i] = melNotes[i];
        }

        return string(abi.encodePacked(
            n0tesV1.getNotesArrayMono(notesBassTemp, 1, "0:0:2", true, 1),
            n0tesV1.getNotesArrayMono(notesMel1Temp, 8, "0:0:2", true, 2)
        ));
    }

    function generateSynths() public view returns (string memory) {
        ILens lens = getCurrentLens();
        uint256[18][2] memory bassSynths = translateBassSynths();
        return string(abi.encodePacked( 
            t0neV1.createMonoSynth(1, bassSynths[0]),
            t0neV1.createMonoSynth(2, bassSynths[1]),
            t0neV1.createMonoSynth(3, lens.paramsMelody1()[0]),
            t0neV1.createMonoSynth(4, lens.paramsMelody1()[1])
        ));
    }

    function generateSignalChains() public view returns (string memory) {
        return string(abi.encodePacked(
            t0neV1.createSignalChain(translateMel1Fx(), 1, 0, 3),
            "monoSynth4.connect(effect1);",
            t0neV1.createSignalChain(translateBassFx(), 14, 0, 1),
            "monoSynth2.connect(effect14);"
        ));
    } 

    function generateLFOs() public view returns (string memory) {
        ILens lens = getCurrentLens();
        return string(abi.encodePacked(
            t0neV1.generateLFO(1, lens.paramsLFO()[0]),
            t0neV1.generateLFO(2, lens.paramsLFO()[1])
        ));
    }

    function generatePlayers() public view returns (string memory) {
        bytes memory p1 = abi.encodePacked(
            t0neV1.generatePlayerCode(1, _playerCode1Type, _playerCodeLabel1, 0, 8, true),
            t0neV1.generatePlayerCode(2, _playerCode1Type, _playerCodeLabel2, 0, 4, true)
        );
        return string(p1);
    }

}
