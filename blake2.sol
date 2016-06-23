contract BLAKE2b {

  //CONSTANTS
  uint8[16][12] public SIGMA = [
        [  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15 ],
        [ 14,10, 4, 8, 9,15,13, 6, 1,12, 0, 2,11, 7, 5, 3 ],
        [ 11, 8,12, 0, 5, 2,15,13,10,14, 3, 6, 7, 1, 9, 4 ],
        [  7, 9, 3, 1,13,12,11,14, 2, 6, 5,10, 4, 0,15, 8 ],
        [  9, 0, 5, 7, 2, 4,10,15,14, 1,11,12, 6, 8, 3,13 ],
        [  2,12, 6,10, 0,11, 8, 3, 4,13, 7, 5,15,14, 1, 9 ],
        [ 12, 5, 1,15,14,13, 4,10, 0, 7, 6, 3, 9, 2, 8,11 ],
        [ 13,11, 7,14,12, 1, 3, 9, 5, 0,15, 4, 8, 6, 2,10 ],
        [  6,15,14, 9,11, 3, 0, 8,12, 2,13, 7, 1, 4,10, 5 ],
        [ 10, 2, 8, 4, 7, 6, 1, 5,15,11, 9,14, 3,12,13 ,0 ],
        [  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15 ],
        [ 14,10, 4, 8, 9,15,13, 6, 1,12, 0, 2,11, 7, 5, 3 ]
    ];

    uint64[8] public IV = [
        0x6a09e667f3bcc908, 0xbb67ae8584caa73b,
        0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
        0x510e527fade682d1, 0x9b05688c2b3e6c1f,
        0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
    ];


  struct BLAKE2b_ctx {
    uint8[128] b; //input buffer
    uint64[8] h;  //chained state
    uint64[2] t; //total bytes
    uint64 c; //Size of b
    uint outlen; //diigest output size
  }

  function G(uint64[16] v, uint a, uint b, uint c, uint d, uint64 x, uint64 y) constant { //OPTIMIZE HERE
       v[a] = v[a] + v[b] + x;
       v[d] = rotate(v[d] ^ v[a], 32);
       v[c] = v[c] + v[d];
       v[b] = rotate(v[b] ^ v[c], 24);
       v[a] = v[a] + v[b] + y;
       v[d] = rotate(v[d] ^ v[a], 16);
       v[c] = v[c] + v[d];
       v[b] = rotate(v[b] ^ v[c], 63);
  }

  function compress(BLAKE2b_ctx ctx, bool last) private {
    uint64[16] memory v;
    uint64[16] memory m;

    for(uint i=0; i<8; i++){
      v[i] = ctx.h[i];
      v[i+8] = IV[i];
    }

    v[12] = v[12] ^ ctx.t[0];
    v[13] = v[13] ^ ctx.t[1];

    if(last) v[14] = ~v[14];

    for(i = 0; i <16; i++){
      m[i] = getWords(ctx.b[i]);
    }

    for(i=0; i<12; i++){
      G( v, 0, 4, 8, 12, m[SIGMA[i][0]], m[SIGMA[i][1]]);
      G( v, 1, 5, 9, 13, m[SIGMA[i][2]], m[SIGMA[i][3]]);
      G( v, 2, 6, 10, 14, m[SIGMA[i][4]], m[SIGMA[i][5]]);
      G( v, 3, 7, 11, 15, m[SIGMA[i][6]], m[SIGMA[i][7]]);
      G( v, 0, 5, 10, 15, m[SIGMA[i][8]], m[SIGMA[i][9]]);
      G( v, 1, 6, 11, 12, m[SIGMA[i][10]], m[SIGMA[i][11]]);
      G( v, 2, 7, 8, 13, m[SIGMA[i][12]], m[SIGMA[i][13]]);
      G( v, 3, 4, 9, 14, m[SIGMA[i][14]], m[SIGMA[i][15]]);
    }

    for(i=0; i<8; ++i){
      ctx.h[i] = ctx.h[i] ^ v[i] ^ v[i+8];
    }
  }

  function init(BLAKE2b_ctx ctx, uint64 outlen, bytes key) private{
      uint i;

      if(outlen == 0 || outlen > 64 || key.length > 64) throw;

      for(i = 0; i< 8; i++){
        ctx.h[i] = IV[i];
      }

      ctx.h[0] = ctx.h[0] ^ 0x01010000 ^ shift_left(uint64(key.length), 8) ^ outlen; // Set up parameter block

      ctx.t[0] = 0;
      ctx.t[1] = 0;

      ctx.c = 0;

      ctx.outlen = outlen;
      i= key.length;

      for(i = key.length; i < 128; i++){
        ctx.b[i] = 0;
      }

      if(key.length > 0){
        update(ctx, key);
        ctx.c = 128;
      }

  }

  function update(BLAKE2b_ctx ctx, bytes input) private {
    uint i;

    for(i = 0; i < input.length; i++){
      if(ctx.c == 128){   //buffer full?
        ctx.t[0] += ctx.c; //add counters
        if(ctx.t[0] < ctx.c){ //overflow?
          ctx.t[1] ++; //carry to high word
        }
        compress(ctx, false);
        ctx.c = 0;
      }

      ctx.b[ctx.c++] = uint8(input[i]); //THIS NEEDS WORK________
    }
  }

  function finalize(BLAKE2b_ctx ctx, uint64[8] out) private {
    uint i;

    ctx.t[0] += ctx.c;
    if(ctx.t[0] < ctx.c) ctx.t[1]++;

    while(ctx.c < 128){
      ctx.b[ctx.c++] = 0;
    }

    compress(ctx,true);


    for(i=0; i< ctx.outlen/8; i++){
      out[i] = (shift_right(ctx.h[shift_right(uint64(i),3)], 8* (i & 7))) & 0xFF;
    }
  }

  function blake2b(bytes key, bytes input, uint64 outlen) constant returns(uint64[8]){
    BLAKE2b_ctx memory ctx;
    uint64[8] memory out;


    init(ctx, outlen, key);
    update(ctx, input);
    finalize(ctx, out);
    return out;
  }

// Utility functions
  function getWords(uint64 a) constant returns (uint64 b) { //Flips endianness of words

    return    (a & 0xFF00000000000000   )/ 0x1000000000000000^
    shift_left(a & 0x00FF000000000000, 8)/ 0x0010000000000000^
    shift_left(a & 0x0000FF0000000000, 16)/0x0000100000000000^
    shift_left(a & 0x000000FF00000000, 24)/0x0000001000000000^
    shift_left(a & 0x00000000FF000000, 32)/0x0000000010000000^
    shift_left(a & 0x0000000000FF0000, 40)/0x0000000000100000^
    shift_left(a & 0x000000000000FF00, 48)/0x0000000000001000^
    shift_left(a & 0x00000000000000FF, 56)/0x0000000000000010;

  }

  function shift_right(uint64 a, uint shift) constant returns(uint64 b){
    return uint64(a / 2**shift);
  }

  function shift_left(uint64 a, uint shift) constant returns(uint64){
    return uint64((a * 2**shift) % (2**64));
  }

  function rotate(uint64 a, uint shift) constant returns(uint64 b){
    return shift_right(a, shift) ^ shift_left(a, 64-shift);
  }

  function assign (bytes32 a, uint b, byte c) constant returns (bytes32 d){
      uint e = uint(c);
      assembly {
          mstore(0,a)
          mstore8(b,e)
          return(0,0x20)
      }
  }

}
