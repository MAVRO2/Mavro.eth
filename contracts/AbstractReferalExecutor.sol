pragma solidity ^0.4.0;
import '../installed_contracts/zeppelin-solidity/contracts/ownership/Ownable.sol';


contract AbstractReferalExecutor is Ownable {

    function once(address referal, uint256 sum) onlyOwner returns (bool);
    function phase() onlyOwner returns (bool);

    function randomNumber() view onlyOwner returns (uint){
        return 42;
    }


}