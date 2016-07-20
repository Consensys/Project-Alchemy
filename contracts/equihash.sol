import "./blake2.sol";
import "./StepRowLib.sol";
contract EquihashValidator is BLAKE2b{

    uint public n = 96;
    uint public k = 5;
    uint public d = 0;


    function EquihashValidator(uint _n, uint _k, uint _d){
      n = _n;
      k = _k;
      d = _d;
    }


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

    function validate(bytes I, uint nonce, uint32[] soln) returns (bool){
      BLAKE2b_ctx memory state;

      initializeState(state);

      uint soln_size = 2**K;

      if(soln.length != soln_size) return false;

      StepRowLib.StepRow[] X;

      for(uint i=0; i< soln.length; i++){
        X.push(StepRowLib.StepRow(n, state, i));
      }

      while(X.length > 1){
        StepRow[] Xc;

        for(i=0; i< X.length; i+=2){
          if(!HasCollision(X[i],X[i+1], CollisionByteLength)) return false;

          if(X[i+1].IndicesBefore(X[i])) return false;

          if(!DistinctIndices(X[i+1, X[i]])) return false;

          Xc.push(X[i].XOR(X[i+1]));
          Xc[Xc.length-1].TrimHash(CollisionByteLength());
        }

        X = Xc;
      }

      return isZero(X[0],hashLen);
    }

    function CollisionByteLength() constant returns (uint){
      return (n/(k+1))/8;
    }

}
