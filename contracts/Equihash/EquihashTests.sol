pragma solidity ^0.4.2;
import "Equihash/EquihashTester.sol";
import "dapple/test.sol";

contract EquihashTest is Test {

  EquihashTester equi;
  Tester tester;

  function EquihashTest(){
    equi = new EquihashTester();
  }

  function setUp(){
    tester = new Tester();
    tester._target(equi);
  }


  function testEquihashValidator(){
    bytes memory seed = "Equihash is an asymmetric PoW based on the Generalised Birthday problem.";
    uint nonce = 1;
    uint32[32] memory soln = [uint32(2154), uint32(87055), uint32(7922), uint32(12920), uint32(45189), uint32(49783), uint32(122795), uint32(124296), uint32(2432), uint32(48178), uint32(48280), uint32(67880), uint32(3912), uint32(62307), uint32(10987), uint32(93891), uint32(19673), uint32(24483), uint32(33984), uint32(91500), uint32(38171), uint32(85505), uint32(94625), uint32(106140), uint32(31530), uint32(60861), uint32(59391), uint32(117337), uint32(68078), uint32(129665), uint32(126764), uint32(128278)];
    uint32[] memory s = new uint32[](32);
    for(uint i=0; i<32; i++){
      s[i] = soln[i];
    }
    bool correct = true;
  //  bool valid = equi.IsValidSolution(soln);

    //assertTrue(correct==valid);
  }

  function testExpandArray(){
    bytes memory inp = "\x02\x20\x0a\x7f\xff";
    bytes memory exp = "\x44\x29";
    uint bits = 21;

    assertTrue(equi.testExpandArray(inp,bits,exp));
  }
}
