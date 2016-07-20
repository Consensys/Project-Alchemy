import "./equihash.sol";
import "dapple/test.sol";

contract EquihashTest is Test {

  EquihashValidator equi;
  Tester test;

  function EquihashTest(){
    equi = new EquihashValidator(96, 5, 0);
  }

  function setUp(){
    tester = new Tester();
    tester._target(equi);
  }


  function testEquihashValidator(){
    bytes memory seed = "Equihash is an asymmetric PoW based on the Generalised Birthday problem.";
    uint nonce = 1;
    uint32[] memory soln = [2154, 87055, 7922, 12920, 45189, 49783, 122795, 124296, 2432, 48178, 48280, 67880, 3912, 62307, 10987, 93891, 19673, 24483, 33984, 91500, 38171, 85505, 94625, 106140, 31530, 60861, 59391, 117337, 68078, 129665, 126764, 128278];
    bool correct = true;
    bool valid = equi.validate(seed, nonce, soln);

    assertTrue(correct==valid);
  }
}
