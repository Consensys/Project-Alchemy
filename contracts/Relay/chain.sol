contract Chain {
  uint constant NUM_ANCESTOR_DEPTHS = 8;
  uint public highestBlock;

  mapping(bytes32 => Block) private blocks;


  function inMainChain(bytes32 txBlockHash) internal returns (bool) {
    var (txBlockHeight, err) = getHeight(txBlockHash);
    if(err != 0){
      return false;
    }
    else return (fastGetBlockHash(txBlockHeight) == txBlockHash);
  }

  function fastGetBlockHash(uint blockHeight) private returns (bytes32) {
    bytes32 blockHash = highestBlock;
    uint anc_index = NUM_ANCESTOR_DEPTHS - 1;

    while(getHeight(blockHash) > blockHeight){
      while(getHeight(blockHash) - blockHeight < getAncDepth(anc_index) && anc_index > 0){
        anc_index--;
      }
      blockHash = blocks[getAncestor(blockHash, anc_index)];
    }
    return blockHash;
  }
}
