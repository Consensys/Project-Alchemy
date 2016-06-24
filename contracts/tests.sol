import "./blake2.sol";
import "dapple/test.sol";

contract BlakeTest is Test {
  BLAKE2b blake;
  Tester tester;

  function setUp(){
    blake = new BLAKE2b();
    tester = new Tester();
    tester._target(blake);
  }

  function testFinalHash (){ //If this works, we're good.....
    assertTrue(blake.blake2b("", "abc", 64) == 0xBA80A53F981C4D0D6A2797B69F12F6E94C212F14685AC4B74B12BB6FDBFFA2D17D87C5392AAB792DC252D5DE4533CC9518D38AA8DBF1925AB92386EDD4009923);
  }

}
