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

  function testFinalHash(){
    uint64[8] memory result = blake.blake2b("abc", "", 64);
    uint64[8] memory trueHash = [0xba80a53f981c4d0d,0x6a2797b69f12f6e9,
                                0x4c212f14685ac4b7,0x4b12bb6fdbffa2d1,
                                0x7d87c5392aab792d,0xc252d5de4533cc95,
                                0x18d38aa8dbf1925a,0xb92386edd4009923];

    assertTrue(equals(result, trueHash));
  }

  function testLongInput(){
    uint64[8] memory result = blake.blake2b("The quick brown fox jumped over the lazy dog.", "", 64);
    uint64[8] memory trueHash =[0x054b087096f9a555,0x3a09a8419cfd16db,
                                0x872805a31dd518be,0x12534d03749edb2a,
                                0x09da6731b89b5f71,0x38fcedc93cbf7536,
                                0x8db91378930e94c3,0xccc65e829b0aa349];

    assertTrue(equals(result, trueHash));

  }

  function testShortOutput(){
    uint64[8] memory result = blake.blake2b("abc", "", 20);
    uint64[8] memory trueHash =[0x384264f676f39536,0x840523f284921cdc,
                                0x0000000068b6846b,0x0000000000000000,
                                0x0000000000000000,0x0000000000000000,
                                0x0000000000000000,0x0000000000000000];

      assertTrue(equals(result, trueHash));
  }

  function testKeyedHash(){
    uint64[8] memory result = blake.blake2b("hello", "world", 32);
    uint64[8] memory trueHash =[0x38010cfe3a8e684c,0xb17e6d049525e71d,
                                0x4e9dc3be173fc05b,0xf5c5ca1c7e7c25e7,
                                0x0000000000000000,0x0000000000000000,
                                0x0000000000000000,0x0000000000000000];

    assertTrue(equals(result, trueHash));
  }

  function testSaltedHash(){
    uint64[8] memory result = blake.blake2b("hello world", "", "This is a salt", "", 32);
    uint64[8] memory trueHash =[0xa6d6c8b9fe87123a,0x9da318786050a1b0,
                                0x7f2f2c23e8e7cd7a,0xe03cfa6a6cb67851,
                                0x0000000000000000,0x0000000000000000,
                                0x0000000000000000,0x0000000000000000];

    assertTrue(equals(result, trueHash), bytes32(result[0]));
  }

  function testOutputFormatter(){
    uint64[8] memory out =[0x054b087096f9a555,0x3a09a8419cfd16db,
                          0x872805a31dd518be,0x12534d03749edb2a,
                          0x09da6731b89b5f71,0x38fcedc93cbf7536,
                          0x8db91378930e94c3,0xccc65e829b0aa349];

    bytes32[2] memory formatted =[bytes32(0x054b087096f9a5553a09a8419cfd16db872805a31dd518be12534d03749edb2a),
                                  bytes32(0x09da6731b89b5f7138fcedc93cbf75368db91378930e94c3ccc65e829b0aa349)];

    bytes32[2] memory result = blake.formatOutput(out);

    assertTrue(result[0] == formatted[0] && result[1] == formatted[1], result[0]);
  }

  function equals(uint64[8] a, uint64[8] b) constant returns(bool){
    for(uint i; i<8; i++){
      if(a[i] != b[i]){
        return false;
      }
    }
    return true;
  }

}
