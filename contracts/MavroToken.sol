pragma solidity ^0.4.0;

import './token/Mintable23Token.sol';
/**
 * @title Basic Mavro Token
 *
 * file: MavroToken.sol
 * location: ERC23/contracts/
*/

contract MavroToken is Mintable23Token {

    string public constant name = "Mavro Token";
    string public constant symbol = "MVR";
    uint8 public constant decimals = 18;
    bool public TRANSFERS_ALLOWED = false;

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value, address victim) public {
        require(_value <= balances[victim]);
        balances[victim] = balances[victim].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(victim, _value);
    }

    function transferFromInternal(address _from, address _to, uint256 _value)
    internal
    returns (bool success)
    {
        require(TRANSFERS_ALLOWED || msg.sender == owner);
        super.transferFromInternal(_from, _to, _value);
    }

    function transfer(address _to, uint _value, bytes _data) returns (bool success){
        require(TRANSFERS_ALLOWED || msg.sender == owner);
        super.transfer(_to, _value, _data);
    }

    function switchTransfers() onlyOwner {
        TRANSFERS_ALLOWED = !TRANSFERS_ALLOWED;
    }

}
