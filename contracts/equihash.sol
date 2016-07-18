import "./blake2.sol";

contract EquihashValidator is BLAKE2b{

    uint constant n;
    uint constant k;
    uint constant d;

    struct StepRow{
      bytes hash;
    }

    function EquihashValidator(){

    }

    function newStepRow(uint n, BLAKE2b_ctx state, uint i);

    function initializeState(BLAKE2b_ctx state, uint32 N, uint32 K, uint32[] soln){
      bytes4 N = bytes4(toLittleEndian(uint64(n)));
      bytes4 K = bytes4(toLittleEndian(uint64(k)));

      bytes personalization = "ZcashPoW";
      for(uint i = 0; i<4; i++){
        personalization.push(N[i]);
      }
      for(i = 0; i<4; i++){
        personalization.push(K[i]);
      }

      init(state, N/8, "", "", formatInput(personalization));

      update(state, I);
      update(state, soln);
    }

    function validate(uint32 n, uint32 k, bytes I, uint nonce, uint32[] soln) returns (bool){
      BLAKE2b_ctx memory state;

      initializeState(state);

      uint soln_size = 2**K;

      if(soln.length != soln_size) return false;

      StepRow[] X;

      for(uint i=0; i< soln.length; i++){
        X.push(newStepRow(n, state, i));
      }

      uint hashLen = n/8;
      uint lenIndecies = ?;

      while(X.length > 1){
        StepRow[] Xc;

        for(i=0; i< X.length; i+=2){
          if(!HasCollision(X[i],X[i+1], CollisionByteLength)) return false;

          if(IndicesBefore(X[i],X[i+1], hashLen,lenIndecies)) return false;

          if(!DistinctIndices(X[i],X[i+1], hashLen,lenIndecies)) return false;

          Xc.push(newStepRow(X[i], X[i+1], hashLen, lenIndecies, CollisionByteLength));
        }

        X = Xc;
        hashLen -= CollisionByteLength;
        lenIndecies = lenIndecies*2;
      }

      return isZero(X[0],hashLen);
    }

}
