pragma solidity ^0.4.0;
import "./StepRowLib.sol";
contract EquihashValidator is StepRowLib{

    struct Equihash{
      uint64 n;
      uint64 k;
    }

    function validate_params(uint n, uint k)returns(bool){
      if(k >= n || n%8 != 0 || (n/(k+1)) % 8 != 0) throw;
    }

    function newEquihash(uint64 n, uint64 k) internal returns(Equihash eq){
      validate_params(n,k);
      eq.n = n;
      eq.k = k;
    }

    function initializeStateEquihash(Equihash eq, BLAKE2b_ctx state) internal {
      bytes person;// =bytes("ZcashPOW");
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

    function isValidSolutionEquihash(Equihash eq, BLAKE2b_ctx state, uint32[] soln) internal returns(bool){
      uint64 soln_size = 2**eq.k;

      if(soln_size != soln.length) throw;

      StepRow[] memory X = new StepRow[](soln_size);

      for(uint i = 0; i < soln_size; i++){
        X[i] = newStepRow(eq.n, state, soln[i]);
      }

      uint hashlen = eq.n/8;
      uint lenindices = 32;

      while(X.length > 1){
        StepRow[] memory Xc = new StepRow[](X.length/2);

        for (i = 0; i < X.length; i += 2) {
            if(!hasCollisionStepRow(X[i], X[i+1], byteLengthEquihash(eq))) return false;
            if(indicesBeforeStepRow(X[i+1],X[i])) return false;
            if(!areDistinctStepRow(X[i], X[i+1])) return false;

            Xc[i/2] = xorStepRow(X[i], X[i+1]);
            trimHashStepRow(Xc[Xc.length -1], byteLengthEquihash(eq));
          }
          X = Xc;
      }
      assert(X.length == 1);
      return isZeroStepRow(X[0]);
    }

    function validate(bytes seed, uint nonce, uint32[] soln) returns (bool){
      Equihash memory eq = newEquihash(96, 5);
      BLAKE2b_ctx memory state;
      initializeStateEquihash(eq, state);
      return isValidSolutionEquihash(eq, state, soln);
    }

    function bitLengthEquihash(Equihash eq) internal returns(uint){
      return eq.n/(eq.k+1);
    }
    function byteLengthEquihash(Equihash eq) internal returns (uint){
      return bitLengthEquihash(eq)/8;
    }




}
