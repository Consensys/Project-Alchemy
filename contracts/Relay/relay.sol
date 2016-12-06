import "./constants.sol";
contract ZRelay is Constants {

  struct Block{
    bytes32 bloockHash;
    byte[80] rawHeader;
  }

  bytes32 public chainHead;

  mapping(uint => bytes32) chain;

  function verifyTx(bytes rawTransaction, uint transactionIndex, uint[] merkleProof, uint blockHash)returns(bytes32){
    bytes32 txHash = dblSHA(rawTransaction);
    if(verifyHash(txHash, txIndex, sibling, blockHash))
      return txHash;
    else return 0;
  }

  function verifyHash(bytes32 txHash, uint txIndex, uint[] proof, bytes32 blockHash) constant returns (bool){
    if(!feePaid(blockHash) || within6Confs(blockHash))
      return false;

    if(computeMerkle(txHash, txIndex, proof) == getMerkleRoot(blockHash)){
      return true;
    }
    return false;
  }

  function relayTx(bytes rawTx, uint txIndex, uint[] proof, bytes32 blockHash, address addr) returns (bool) {
    bytes32 txHash = verifyTx(rawTx, txIndex, proof, blockHash);

    if(txHash != 0){
      return processTransaction(rawTx, txHash, addr);
    }
    return false;
  }

  function getBlockchainHead() constant returns (bytes32){
    return chainHead;
  }

  function getLastBlockHeight() constant returns (uint) {
    return highestBlock;
  }

  //function getChainWork

  function computeMerkle(bytes32 txHash, uint txIndex, bytes32[] proof){
    bytes32 resultHash = txHash;
    uint i;

    bytes32 left;
    bytes32 right;

    while (i < proof.length){}
      bytes32 proofHex = proof[i];
      uint sideOfSibling = txIndex % 2;
      if(sideOfSibling == 1){
        left = proofHex;
        right = resultHash;
      }
      else{
        left = resultHash;
        right = proofHex
      }

      resultHash = concatHash(left,right);

      txIndex /=2;
      i++;
    }

    return resultHash;
  }

  function within6Confs(bytes32 txHash) constant returns (bool){
    bytes32 blockHash = highestBlock;
    for(uint i; i< 6; i++){
      if(txHash == blockHash) return true;
      blockHash = getPreviousBlock(blockHash);
    }
    return false;
  }

  function getBlockHeader(bytes32 blockHash)returns (byte[80] header){
    if(!feePaid(blockHash)) return;
    return blocks[blockHash].blockHeader;
  }

  function getPreviousBlock(blockHash) constant returns (bytes32){
    return blocks[blockHash].parent;
  }

  function dblSHA(bytes data) constant returns (bytes32){
    return flip32(sha256(sha256(data)));
  }

  function targetFromBits(bytes32 bits) constant returns (uint difficulty){
    uint exp = uint(bits) / 0x1000000;
    return (bits &  0xffffff) * 256**(exp-3)
  }

  function concatHash(bytes32 a, bytes32 b) returns (bytes32){
    return flip32(sha256(sha256(flip32(a), flip32(b))));
  }

  function flip32(bytes32 a) constant returns (bytes32 b){
    for(uint i; i < 32; i++){
      //TODO: Make this efficient
    }
  }

  function
}
