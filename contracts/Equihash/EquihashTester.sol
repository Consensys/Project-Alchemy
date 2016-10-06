pragma solidity ^0.4.2;
import "Equihash/Equihash.sol";

contract EquihashTester is EquihashValidator{

  function testGenerator(uint32 g, bytes expected) returns (bool){
    BLAKE2b_ctx memory state;
    bytes memory out;
    initializeState(state);
    generateHash(state, g, out);

    for(uint i; i<8; i++){
      if(out[i] != expected[i]) return false;
    }
    return true;
  }

  function testExpandArray(bytes inp, uint len, bytes expected)returns (bool){
    bytes memory out = new bytes(8*(inp.length/len));

    ExpandArray(inp, out, len);

    if(out.length != expected.length) return false;
    for(uint i; i<out.length; i++){
      if (out[i] != expected[i]) return false;
    }

    return true;
  }

}
