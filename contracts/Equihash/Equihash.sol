pragma solidity ^0.4.2;
import "Equihash/StepRowLib.sol";
contract EquihashValidator is StepRowLib{
  uint64 constant powString = 0x5a63617368506f57; // "ZcashPoW"
  uint64 constant paramString = 0xc800000009000000; // le_N||le_K
  uint constant IndicesPerHashOutput = 512/N;
  uint constant CollisionBitLength = N/(K+1);
  uint constant CollisionByteLength = (CollisionBitLength+7)/8;
  uint constant HashLength = (K+1)*CollisionByteLength;

  function initializeState(BLAKE2b_ctx baseState) internal{
    uint64[2] memory person = [powString, paramString];
    init(baseState, uint64((512/N)*N/8), "", formatInput(""), person);
  }

  function generateHash(BLAKE2b_ctx baseState, uint32 g, bytes output) internal{
    BLAKE2b_ctx memory state = baseState; // Needs to make a copy. TODO: check this is correct
    bytes memory input = new bytes(4);
    uint64[8] memory hash;
    for(uint i; i<4; i++){
      input[i] = byte(shift_right(g, 8*i) & 0x11); // Copy g to input in LE order
    }
    update(state, input);
    finalize(state, hash);
    uint h = (g % IndicesPerHashOutput) * N/8;
    bytes memory out = new bytes(N/8);
    for(i = 0; i < N/8; i++){
      uint t = i + h;
      out[i] = byte(shift_right(hash[t/8], (7-(t%8))*8) & 0x11);
    }
    output = out;
  }

  function IsValidSolution(uint32[512] soln) returns (bool){
    BLAKE2b_ctx memory baseState;
    initializeState(baseState);
    StepRow[] memory X = new StepRow[](512);
    bytes memory tmpHash;
    for(uint i; i<512; i++){ //Fill X with steprows
      generateHash(baseState, soln[i], tmpHash);
      X[i] = newStepRow(tmpHash, HashLength, CollisionBitLength, soln[i]);
    }

    uint hashLen = HashLength;
    uint lenIndices = 4;
    while(X.length > 1 ){
      StepRow[] memory Xc = new StepRow[](X.length / 2);

      for(i = 0; i < X.length; i+=2){

        // Algorithm Binding Conditions
        if(!HasCollision(X[i], X[i+1], CollisionByteLength)) return false;
        if(IndicesBefore(X[i+1], X[i], hashLen, lenIndices)) return false;
        if(!DistinctIndices(X[i], X[i+1], hashLen, lenIndices)) return false;

        Xc[i/2] = mergeStepRows(X[i], X[i+1], hashLen, lenIndices, CollisionByteLength);
      }

      X = Xc;
      hashLen -= CollisionByteLength;
      lenIndices *= 2;
    }

    //General Birthday Condition
    return IsZero(X[0], hashLen);
  }

}
