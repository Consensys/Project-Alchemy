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
    bool correct = true;
    uint64[8] memory result = blake.blake2b("", "abc", 64);
    uint64[8] memory trueHash = [0xba80a53f981c4d0d,0x6a2797b69f12f6e9,
                        0x4c212f14685ac4b7,0x4b12bb6fdbffa2d1,
                        0x7d87c5392aab792d,0xc252d5de4533cc95,
                        0x18d38aa8dbf1925a,0xb92386edd4009923];
    for(uint i; i<8; i++){
      if(result[i] != trueHash[i]){
        correct = false;
      }

      assertTrue(correct);
    }
  }

}
