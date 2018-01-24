pragma solidity ^0.4.0;
import './AbstractReferalExecutor.sol';
contract DumbExecutor is AbstractReferalExecutor {
    function DumbExecutor(){

    }

    function once(address referal, uint256 sum) onlyOwner returns (bool){
        return true;
    }

    function phase() onlyOwner returns (bool){
        return true;
    }
}
