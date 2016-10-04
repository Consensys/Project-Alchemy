pragma solidity ^0.4.0;
import "BLAKE2b/BLAKE2b.sol";

contract StepRowLib is BLAKE2b{
  uint constant N = 200;
  uint constant K = 9;


  struct StepRow { // TODO: find most efficient hash and index storage system
  }

  // StepRow Constructors

  function newStepRow(bytes h, uint hlen, uint collisionLen, uint32 index) internal returns (StepRow); // Creates new step row. TODO: Define steprow and understand its fields

  function mergeStepRows(StepRow memory a, StepRow memory b) internal returns (StepRow);

  //Alg Binding Checks

  // True iff a.hash^b.hash has collisionLength leading 0-bytes
  function HasCollision(StepRow memory a, StepRow memory b, uint collisionLength) internal returns (bool);

  // True iff a's indicies are lexicographically before b's
  function IndicesBefore(StepRow memory a, StepRow memory b) internal returns (bool);

  // True iff a and b share no indices
  function DistinctIndices(StepRow memory a, StepRow memory b) internal returns (bool);

}
