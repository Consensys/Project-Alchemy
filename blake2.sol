//Line-for-line naieve implementation of IETF RFC 7693
contract BLAKE2 {

  uint[16][12] SIGMA = [
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

    bytes8[8] IV = [
        bytes8(0x6a09e667f3bcc908), bytes8(0xbb67ae8584caa73b),
        bytes8(0x3c6ef372fe94f82b), bytes8(0xa54ff53a5f1d36f1),
        bytes8(0x510e527fade682d1), bytes8(0x9b05688c2b3e6c1f),
        bytes8(0x1f83d9abfb41bd6b), bytes8(0x5be0cd19137e2179)
    ];

    function G (bytes8[16] v, uint a, uint b, uint c, uint d, bytes8 x, bytes8 y) returns (bytes8[16]){
      v[a] =bytes8((uint(v[a]) + uint(v[b]) + uint(x)) % 2**64);
      v[d] = rotate(v[d] ^ v[a], 32);
      v[c] = bytes8((uint(v[c]) + uint(v[d])) % 2**64);
      v[b] = rotate(v[b] ^ v[c], 24);
      v[a] = bytes8((uint(v[a]) + uint(v[b]) + uint(y)) % 2**64);
      v[d] = rotate(v[d] ^ v[a], 16);
      v[c] = bytes8((uint(v[c]) + uint(v[d])) % 2**64);
      v[b] = rotate(v[b] ^ v[c], 63);

      return v;
    }


    function F(bytes8[8] h, bytes8[16] m, uint16 t, bool f) returns (bytes8[8]){
      bytes8[16] memory v;

      assembly {
        let iv := 0
        IV pop
        =: iv
        mstore(v,mload(h))
        mstore(add(v,0x20),mload(add(h,0x20)))
        mstore(add(v,0x40),sload(iv))
        mstore(add(v,0x60),sload(add(iv,0x20)))
      }

      v[12] = v[12] ^ bytes8((uint(t) % 2**64));
      v[13] = v[13] ^ shift_left(bytes8(t),64);

      if(f) v[14] = v[14] ^ 0xFFFFFFFFFFFFFFFF;

      for(uint i; i < 12; i++){
        uint[16] s = SIGMA[i%10];

        v = G( v, 0, 4, 8, 12, m[s[0]], m[s[1]]);
        v = G( v, 1, 5, 9, 13, m[s[2]], m[s[3]]);
        v = G( v, 2, 6, 10, 14, m[s[4]], m[s[5]]);
        v = G( v, 3, 7, 11, 15, m[s[6]], m[s[7]]);

        v = G( v, 0, 5, 10, 15, m[s[0]], m[s[1]]);
        v = G( v, 1, 6, 11, 12, m[s[2]], m[s[3]]);
        v = G( v, 2, 7, 8, 13, m[s[4]], m[s[5]]);
        v = G( v, 3, 4, 9, 14, m[s[6]], m[s[7]]);
      }

      for(i = 0; i<8; i++){
        h[i] = h[i] ^ v[i] ^ v[i+8];
      }

      return h;
    }

   // function pad();

    function digest(bytes8[8] p, bytes8[16][] d, bytes8[16] key, uint ll) returns(bytes8[8]){
      bytes8[8] memory h = IV;
      bytes8 nn = p[0];
      bytes8 kk = p[1];
      h[0] = h[0] ^ 0x01010000 ^ shift_left(kk,8) ^ nn;

      if(d.length > 1){
        for(uint i; i< d.length-1; i++){
          h = F(h, d[i], uint16((i+1)*128), false);
        }
      }

      if(kk == 0){
        h = F(h, d[d.length-1], uint16(ll), true);
      }

      else {
        h = F(h, d[d.length-1], uint16(ll+128), true);
      }

      return h;
    }



    function shift_right(bytes8 a, uint shift) constant returns(bytes8 b){
      return bytes8(uint(a) / 2**shift);
    }

    function shift_left(bytes8 a, uint shift) constant returns(bytes8 b){
      return bytes8((uint(a) * 2**shift) % (2**64));
    }

    function rotate(bytes8 a, uint shift) constant returns(bytes8 b){
      return shift_right(a, shift) ^ shift_left(a, 64-shift);
    }



}
