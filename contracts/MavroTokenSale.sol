pragma solidity ^0.4.0;

 /**
 * @title Mavro Token Sale
 *
 * https://mavro.org
 * 2018
 */
 
import './MavroToken.sol';
import '../installed_contracts/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../installed_contracts/zeppelin-solidity/contracts/ownership/Ownable.sol';

import "../installed_contracts/solidity-stringutils/strings.sol";
import './AbstractReferalExecutor.sol';
import './DumbExecutor.sol';


contract MavroTokenSale is Utils, Ownable {
    using strings for *;
    using SafeMath for uint256;


    uint256 constant   TOKEN_PRICE_D = 4700;                                 // Initial price in wei (denominator)
    uint256 constant  PERSONAL_LIMIT_WEI = 100000000000000000000;            // Personal limit at phase in wei
    uint256 constant   MIN_CONTRIBUTION_WEI = 9999999999999999;              // Minimum contribution in wei
    uint constant PHASES_COUNT = 2;                                          // Count of phases ICO (Pre-sale and ICO)
    address constant VAULT = 0xE56DcbbcD1c6E76B4315bCC67A229DD946Ce661b;     // First address of contribution funding
    address constant VAULT2 = 0x01924b31010dC4e4ba3E4a773BA4297e53f4056C;    // Second address of contribution funding
    uint256 constant BOUNTY_CAP_WEI = 40000000;                              // Bounty cap
    uint256 public  BOUNTY_TOTAL_WEI = 0;                                    // Bounty total in wei

    mapping(bytes32 => uint256)  callbackQueue;
    mapping(uint => uint)  refMultipliers;
    mapping(uint => PhaseParams) public  phases;
    
    /**
    * Creating object of MavroToken
    */
    MavroToken public token = new MavroToken();
    
    AbstractReferalExecutor abstractReferal =  new DumbExecutor();

    event newOraclizeQuery(string description);
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    event BountyPaid(address indexed beneficiar, uint256 amount);
    event ReferalExecutorChanged(address indexed executor);
    event FundsForwarded(address addr);

    struct PhaseParams {
        uint START_TIME;
        uint END_TIME;
        uint HARD_CAP;
        uint256 FUNDS_RAIZED;
        uint BONUS_MULTIPLIER;
    }

    /**
    * Initital MavroTokenSale function
    */
    function MavroTokenSale()
    {
        owner = msg.sender;
        
        /**
        * Massive of data for the Pre-sale phase
        *
        var prePhase = PhaseParams({
            START_TIME : 1516403990,
            END_TIME : 1519214400,
            HARD_CAP : 42589437800000000000000,
            BONUS_MULTIPLIER : 25,
            FUNDS_RAIZED : 0
            });

        /**
        * Massive of data for the ICO phase
        */
        var mainPhase = PhaseParams({
            START_TIME : 1521072000,
            END_TIME : 1523793600,
            HARD_CAP : 1010638297800000000000000,
            BONUS_MULTIPLIER : 0,
            FUNDS_RAIZED : 0
            });

        phases[0] = prePhase;
        phases[1] = mainPhase;
        refMultipliers[0] = 10;
        refMultipliers[1] = 5;
        refMultipliers[2] = 3;
        refMultipliers[3] = 2;
        refMultipliers[4] = 1;
    }

    // Fallback function, being executed when an investor sends Ethereum
    function() external payable {
        uint phaseIndex = getCurrentPhaseIndex();
        require(msg.value > MIN_CONTRIBUTION_WEI);
        require((phases[phaseIndex].FUNDS_RAIZED + msg.value) < phases[phaseIndex].HARD_CAP);

        buyTokens(msg.sender, msg.value, phaseIndex);

        forwardFunds();
    }

    // Function for the MVR offchain purchasing 
    function offchainPurchase(address beneficiar, uint256 WEIequity) public onlyOwner {
        buyTokens(beneficiar, WEIequity, getCurrentPhaseIndex());
    }

    // Function for transferring bounty bonus 
    function sendBountyBonus(address to, uint256 amount) onlyOwner {
        require(amount.add(BOUNTY_TOTAL_WEI) < BOUNTY_CAP_WEI);
        token.mint(to, amount);
        BOUNTY_TOTAL_WEI = BOUNTY_TOTAL_WEI.add(amount);
        BountyPaid(to, amount);
    }

    // Function for transferring the ownership of the crowdsale contract
    function transferTokenOwnership(address newOwner) public onlyOwner {
        token.transferOwnership(newOwner);
    }

    // Function for burning tokens
    function burnTokens(address victim, uint amount) public onlyOwner {
        token.burn(amount, victim);
    }

    // Function which switching the possibility of transfer   
    function switchTransfers() public onlyOwner {
        token.switchTransfers();
    }
    
    // Function which turning the address type to the string type
    function toString(address x) returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2 ** (8 * (19 - i)))));

        return string(b);
    }

    // Function for referral checkout
    function referalCheckout() onlyOwner {
        abstractReferal.phase();
    }

    // Function of the revaluation of the total investing amount  
    function totalRaized() public returns (uint256){
        uint256 raized = 0;
        for (uint i = 0; i < PHASES_COUNT; i++)
        {
            raized = raized.add(phases[i].FUNDS_RAIZED);

        }

        return raized;
    }

    // Function of token purchase
    function buyTokens(address beneficiar, uint256 amount, uint phaseIndex) internal {

        uint256 tokens = amount.mul(TOKEN_PRICE_D);
        phases[phaseIndex].FUNDS_RAIZED = phases[phaseIndex].FUNDS_RAIZED.add(amount);

        uint256 phase_bonus = tokens.div(100).mul(phases[phaseIndex].BONUS_MULTIPLIER);

        require(token.mint(beneficiar, tokens + phase_bonus));

        abstractReferal.once(beneficiar, amount);

        TokenPurchase(beneficiar, amount, tokens);
    }

    // Function for transferring Funds to fund
    function forwardFunds() internal {
        uint256 half = msg.value.div(2);
        VAULT.transfer(half);
        FundsForwarded(VAULT);
        VAULT2.transfer(msg.value.sub(half));
        FundsForwarded(VAULT2);
    }

    // Getting current phase index
    function getCurrentPhaseIndex() public view returns (uint){
        for (uint i = 0; i < PHASES_COUNT; i++)
        {
            if ((phases[i].START_TIME < now) && (phases[i].END_TIME > now)) {
                return i;
            }

            revert();
        }
    }

    // Setting for the referral logic
    function setAbstractReferalExecutor(address addr) onlyOwner {
        abstractReferal =  AbstractReferalExecutor(addr);
        require(abstractReferal.randomNumber() == 42);
        ReferalExecutorChanged(addr);
    }
    
    // Setting address of MavroToken contract
    function setToken(address addr) onlyOwner {
        token =  MavroToken(addr);

    }

}
