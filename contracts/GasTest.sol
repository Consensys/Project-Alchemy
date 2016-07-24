contract GasTest{
  uint lastGas;
  uint calibration;
  event LogGas(string message, uint gas);

  function Log(string message){
      if(lastGas == 0){
        lastGas = msg.gas;
        calibrate();
      }
      LogGas(message, lastGas - msg.gas - calibration);
      lastGas = msg.gas;
  }

  function calibrate() private {
    uint gas = msg.gas;
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    Log("Testing 123");
    calibration = (gas-msg.gas)/30;
  }
}
