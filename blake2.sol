//Line-for-line naieve implementation of IETF RFC 7693
import "./constants.sol"

contract BLAKE2 {

    BLAKE2b_CONST CONST;

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
/*
      assembly {
        let iv := 0
        IV pop
        =: iv
        mstore(v,mload(h))
        mstore(add(v,0x20),mload(add(h,0x20)))
        mstore(add(v,0x40),sload(iv))
        mstore(add(v,0x60),sload(add(iv,0x20)))
      }
*/

      for(uint i; i< 8; i++){
        v[i] = h[i];
        v[8+i] = CONST.IV[i];
      }

      v[12] = v[12] ^ bytes8((uint(t) % 2**64));
      v[13] = v[13] ^ shift_left(bytes8(t),64);

      if(f) v[14] = v[14] ^ 0xFFFFFFFFFFFFFFFF;

      for(i = 0; i < 12; i++){
        uint8[16] s = CONST.SIGMA[i%10];

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
      bytes8[8] memory h = CONST.IV;
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
