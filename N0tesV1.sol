// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./LibString.sol";

contract n0tesV1 {

    uint8 constant NO_NOTE = 255;

    function getNotesArrayMono(
        uint8[] memory notes, 
        uint _rate, 
        string memory _duration, 
        bool _addLabel, 
        uint _partNum
    ) external pure returns (string memory) {

        require(_rate > 0, "_rate must be > 0");

        bytes memory jsonStart = _addLabel ? abi.encodePacked(" const notesPart", LibString.toString(_partNum), " = [") : bytes("[");
        bytes memory jsonEnd = "];";
        bytes memory result = jsonStart;

        // Assume a standard 4/4 bar with 16 sixteenth notes per bar
        uint16 sixteenthsPerBar = 16;
        uint16 incrementsPerBeat = sixteenthsPerBar / 4; // equals 4

        string memory durLocal = _duration;

        for (uint i = 0; i < notes.length; i++) {
            uint _noteI = notes[i];

            if (_noteI == NO_NOTE) {
                continue;
            }

            uint totalOffset = i * _rate;

            uint bar = totalOffset / sixteenthsPerBar;
            uint offsetInBar = totalOffset % sixteenthsPerBar;

            uint beat = offsetInBar / incrementsPerBeat;
            uint quarter = offsetInBar % incrementsPerBeat;

            // Convert note to string
            string memory noteLocal = LibString.toString(_noteI);
            // Set duration (for simplicity, one increment - adjust as needed)
            
            string memory timeStr = string(
                abi.encodePacked(
                    LibString.toString(bar), ":",
                    LibString.toString(beat), ":",
                    LibString.toString(quarter)
                )
            );

            bytes memory noteObj = abi.encodePacked(
                i == 0 ? "{" : ",{",
                "\"midi\":", noteLocal, ",",
                "\"duration\":\"", durLocal, "\",",
                "\"time\":\"", timeStr, "\"",
                "}"
            );

            result = abi.encodePacked(result, noteObj);
        }

        result = abi.encodePacked(result, jsonEnd);

        return string(result);
    }

    function getNotesArrayPoly(
        uint8[][] memory chords,
        uint _rate,
        string memory _duration,
        bool _addLabel,
        uint _partNum
    ) external pure returns (string memory) {
        require(_rate > 0, "_rate must be > 0");

        // Optional label (e.g., " const notesPart1 = [")
        bytes memory jsonStart = _addLabel
            ? abi.encodePacked(" const notesPart", LibString.toString(_partNum), " = [")
            : bytes("[");

        bytes memory jsonEnd = "];";
        bytes memory result = jsonStart;

        // Assume a standard 4/4 bar with 16 sixteenth notes per bar
        uint16 sixteenthsPerBar = 16;
        uint16 incrementsPerBeat = sixteenthsPerBar / 4; // equals 4

        string memory durLocal = _duration;

        bool firstNote = true; // Track if we've appended any note objects yet

        uint8[][] memory chordsTemp = chords;

        for (uint i = 0; i < chords.length; i++) {
            // Each chord starts at a new time, offset by _rate
            uint totalOffset = i * _rate;

            // Calculate bar, beat, quarter
            uint bar = totalOffset / sixteenthsPerBar;
            uint offsetInBar = totalOffset % sixteenthsPerBar;
            uint beat = offsetInBar / incrementsPerBeat;
            uint quarter = offsetInBar % incrementsPerBeat;

            // Construct the time string (e.g. "0:1:2")
            string memory timeStr = string(
                abi.encodePacked(
                    LibString.toString(bar), ":",
                    LibString.toString(beat), ":",
                    LibString.toString(quarter)
                )
            );

            // Now loop through the notes in the chord
            for (uint j = 0; j < chordsTemp[i].length; j++) {

                if (chordsTemp[i][j] == NO_NOTE) {
                    continue;
                }
                // Convert each chord note to string
                string memory noteLocal = LibString.toString(chordsTemp[i][j]);

                // Build the note object
                // Skip comma if this is the very first note overall
                bytes memory noteObj = abi.encodePacked(
                    firstNote ? "{" : ",{",
                    "\"midi\":", noteLocal, ",",
                    "\"duration\":\"", durLocal, "\",",
                    "\"time\":\"", timeStr, "\"",
                    "}"
                );

                // Append to the result
                result = abi.encodePacked(result, noteObj);
                
                // After the first note, we always prepend commas
                if (firstNote) {
                    firstNote = false;
                }
            }
        }

        // Close the array
        result = abi.encodePacked(result, jsonEnd);

        return string(result);
    }

}
