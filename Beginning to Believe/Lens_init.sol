// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LibString.sol";
import "./ILens.sol";


interface IERC721 {
    function ownerOf(uint tokenId) external view returns (address);
}

contract lens_init is ILens{

    IERC721 tokenContract = IERC721(0xb314BEC0F3c247c694f0F0F5d972d9D7c307C5b7);

    IT0neV1.Effect[] chain1;
    IT0neV1.Effect[] chain2;
    IT0neV1.Effect[] chain3;
    IT0neV1.Effect[] chain4;
    IT0neV1.Effect[] chain5;
    IT0neV1.Effect[] chain6;
    IT0neV1.Effect[] chain7;
    IT0neV1.Effect[] chain8;

    uint[6][] values;

    constructor () {

        chain1.push(IT0neV1.Effect({id:0, params: new uint256[](3)}));  //melody 1
        chain1[0].params[0] = 460;
        chain1[0].params[1] = 0;
        chain1[0].params[2] = 28;
        chain1.push(IT0neV1.Effect({id:1, params: new uint256[](4)}));
        chain1[1].params[0] = 100;
        chain1[1].params[1] = 2;
        chain1[1].params[2] = 500;
        chain1[1].params[3] = 50;
        chain1.push(IT0neV1.Effect({id:2, params: new uint256[](3)}));
        chain1[2].params[0] = 100;
        chain1[2].params[1] = 2;
        chain1[2].params[2] = 20;
        chain1.push(IT0neV1.Effect({id:3, params: new uint256[](3)}));
        chain1[3].params[0] = 300;
        chain1[3].params[1] = 10;
        chain1[3].params[2] = 30;

        chain2.push(IT0neV1.Effect({id:0, params: new uint256[](3)}));  //melody 2 - distortion and delay
        chain2[0].params[0] = 120;
        chain2[0].params[1] = 0;
        chain2[0].params[2] = 22;
        chain2.push(IT0neV1.Effect({id:2, params: new uint256[](3)}));
        chain2[1].params[0] = 63;
        chain2[1].params[1] = 2;
        chain2[1].params[2] = 10;

        chain3.push(IT0neV1.Effect({id:5, params: new uint256[](1)}));  //melody3 - pan
        chain3[0].params[0] = 350;

        chain4.push(IT0neV1.Effect({id:5, params: new uint256[](1)}));  //melody4 - pan
        chain4[0].params[0] = 1650;

        chain5.push(IT0neV1.Effect({id:4, params: new uint256[](5)}));  //chords1 - filter and pan
        chain5[0].params[0] = 0;
        chain5[0].params[1] = 800;
        chain5[0].params[2] = 0;
        chain5[0].params[3] = 50;
        chain5[0].params[4] = 1;
        chain5.push(IT0neV1.Effect({id:5, params: new uint256[](1)}));
        chain5[1].params[0] = 200;

        chain6.push(IT0neV1.Effect({id:4, params: new uint256[](5)}));  //chords2 - filter and pan
        chain6[0].params[0] = 0;
        chain6[0].params[1] = 1800;
        chain6[0].params[2] = 0;
        chain6[0].params[3] = 50;
        chain6[0].params[4] = 1;
        chain6.push(IT0neV1.Effect({id:5, params: new uint256[](1)}));
        chain6[1].params[0] = 1800;

        chain7.push(IT0neV1.Effect({id:5, params: new uint256[](1)}));  //arp - pan
        chain7[0].params[0] = 1000;

        chain8.push(IT0neV1.Effect({id:0, params: new uint256[](3)}));  //bass - distortion
        chain8[0].params[0] = 120;
        chain8[0].params[1] = 0;
        chain8[0].params[2] = 15;

        //[font size, blur filter, x, start y, end y, time] for each column of text
        values.push([8,1,10,2800,1300,8]);
        values.push([10,1,75,1800,620,6]);
        values.push([156,2,100,8800,900,6]);
        values.push([8,3,175,3200,300,5]);
        values.push([34,1,200,2500,2700,8]);
        values.push([20,1,250,1800,850,4]);
        values.push([8,3,260,2800,600,5]);
        values.push([12,1,270,6800,700,9]);
        values.push([30,1,300,4800,850,7]);
        values.push([15,1,325,2800,1700,8]);
        values.push([24,1,350,3800,2600,16]);
        values.push([8,3,375,2800,700,5]);
        values.push([16,1,400,2400,700,6]);
        values.push([400,3,450,30000,1600,9]);
        values.push([24,1,460,2200,700,8]);
    }

    function signalChainMelody1() public view returns (IT0neV1.Effect[] memory) {
        return chain1;
    }

    function signalChainChords1() public view returns (IT0neV1.Effect[] memory) {
        return chain5;
    }

    function signalChainChords2() public view returns (IT0neV1.Effect[] memory) {
        return chain6;
    }

    function signalChainBass() public view returns (IT0neV1.Effect[] memory) {
        return chain8;
    }
    function signalChainMelody2() public view returns (IT0neV1.Effect[] memory) {
        return chain2;
    }
    function signalChainMelody3() public view returns (IT0neV1.Effect[] memory) {
        return chain3;
    }
    function signalChainMelody4() public view returns (IT0neV1.Effect[] memory) {
        return chain4;
    }
    function signalChainArp() public view returns (IT0neV1.Effect[] memory) {
        return chain7;
    }

    function name() public pure returns (string memory) {
        return "[ init ]";
    }

    function notesBass() public pure returns (uint8[4] memory) {
        return [29,32,27,31];
    }  

    function notesMelody1() public pure returns (uint8[8] memory) {
        return [77,84,75,82,79,86,79,84];
    } 

    function notesMelody2() public pure returns (uint8[32] memory) {
        return [255,255,91,89,87,86,87,89,255,255,91,89,87,86,87,82,255,255,79,89,87,86,87,89,255,255,94,89,92,91,89,86];
    } 

    function notesMelody3() public pure returns (uint8[32] memory) {
        return [62,63,62,63,62,63,62,63,58,60,62,63,58,60,62,55,62,63,62,63,62,63,62,63,62,63,62,63,65,67,62,63];
    }

    function notesMelody4() public pure returns (uint8[32] memory) {
        return [70,72,70,72,70,72,70,72,74,75,70,72,74,75,70,72,70,72,70,72,70,72,70,72,74,75,70,72,74,75,77,79];
    } 
       
    function notesChord() public pure returns (uint8[3][4] memory) {
        return [[53,56,60],[51,56,60],[55,58,63],[55,58,62]];
    }

    function colors() public pure returns (bytes[2] memory) {
        return [bytes("#111111"), bytes("#9bf2aa")];
    }

    function paramsBass() public pure returns (uint[18][2] memory) {
        return [
            [uint(10),0,3,10,0,1000,300,0,0,0,10,2000,1000,10,255,1,9,0],
            [uint(10),14,3,10,0,1000,200,0,0,0,10,2000,1000,10,255,1,9,0]
        ];
    }

    function paramsMelody1() public pure returns (uint[18][2] memory) {
        return [
            [uint(25),0,3,200,2000,1000,2000,0,0,0,600,15000,500,5000,1200,4,4,19],
            [uint(25),10,3,50,2000,1000,2000,0,0,0,600,15000,500,5000,1200,4,4,19]
        ];
    }   

    function paramsMelody2() public pure returns (uint[18][2] memory) {
        return [
            [uint(20),0,3,50,2000,1000,800,0,0,0,50,100,0,800,1500,3,4,0],
            [uint(20),10,3,50,2000,1000,800,0,0,0,60,100,0,800,1500,3,4,0]
        ];
    } 
    
    function paramsMelody3() public pure returns (uint[18] memory) {
        return [uint(10),0,3,380,1,1,1,0,0,0,10,2000,1000,10,255,1,9,0];
    }

    function paramsMelody4() public pure returns (uint[18] memory) {
        return [uint(10),0,3,380,1,1,1,0,0,0,10,2000,1000,10,255,1,9,0];
    }
    
    function paramsArp() public pure returns (uint[18] memory) {
        return [uint(10),0,3,10,0,1000,300,0,0,0,10,2000,1000,10,200,2,9,0];
    }

    function paramsChord() public pure returns (uint[11] memory) {
        return [uint(3),18,3,3,10,10,870,10,12,0,12];
    }

    function paramsLFO() public pure returns (uint[5][3] memory) {
        return [
            [uint(200),65,65,55,0],
            [uint(80),30,30,100,0],
            [uint(1000),100,100,100,0]
        ];
    }

    function notesArp() public pure returns (uint8[3][4] memory) {
        return [[77,80,91],[80,84,91],[82,87,91],[79,86,91]];
    }

    function text() public view returns (string memory) {
        address localOwner = tokenContract.ownerOf(1);
        string memory addrStr = LibString.toHexString(uint256(uint160(localOwner)), 20);
        return addrStr;
    }
    
    function svgValues () public view returns (uint[6][] memory){ 
        return values;
    }
}
