import "./blake2.sol";

library StepRowLib {
  uint32 constant n = 96;
  uint32 constant k = 5;
  struct StepRow{
    bytes hash; //Statically sized, use static types once n is defined
    uint len;
    uint32[] indices;
  }

  function newStepRow(uint n, BLAKE2b.BLAKE2b_ctx state, uint32 i) returns(StepRow){
    StepRow memory self;
    bytes person = "ZCashPOW";
    /*
    TODO: ADD N and K to personalization bytes
    */

    self.len = n/8;
    self.indices.push(i);
    self.hash = BLAKE2b.blake2b(i, "", "", person, n/8);

    return self;
  }

  function IndicesBefore(StepRow self, StepRow a){
    return self.indices[0] < a.indices[0];
  }

  function TrimHash(StepRow self, uint l){
    bytes memory p;

    for(uint i = 0; i< self.len-l; i++){
      p.push(self.hash[i+1]);
    }

    self.hash = p;
    self.len -=l;
  }

  function XOR(StepRow self, StepRow a) returns (StepRow){
    if(self.len != a.len) throw;
    if(a.indices.length != self.indices.length) throw;

    for(uint i=0; i<self.len; i++){
      self.hash = self.hash[i] ^ a.hash[i];
    }

    for(i=0; i< a.indices.length; i++){
      self.indices.push(a.indices[i]);
    }

    return self;
  }

  function IsZero(StepRow self) returns(bool){
    for(uint i=0; i<self.len; i++){
      if(self.hash[i] != 0) return false;
    }
    return true;
  }

  function HasCollisions(StepRow a, StepRow b, int l) returns (bool){
    for(uint j=0; j< l; j++){
      if(a.hash[j] != b.hash[j]) return false;
    }
    return true;
  }

  function DistinctIndicies(StepRow a, StepRow b) returns (bool){ //TODO: clarify what this does
/*
    mapping(uint32 => bool) memory indices;
    for(uint i=0; i< a.indices.length; i++){
      indices[i] = true;
    }

    for(i =0; i < b.indices.length; i++){
      if(indices[b.indices[i]]) return false;
    }
*/
    return true;
  }

}
