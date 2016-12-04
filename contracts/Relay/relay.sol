contract ZRelay {

  bytes32 public chainHead;
  uint public highestBlock;

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
}
