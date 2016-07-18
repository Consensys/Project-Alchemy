import "./blake2.sol";

contract EquihashValidator{
    BLAKE2b blake;

    function EquihashValidator(){
      blake = new BLAKE2b();
    }

    

}
