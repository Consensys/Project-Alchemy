import "./equihash.sol";
import "dapple/test.sol";

contract EquihashTest is Test {

  EquihashValidator equi;
  Tester test;

  function setUp(){
    equi = new EquihashValidator();
    tester = new Tester();
    tester._target(equi);
  }


}
