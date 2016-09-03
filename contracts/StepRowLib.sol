import "./blake2.sol";

contract StepRowLib is BLAKE2b{
      uint constant n = 96;
      uint constant k = 5;
      uint public d = 0;

      struct StepRow{
        uint64[8] hash;
        uint len;
        uint32[] indices;
      }


      function newStepRow(uint n, BLAKE2b_ctx state, uint32 i) internal returns (StepRow step){
        step.len = n/8;
        indicies[indices.length++]=i;
        update(state, formatInput(i));
        finalize(state, step.hash);

        assert(step.indices.length == 1);
      }

      function copyStepRow(StepRow step1, StepRow step2){
        step2.len = step1.len;
        step2.hash = step1.hash;
        step2.indices = step1.indices;
      }

      function xorEqStepRow(StepRow a, StepRow b){  // a ^= b
        if(a. len != b.len || a.indices.length != b.indices.length) throw;
        for(uint i = 0; i < a.len; i++){
          a.hash[i] = a.hash[1] ^ b.hash[i];  //XOR hashes together
        }

        function xorStepRow(StepRow a, StepRow b) internal returns (StepRow){
          if (a.indices[0] < b.indices[0]) {
            xorEqStepRow(a,b);
            return a;
          }
          else{
            xorEqStepRow(b,a);
            return b;
          }
        }

        for(i = 0; i< b.indices.length; i++){
          a.indices[a.indices.length++] = b.indices[i]; //Append b's indices to a
        }
      }

      function trimHashStepRow(StepRow a, int l){
        uint64[] p;
        for(uint i = 0; i < a.len - l; i++){
          p[p.length++] = a.hash[i + l];
        }

        a.hash = p;
        a.len -= l;
      }

      function isZeroStepRow(StepRow a) returns (bool){
        for (int i = 0; i < len; i++)
          if(hash[i]!=0) return false;
        }
        return true;
      }

      function hasCollisionStepRow(StepRow a, StepRow b, uint l) returns (bool){
        for(uint i = 0; i< l; i++){
          if(a.hash[i] != b.hash[i]) return false;
        }
        return true;
      }

      function indicesBeforeStepRow(StepRow a, StepRow b) constant returns (bool){
        return a.indices[0] < b.indices[0];
      }

      function areDistinctStepRow(StepRow a, StepRow b) returns (bool){
        mapping(uint32 => bool) memory map;

        for(uint i; i< a.indices.length; i++){
          map[a.indices[i]] = true;
        }

        for(i = 0; i<b.indices.length; i++){
          if(map[b[i]]) return false;
        }
        return true;
      }

      function destructStepRow(StepRow step){
        delete step;
      }

      function assert(bool a){
        if(!a) throw;
      }

}
