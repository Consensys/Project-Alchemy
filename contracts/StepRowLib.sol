pragma solidity ^0.4.0;
import "./blake2.sol";

contract StepRowLib is BLAKE2b{
      uint constant n = 96;
      uint constant k = 5;
      uint public d = 0;

      mapping(uint32 => bool)  map;

      struct IndexArray{
        uint32[100] val;
        uint length;
      }

      struct StepRow{
        uint64[8] hash;
        uint len;
        IndexArray indices;
      }


      function newStepRow(uint n, BLAKE2b_ctx state, uint32 i) internal returns (StepRow step){
        step.len = n/8;
        step.indices.val[step.indices.length++]=i;
        bytes memory input = new bytes(4);
        for(uint j; j < 4; j++){
          input[j] = byte(shift_right(shift_left(uint64(i), 24-8*j), 8*j));
        }
        update(state, input);
        finalize(state, step.hash);

        assert(step.indices.length == 1);
      }

      function copyStepRow(StepRow step1, StepRow step2) internal {
        step2.len = step1.len;
        step2.hash = step1.hash;
        step2.indices = step1.indices;
      }

      function xorEqStepRow(StepRow a, StepRow b) internal {  // a ^= b
        if(a. len != b.len || a.indices.length != b.indices.length) throw;
        for(uint i = 0; i < a.len; i++){
          a.hash[i] = a.hash[1] ^ b.hash[i];  //XOR hashes together
        }
        for(i = 0; i< b.indices.length; i++){
          a.indices.val[a.indices.length++] = b.indices.val[i]; //Append b's indices to a
        }
      }

      function xorStepRow(StepRow a, StepRow b) internal returns (StepRow){
        if (a.indices.val[0] < b.indices.val[0]) {
          xorEqStepRow(a,b);
          return a;
        }
        else{
          xorEqStepRow(b,a);
          return b;
        }
      }

      function trimHashStepRow(StepRow a, uint l) internal {
        uint64[8] memory p;
        for(uint i = 0; i < a.len - l; i++){
          p[i] = a.hash[i + l];
        }

        a.hash = p;
        a.len -= l;
      }

      function isZeroStepRow(StepRow a) internal returns (bool){
        for (uint i = 0; i < a.len; i++){
          if(a.hash[i]!=0) return false;
        }
        return true;
      }

      function hasCollisionStepRow(StepRow a, StepRow b, uint l) internal returns (bool){
        for(uint i = 0; i< l; i++){
          if(a.hash[i] != b.hash[i]) return false;
        }
        return true;
      }

      function sortIndices(IndexArray a) private returns (IndexArray b){ //TODO: Sort in-place
        IndexArray memory tmp;
        for(uint i = 0 ; i < a.length; i++){
          uint j = 0;
          while (tmp.val[j] < a.val[i]){
            j++;
          }
          insert(tmp, a.val[i], j);
        }
        return tmp;
      }

      function insert(IndexArray a, uint32 b, uint i) private {
        uint32 tmp;
        uint32 tmp1 = b;
        for(uint j; j<a.length; j++){
          tmp = a.val[j];
          a.val[j] = tmp1;
          tmp1 = tmp;
        }
        a.length++;
      }

      function indicesBeforeStepRow(StepRow a, StepRow b) internal returns (bool){
        return a.indices.val[0] < b.indices.val[0];
      }

      function areDistinctStepRow(StepRow a, StepRow b) internal returns (bool){
        IndexArray memory aSort = sortIndices(a.indices);
        IndexArray memory bSort = sortIndices(b.indices);

        uint i = 0;
        for(uint j = 0; j<bSort.length; j++){
          while (aSort.val[i] < bSort.val[j]){
            i++;
            if(i == aSort.length) return true;
          }
          assert(aSort.val[i] >= bSort.val[j]);
          if(aSort.val[i] == bSort.val[j]) return false;
        }

        return true;
      }

      function destructStepRow(StepRow step) internal {
        delete step;
      }

      function assert(bool a){
        if(!a) throw;
      }

}
