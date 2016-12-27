pragma solidity ^0.4.7;
import "./BLAKE2b_Constants.sol";
//Remember to deal with empty case
contract BLAKE2b is BLAKE2_Constants{

  event Compressing(uint256[2] h);

  struct BLAKE2b_ctx {
    uint256[4] b; //input buffer
    uint256[2] h;  //chained state
    uint t; //total bytes
    uint c; //Size of b
    uint outlen; //diigest output size
    bytes32[2] out;
  }


  function compress(BLAKE2b_ctx ctx, bool last) internal {
    //Serialize context
    uint[2] memory h = ctx.h;
    uint[4] memory b = ctx.b;
    uint t = ctx.t;
    uint tf = (t >> 64) << 128;
    tf ^= (t & ((1<<64) - 1)) << 192;
    if(last){
        tf ^= ((1<<64)-1)<<64;
    }
    bytes32 sig = sha3("Compressing(uint256[2])");
    bool success;
    assembly {
        let m := mload(0x40)
        mstore(m,mload(h))
        mstore(add(m,0x20),mload(add(h,0x20)))
        mstore(add(m,0x40),mload(b))
        mstore(add(m,0x60), mload(add(b,0x20)))
        mstore(add(m,0x80), mload(add(b,0x40)))
        mstore(add(m,0xA0), mload(add(b,0x60)))
        mstore(add(m,0xC0), tf)
        log1(m,0xE0,sig)
        success := call(1000,5,0,m,0xE0,h,0x40)
        log1(h,0x40,sig)
    }
    if(!success) throw;
  }


  function init(BLAKE2b_ctx ctx, uint64 outlen, bytes key, uint128 salt, uint128 person) internal{

      if(outlen == 0 || outlen > 64 || key.length > 64) throw;
/*
      //Initialize chained-state to IV
      for(uint i = 0; i< 8; i++){
        ctx.h[i] = IV[i];
      }


*/
    uint256[2] memory IV = [
    0x6a09e667f3bcc908bb67ae8584caa73b3c6ef372fe94f82ba54ff53a5f1d36f1,
    0x510e527fade682d19b05688c2b3e6c1f1f83d9abfb41bd6b5be0cd19137e2179
    ];

      uint256[2] memory h = ctx.h;
      assembly {
          let iv := mload(IV)
          mstore(h,iv)
          iv := mload(add(IV,0x20))
          mstore(add(h,0x20),iv)
      }


      // Set up parameter block
      ctx.h[0] ^= ((0x01010000 ^ (key.length << 8) ^ outlen) << (64*3));
      ctx.h[1] ^= salt ^ (person << 64);
      //ctx.h[5] = ctx.h[5] ^ salt[1];
      //ctx.h[6] = ctx.h[6] ^ person[0];
      //ctx.h[7] = ctx.h[7] ^ person[1];

      ctx.outlen = outlen;
      //i = key.length;

      //Run hash once with key as input
      if(key.length > 0){
        update(ctx, key);
        ctx.c = 128;
      }
  }


  function update(BLAKE2b_ctx ctx, bytes input) internal {

    for(uint i = 0; i < input.length; i++){
      //If buffer is full, update byte counters and compress
      if(ctx.c == 128){
        ctx.t += ctx.c;
        compress(ctx, false);
        ctx.c = 0;
      }

      //Update temporary counter c
      uint c = ctx.c++;

      // b -> ctx.b
      uint[4] memory b = ctx.b;
      uint8 a = uint8(input[i]);

      // ctx.b[c] = a
      assembly{
        mstore8(add(b,c),a)
      }
    }
  }


  function finalize(BLAKE2b_ctx ctx) internal {
    // Add any uncounted bytes
    ctx.t += ctx.c;

    // Compress with finalization flag
    compress(ctx,true);

    //Flip little to big endian and store in output buffer
    ctx.out[0] = bytes32(ctx.h[0]);
    ctx.out[1] = bytes32(ctx.h[1]);
    flip_endian(ctx.out);


    //Properly pad output if it doesn't fill a full word
//    if(ctx.outlen < 64){
 //     bytes32 a = ctx.out[ctx.outlen/32];
      //ctx.out[ctx.outlen/32] = shift_right(getWords(ctx.h[ctx.outlen/8]),64-8*(ctx.outlen%8));

//    }

  }
/*
  //Helper function for full hash function
  function blake2b(bytes input, bytes key, bytes salt, bytes personalization, uint64 outlen) constant public returns(uint64[8]){

    BLAKE2b_ctx memory ctx;
    uint64[8] memory out;

    init(ctx, outlen, key, formatInput(salt), formatInput(personalization));
    update(ctx, input);
    finalize(ctx, out);
    return out;
  }

  function blake2b(bytes input, bytes key, uint64 outlen) constant returns (uint64[8]){
    return blake2b(input, key, "", "", outlen);
  }
*/

 function blake2b(bytes input, bytes key, bytes16 salt, bytes16 personalization, uint64 outlen) constant public returns(bytes32[2]){

    BLAKE2b_ctx memory ctx;

    init(ctx, outlen, key, uint128(salt), uint128(personalization));
    update(ctx, input);
    finalize(ctx);
    return ctx.out;
  }

// Utility functions

  function getWords(bytes32 c) constant returns (bytes32 b) {
    uint64 a = uint64(c);
    return  bytes32((a & MASK_0) / SHIFT_0 ^
            (a & MASK_1) / SHIFT_1 ^
            (a & MASK_2) / SHIFT_2 ^
            (a & MASK_3) / SHIFT_3 ^
            (a & MASK_4) * SHIFT_3 ^
            (a & MASK_5) * SHIFT_2 ^
            (a & MASK_6) * SHIFT_1 ^
            (a & MASK_7) * SHIFT_0);
  }


  function flip_endian(bytes32[2] a){
/*      uint64 c;
      for(uint i = 0; i < 8; i++){
          uint mask = ((1 << 64) - 1) << ((4-(i%4))*64)
          assembly{
              let w := mload(add(a,div(i,4)))
              w := and(w,mask)

          }
      }*/
      bytes32 mask = (1<<64)-1;
      bytes32 b = a[0];
      a[0] = (getWords((b >> (64*3))&mask) << (64*3)) ^
          (getWords((b >> (64*2))&mask) << (64*2)) ^
          (getWords((b >> (64))&mask) << (64)) ^
          (getWords(b&mask));
      b = a[1];
      a[1] = (getWords((b >> (64*3))&mask) << (64*3)) ^
          (getWords((b >> (64*2))&mask) << (64*2)) ^
          (getWords((b >> (64))&mask) << (64)) ^
          (getWords(b&mask));
  }
  /*
  function shift_right(uint64 a, uint shift) constant returns(uint64 b){
    return uint64(a / 2**shift);
  }

  function shift_left(uint64 a, uint shift) constant returns(uint64){
    return uint64((a * 2**shift) % (2**64));
  }

  //bytes -> uint64[2]
  function formatInput(bytes input) constant returns (uint64[2] output){
    for(uint i = 0; i<input.length; i++){
        output[i/8] = output[i/8] ^ shift_left(uint64(input[i]), 64-8*(i%8+1));
    }
        output[0] = getWords(output[0]);
        output[1] = getWords(output[1]);
  }

  function formatOutput(uint64[8] input) constant returns(bytes32[2]){
    bytes32[2] memory result;

    for(uint i = 0; i < 8; i++){
        result[i/4] = result[i/4] ^ bytes32(input[i] * 2**(64*(3-i%4)));
    }
    return result;
  }

  */
}
