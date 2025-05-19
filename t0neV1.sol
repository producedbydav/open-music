// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./LibString.sol";

contract t0neV1 {

    bytes constant oscType = "type: ['sine', 'square', 'triangle', 'sawtooth'][";
    string[] synthsType = ["monoSynth","detunedPolySynth"];

    function createDetunedPolySynth(uint _index, bool _declare, uint256[11] memory _params) external pure returns (bytes memory) {
        bytes memory declareVals = abi.encodePacked(
            "class DetunedSynth extends Tone.Synth {constructor(options) {super(options);this.detune.value += DetunedSynth.detuneValues[DetunedSynth.voiceIndex % DetunedSynth.detuneValues.length];DetunedSynth.voiceIndex++;}}",
            "DetunedSynth.detuneValues = [-",
            LibString.toString(_params[8]),
            ",",
            LibString.toString(_params[9]),
            ",",
            LibString.toString(_params[10]),
            "];DetunedSynth.voiceIndex = 0;"
        );
        bytes memory declaring = _declare ? declareVals : new bytes(0);
        return abi.encodePacked(
            declaring,
            "const detunedPolySynth",
            LibString.toString(_index),
            " = new Tone.PolySynth(DetunedSynth, {",
                "maxPolyphony: ", LibString.toString(_params[0]), ",",
                "volume: -", LibString.toString(_params[1]), ",",
                "oscillator:{", oscType, LibString.toString(_params[2]), "]}, ",
                "voices: ", LibString.toString(_params[3]), ",",
                "envelope: {",
                getEnvelope([_params[4],_params[5],_params[6],_params[7]]),
                "},});"
        );
    }

    function createMonoSynth(uint _index, uint256[18] memory _params) external pure returns (bytes memory) {
        bytes memory p1 = abi.encodePacked(
                "const monoSynth",
                LibString.toString(_index),
                "=new Tone.MonoSynth({",
                "volume: -", LibString.toString(_params[0]), ",",
                "detune:", LibString.toString(_params[1]), ",",
                "oscillator:{", oscType, LibString.toString(_params[2]), "]}, ",
            "envelope: {",
                getEnvelope([_params[3],_params[4],_params[5],_params[6]]),
            "},"
        );

        bytes memory p2 = abi.encodePacked(
            "filter : {",
                "Q: ", LibString.toString(_params[7]), ",",
                "type: ['lowpass','highpass','bandpass','lowshelf','highshelf','notch','allpass','peaking'][", LibString.toString(_params[8]), "],",
                "rolloff: -(12 * 2**", LibString.toString(_params[9]), ")",
            "},"
            "filterEnvelope : {",
                "baseFrequency: ", LibString.toString(_params[14]), ",",
                "octaves: ", LibString.toString(_params[15]), ",",
                "exponent: ", LibString.toString(_params[16]), ",",
                getEnvelope([_params[10],_params[11],_params[12],_params[13]]),
            "}",
            ",portamento:", LibString.toString(_params[17]), " / 100",
            "});"
        );

        return abi.encodePacked(p1, p2);
    }

    function generateLFO(uint _index, uint256[5] memory _params) external pure returns (bytes memory) {
        return abi.encodePacked(
            "const lfo", LibString.toString(_index), "=new Tone.LFO({",
                "frequency:`${", LibString.toString(_params[0]), "/100}hz`,",
                "min:-", LibString.toString(_params[1]), ",",
                "max:", LibString.toString(_params[2]), ",",
                "amplitude: ", LibString.toString(_params[3]), "/100,",
                oscType, LibString.toString(_params[4]), "]});lfo", LibString.toString(_index), ".start();"
        );
    }

    function uintNestedToString(uint8[3][4] memory _array) public pure returns (string memory) {
        bytes memory result = "[";

        for (uint i = 0; i < _array.length; i++) {
            result = abi.encodePacked(result, "[");
            for (uint j = 0; j < _array[i].length; j++) {
                result = abi.encodePacked(result, LibString.toString(_array[i][j]));
                if (j < _array[i].length - 1) {
                    result = abi.encodePacked(result, ",");
                }
            }
            result = abi.encodePacked(result, "]");
            if (i < _array.length - 1) {
                result = abi.encodePacked(result, ",");
            }
        }

        result = abi.encodePacked(result, "]");
        return string(result);
    }


    function generateChaosArp(uint _synthType, uint _synthIndex, uint8[3][4] memory _notes, uint _octaveCount, uint _noteDuration, uint _noteInterval, uint _chordDuration) public view returns (bytes memory){
        return abi.encodePacked(
            "let chords=",
            uintNestedToString(_notes),
            ",a=c=>{c=c.slice().sort((x,y)=>x-y);let r=[];for(let j=0;j<",
            LibString.toString(_octaveCount),
            ";j++)for(let e of c)r.push(e+12*j);return r},i=0,n=0,C=a(chords[i]);new Tone.Loop(t=>{",
            synthsType[_synthType], LibString.toString(_synthIndex),
            ".triggerAttackRelease(Tone.Frequency(C[n],'midi').toNote(),'",
            LibString.toString(_noteDuration),
            "n',t);if(++n>=C.length)n=0},(",
            LibString.toString(_noteInterval),
            " / 1000)).start(0);Tone.Transport.scheduleRepeat(()=>{i=(i+1)%chords.length;C=a(chords[i]);n=0},'",
            LibString.toString(_chordDuration),
            "m');"
        );
    }

    struct Effect {
        uint8 id; 
        uint256[] params; 
    }

    function createSignalChain(Effect[] memory effects, uint _startingIndex, uint _synthType, uint _synthLabel) external view returns (bytes memory) {
        bytes memory code = abi.encodePacked(
            generateEffectsCode(effects, _startingIndex),
            getSynthName(_synthType, _synthLabel),
            generateChainCode(effects, _startingIndex)
        );

        return code;
    }

    function generateEffectsCode(Effect[] memory effects, uint _startingIndex) public pure returns (bytes memory) {
        bytes memory code;

        for (uint i = 0; i < effects.length; i++) {
            code = abi.encodePacked(
                code,
                generateEffectCode(effects[i], i + _startingIndex)
            );
        }

        return code;
    }


    function generateEffectCode(Effect memory effect, uint _index) public pure returns (bytes memory) {
    
        if (effect.id == 0) {
            // Distortion
            uint[3] memory temp;
            for (uint i = 0; i < 3; i++) {
                temp[i] = effect.params[i];
            }
            return generateDistortionCode(temp, _index);
        } else if (effect.id == 1) {
            // Phaser
            uint[4] memory temp;
            for (uint i = 0; i < 4; i++) {
                temp[i] = effect.params[i];
            }
            return generatePhaserCode(temp, _index);
        } else if (effect.id == 2) {
            // Delay
            uint[3] memory temp;
            for (uint i = 0; i < 3; i++) {
                temp[i] = effect.params[i];
            }
            return generateDelayCode(temp, _index);
        } else if (effect.id == 3) {
            // Reverb
            uint[3] memory temp;
            for (uint i = 0; i < 3; i++) {
                temp[i] = effect.params[i];
            }
            return generateReverbCode(temp, _index);
        } else if (effect.id == 4) {
            // Filter
            uint[5] memory temp;
            for (uint i = 0; i < 5; i++) {
                temp[i] = effect.params[i];
            }
            return generateFilterCode(temp, _index);
        } else if (effect.id == 5) {
            // Panner
            uint[1] memory temp;
            for (uint i = 0; i < 1; i++) {
                temp[i] = effect.params[i];
            }
            return generatePannerCode(temp, _index);
        } else {return "";}
    }

    function generateChainCode(Effect[] memory effects, uint _startingIndex) public pure returns (bytes memory) {
        bytes memory chainCode = ".chain(";
        for (uint i = 0; i < effects.length; i++) {
            if (i > 0) {
                chainCode = abi.encodePacked(chainCode, ", ");
            }
            chainCode = abi.encodePacked(chainCode, "effect", LibString.toString(i + _startingIndex));
        }
        chainCode = abi.encodePacked(chainCode, ",Tone.Destination);");
        return chainCode;
    }

    function generatePhaserCode(uint256[4] memory params, uint _index) public pure returns (bytes memory) {
        return abi.encodePacked(
            "const effect", LibString.toString(_index), " = new Tone.Phaser({",
                "frequency: ", LibString.toString(params[0]), " / 1000,",
                "octaves:", LibString.toString(params[1]), ",",
                "baseFrequency:", LibString.toString(params[2]), ",",
                "wet:", LibString.toString(params[3]), " / 100",
            "});"
        );
    }

    function generateDelayCode(uint256[3] memory params, uint _index) public pure returns (bytes memory) {
        return abi.encodePacked(
            "const effect", LibString.toString(_index), " = new Tone.FeedbackDelay({",
                "delayTime: ", LibString.toString(params[0]), ",",
                "feedback:", LibString.toString(params[1]), "/100,",
                "wet:", LibString.toString(params[2]), "/100",
            "});"
        );
    }

    function generateReverbCode(uint256[3] memory params, uint _index) public pure returns (bytes memory) {
        return abi.encodePacked(
            "const effect", LibString.toString(_index), "=new Tone.Reverb({",
                "decay:", LibString.toString(params[0]), "/100,",
                "predelay:", LibString.toString(params[1]), "/100,",
                "wet:", LibString.toString(params[2]), "/100",
            "});"
        );
    }

    function generateDistortionCode(uint256[3] memory params, uint _index) public pure returns (bytes memory) {
        string memory overSample = ['none', '2x', '4x'][params[1]];
        return abi.encodePacked(
            "const effect", LibString.toString(_index), " = new Tone.Distortion({",
                "distortion:", LibString.toString(params[0]), "/1000,",
                "oversample:'", overSample, "',",
                "wet:", LibString.toString(params[2]), "/100",
            "});"
        );
    }

    function generatePannerCode(uint256[1] memory params, uint _index) public pure returns (bytes memory) {
        return abi.encodePacked(
            "const effect", LibString.toString(_index), " = new Tone.Panner(-1 + (",
            LibString.toString(params[0]),
            " / 1000));"
        );
    }

    function generateFilterCode(uint256[5] memory params, uint _index) public pure returns (bytes memory) {
        return abi.encodePacked(
            "const effect", LibString.toString(_index), " = new Tone.Filter({",
                "type: ['lowpass', 'highpass', 'bandpass', 'lowshelf', 'highshelf', 'notch', 'allpass', 'peaking'][", LibString.toString(params[0]), "],",
                "frequency: ", LibString.toString(params[1]), ",",
                "rolloff: -(12 * 2**", LibString.toString(params[2]), "),",
                "Q: (", LibString.toString(params[3]), " / 100),",
                "gain:(", LibString.toString(params[4]), " / 100)",
            "});"
        );
    }

    function generatePlayerCode(uint _partNum , uint[] memory _synthType, uint[] memory _synthLabels, uint8 startTime, uint8 loopTime, bool _loop) external view returns (bytes memory) {

        bytes memory synthsLoop;
        bytes memory loop = _loop ? abi.encodePacked("notesPart", LibString.toString(_partNum), "Sequence.loop = true;") : new bytes(0);

        for (uint i = 0; i < _synthType.length; i++) {
            // Concatenate the new string using abi.encodePacked
            synthsLoop = abi.encodePacked(synthsLoop, synthsType[_synthType[i]], LibString.toString(_synthLabels[i]), ".triggerAttackRelease(note, event.duration, time);");
        }

        return abi.encodePacked(
                "let notesPart", LibString.toString(_partNum), "Sequence = new Tone.Part(function(time, event){let note = new Tone.Midi(event.midi).toNote();",
                synthsLoop,
                "}, notesPart",
                LibString.toString(_partNum),
                ").start('",
                LibString.toString(startTime),
                "m'); notesPart",
                LibString.toString(_partNum), 
                "Sequence.loopEnd = '",
                LibString.toString(loopTime),
                "m';",
                loop
        );
    }

    function generateFooterCode(string memory xtraCodeStart, string memory xtraCodeStop) external pure returns (bytes memory) {

        return abi.encodePacked(
            "let isPlaying = false;",
            "canvas.addEventListener('click', function(event) {if (!isPlaying) {Tone.start().then(() => {Tone.Transport.start(); isPlaying = true;",
            xtraCodeStart,
            "}); } else {Tone.Transport.stop(); isPlaying = false; Tone.Transport.position = 0;",
            xtraCodeStop,
            "}event.preventDefault(); });"

        );

    }

    function getSynthName(uint _type, uint _label) public view returns (bytes memory) {
        return abi.encodePacked(synthsType[_type], LibString.toString(_label));
    }

    function getEnvelope (uint[4] memory _envParams) public pure returns (bytes memory) {
        return abi.encodePacked(
            "attack:(", LibString.toString(_envParams[0]), "/1000),",
            "decay:(", LibString.toString(_envParams[1]), "/1000),",
            "sustain:(", LibString.toString(_envParams[2]), "/1000),",
            "release:(", LibString.toString(_envParams[3]),  "/1000)"
        );
    }

}
