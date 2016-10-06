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
  function newStepRow(bytes h, uint hLen, uint collisionLen) internal returns (StepRow step){
    ExpandArray(h, step.hash, collisionLen);

  }

  function mergeStepRows(StepRow memory a, StepRow memory b) internal returns (StepRow s);

  //Alg Binding Checks

  // True iff a.hash^b.hash has collisionLength leading 0-bytes
  function HasCollision(StepRow memory a, StepRow memory b, uint collisionLength) internal returns (bool);

  // True iff a's indicies are lexicographically before b's
  function IndicesBefore(StepRow memory a, StepRow memory b) internal returns (bool);

  // True iff a and b share no indices
  function DistinctIndices(StepRow memory a, StepRow memory b) internal returns (bool);

  // True iff the first len bytes are 0
  function IsZero(StepRow s, uint hLen)internal returns(bool);

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
}
