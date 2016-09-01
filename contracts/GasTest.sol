contract GasTest{
  uint lastGas;
  uint constant calibration = 5194;
  event LogGas(string message, int gas);

  function Log(string message){
      if(lastGas == 0){
        lastGas = msg.gas;
      }
      LogGas(message, int(lastGas - msg.gas - calibration));
      lastGas = msg.gas;
  }

  event LogVal(string message, bytes32 v);
}
