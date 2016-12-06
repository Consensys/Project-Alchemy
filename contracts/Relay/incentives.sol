contract Incentives {
  uint128 gasPrice;
  uint128 public changeRecipientFee;

  event EthPayment(address recipient, uint amount);

  function storeBlockWithFee(byte[80] blockHeaderBytes, uint fee){
    return storeBlockWithFeeandRecipient(blockHeaderBytes, fee, msg.sender);
  }

  function storeBlockWithFeeandRecipient(byte[80] blockHeaderBytes, uint fee, address recipient){
    uint beginGas = msg.gas;
    bool res = storeBlockHeader(blockHeaderBytes);
    if(res){
      bytes32 blockHash = dblSHA(blockHeaderBytes);
      setFeeInfo(blockHash, fee, recipient);
      uint remainingGas = msg.gas;

      
    }
  }
}
