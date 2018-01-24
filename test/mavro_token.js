var MavroTokenSale = artifacts.require("MavroTokenSale");
var MavroToken = artifacts.require("MavroToken");

contract('MavroToken', function(accounts) {

var owner = accounts[0]
var not_owner = accounts[4]
var not_owner1 = accounts[5]


it("Проверка выпуска токенов владельцеми  трансфера пользователем", function() {
    return MavroTokenSale.deployed().then(function(instance) {
      instance.sendBountyBonus.sendTransaction(not_owner, 800, {from:owner})
      return instance.token()
    }).then(function(addr) {

        var Token = MavroToken.at(addr);
        Token.transfer.sendTransaction(not_owner1,100,{from:not_owner})
        return Token.balanceOf.call(not_owner)

    }).then(function(balance){
           assert.equal(800, balance['c'][0], "800 Токенов должно быть насяльнике");
    });
  });

   it("Проверка запрета передачи токенов", function() {
    return MavroTokenSale.deployed().then(function(instance) {
        instance.switchTransfers()

      return instance.token()
    }).then(function(addr) {

       var Token = MavroToken.at(addr);
       Token.transfer.sendTransaction(not_owner1,100,{from:not_owner});

       return Token.balanceOf(not_owner1);
    }).then(function(balance){
        assert.equal(100, balance['c'][0], "Токнов быть не должно");
    });
  });

});