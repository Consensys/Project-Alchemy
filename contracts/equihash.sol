import "./blake2.sol";
import "./StepRowLib.sol";
contract EquihashValidator{

    struct Equihash{
      uint n;
      uint k;
    }

    function validate_params(uint n, uint k)returns(bool){
      if(k >= n || n%8 != 0 || (n/(k+1)) % 8 != 0) throw;
    }

    function newEquihash(uint n, uint k) internal returns(Equihash eq){
      validate_params(n,k);
      eq.n = n;
      eq.k = k;
    }

    function initializeStateEquihash(Equihash eq, BLAKE2b_ctx state){
      bytes person = "ZcashPOW";
      bytes8 N = bytes8(getWords(eq.n));
      bytes8 K = bytes8(getWords(eq.k));

      for(uint i = 0; i<4; i++){
        person[person.length++] = N[i];
      }

      for(i = 0; i<4; i++){
        person[person.length++] = K[i];
      }

      init(state, eq.n/8, "", formatInput(""), formatInput(person));
    }

    function isValidSolutionEquihash(Equihash eq, BLAKE2b_ctx state, uint32[] soln){
      uint32 soln_size = 2**eq.k;

      if(soln_size != soln.length) throw;

      StepRow[] X;

      for(uint i = 0; i < soln_size; i++){
        X[X.length++] = newStepRow(eq.n, state, soln[i]);
      }

      x_size = X.length();

      uint hashlen = eq.n/8;
      uint lenindices = 32;

      while(X.length > 1){
        StepRow[] memory Xc;

        for (int i = 0; i < X.length(); i += 2) {
            if(!hasCollisionStepRow(X[i], X[i+1], byteLengthEquihash())) return false;
            if(indicesBeforeStepRow(X[i+1],X[i])) return false;
            if(!areDistinctStepRow(X[i], X[i+1])) return false;

            Xc[Xc.length++] = xorStepRow(X[i], X[i+1]);
            trimHashStepRow(Xc[Xc.length -1], byteLengthEquihash());
          }
          X = Xc;
      }
      assert(X.length == 1);
      return isZeroStepRow(X[0]);
    }

    function bitLengthEquihash(Equihash eq) constant returns(uint){
      return eq.n/(eq.k+1);
    }
    function byteLengthEquihash(Equihash eq) constant returns (uint){
      return bitLengthEquihash(eq)/8;
    }




}
