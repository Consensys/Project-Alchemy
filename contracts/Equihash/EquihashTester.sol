pragma solidity ^0.4.2;
import "Equihash/Equihash.sol";

contract EquihashTester is EquihashValidator{

  function testGenerator(uint32 g, uint64[8] expected) returns (bool){
    BLAKE2b_ctx memory state;
    uint64[8] memory out;
    initializeState(state);
    generateHash(state, g, out);

    for(uint i; i<8; i++){
      if(out[i] != expected[i]) return false;
    }
    return true;
  }

}
