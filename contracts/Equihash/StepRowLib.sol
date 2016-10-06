pragma solidity ^0.4.0;
import "BLAKE2b/BLAKE2b.sol";

contract StepRowLib is BLAKE2b{
  uint constant N = 200;
  uint constant K = 9;
  uint constant word_size = 32;
  uint constant word_mask = (2**word_size)-1;



  struct StepRow { // TODO: find most efficient hash and index storage system
    bytes hash;
    uint hashLen;
    uint lenIndices;
  }

  // StepRow Constructors

  // Creates new step row. TODO: Define steprow and understand its fields
  function newStepRow(bytes h, uint hLen, uint collisionLen, uint32 i) internal returns (StepRow step){
    ExpandArray(h, step.hash, collisionLen);
    EhIndexToArray(i, step.hash, hLen);
  }

  //Merge a and b into s
  function mergeStepRows(StepRow memory a, StepRow memory b, uint len, uint lenIndices, uint trim) internal returns (StepRow){
    StepRow memory s;

    s.hash = a.hash;

    for(uint i = trim; i < len; i++){
      s.hash[i-trim] = a.hash[i] ^ b.hash[i];
    }
    if(IndicesBefore(a, b, len, lenIndices)){
      for(i = 0; i < lenIndices; i++){
        s.hash[len + i - trim] = a.hash[len+i];
        s.hash[len+lenIndices+i - trim] = b.hash[len+i];
      }
    }
    else{
      for(i = 0; i < lenIndices; i++){
        s.hash[len + i - trim] = b.hash[len+i];
        s.hash[len+lenIndices+i - trim] = a.hash[len+i];
      }
    }
    return s;
  }

  //Alg Binding Checks

  // True iff a.hash^b.hash has collisionLength leading 0-bytes
  function HasCollision(StepRow memory a, StepRow memory b, uint collisionLength) internal returns (bool){
    for(uint i = 0; i < collisionLength; i++){
      if(a.hash[i] != b.hash[i]) return false;
    }
    return true;
  }

  // True iff a's indicies are lexicographically before b's
  function IndicesBefore(StepRow memory a, StepRow memory b, uint len, uint lenIndices) internal returns (bool){
    bytes memory aHash = a.hash;
    bytes memory bHash = b.hash;
    for(uint i; i< lenIndices; i++){
      if(a.hash[len + i] < b.hash[len + i]) return true;
    }

    return false;
    //TODO: implement efficien comparison using 32-byte chunks
/*    assembly {
      let startA := add(add(aHash, 0x20),len)
      let startB := add(add(bHash, 0x20), len)
      let i := 0
      loop:
      jumpi(equal, geq(i, lenIndices))
      jumpi(nequal, not(eq(mload(add(startA,i)))))
      equal:
    }*/
  }

  // True iff a and b share no indices TODO: this can be much more efficient
  function DistinctIndices(StepRow memory a, StepRow memory b, uint len, uint lenIndices) internal returns (bool){
    for(uint i; i < lenIndices; i += 4){
      for(uint j; j < lenIndices; j+=4){
        if(
          a.hash[len+i] == b.hash[len+j] &&
          a.hash[len+i+1] == b.hash[len+j+1] &&
          a.hash[len+i+2] == b.hash[len+j+2] &&
          a.hash[len+i+3] == b.hash[len+j+3]
          ) return false;
      }
    }

    return true;
  }

  // True iff the first len bytes are 0
  function IsZero(StepRow s, uint hLen)internal returns(bool){
    for(uint i; i<hLen; i++){
      if(s.hash[i] != 0) return false;
    }
    return true;
  }

  //Converts an array of little endian bit_len length values to 32 bit big endian array
  function ExpandArray(bytes inp, bytes out, uint bit_len) internal {
    uint bit_len_mask = (2**bit_len)-1;
    uint64 acc_bits = 0;
    uint64 acc_value = 0;

    uint outlen = 8*inp.length/bit_len;

    uint j = 0;

    for(uint i = 0; i < inp.length; i++){
      acc_value = uint64(shift_left(acc_value, 8) & word_mask | uint(inp[i]));
      acc_bits += 8;

      if(acc_bits >= bit_len){
        acc_bits -= uint64(bit_len);
        out[j] = byte(shift_right(acc_value, acc_bits) & bit_len_mask);
        j++;
      }
    }
  }

  function CompressArray(bytes inp, bytes out, uint inp_bits) internal {
    uint64 acc_bits = 0;
    uint64 acc_value = 0;

    uint outlen = inp_bits*inp.length/8;

    uint j = 0;

    for(uint i; i < outlen; i++){
      if(acc_bits < 8){
        acc_value = uint64((shift_left(acc_value, inp_bits) & word_mask) | uint(inp[j]));
        j++;
        acc_bits += uint64(inp_bits);
      }

      acc_bits -= 8;
      out[i] = byte(shift_right(acc_value, acc_bits) & 0xFF);
    }
  }

  function EhIndexToArray(uint32 i, bytes hash, uint hLen) internal {
    uint32 bei = uint32(getWords(i));
    for(uint j = 0; j < 4; j++){
      hash[j + hLen] = byte(shift_right(bei, 8*(3-j)) & 0xFF);
    }
  }
}
