var MavroTokenSale = artifacts.require("MavroTokenSale");
var MavroToken = artifacts.require("MavroToken");

contract('MavroTokenSale', function(accounts) {

var owner = accounts[0]
var not_owner = accounts[4]
var not_owner1 = accounts[5]


it("Проверка выдачи бонусных токенов владельцем", function() {
    return MavroTokenSale.deployed().then(function(instance) {
      instance.sendBountyBonus.sendTransaction(not_owner, 1000, {from:owner})
      return instance.token()
    }).then(function(addr) {

        var Token = MavroToken.at(addr);
        return Token.balanceOf.call(not_owner)


    }).then(function(balance){
           assert.equal(1000, balance, "10000 Токенов должно быть насяльнике");
    });
  });

   it("Проверка подсчета тотала и несанкционнированного вызова", function() {
    return MavroTokenSale.deployed().then(function(instance) {
      instance.sendBountyBonus.sendTransaction(not_owner, 100, {from:not_owner1})
      instance.sendBountyBonus.sendTransaction(not_owner, 500, {from:owner})
      return instance
    }).then(function(instance) {
       return instance.BOUNTY_TOTAL_WEI.call()

    }).then(function(balance){
           assert.equal(1500, balance['c'][0], "Токнов быть не должно");
    });
  });


   it("Проверкапокупки и  реферальных отчислений", function() {
    return MavroTokenSale.deployed().then(function(instance) {
      instance.sendTransaction( {from:not_owner1,value:6000000})
      return instance.token()
    }).then(function(addr) {
       var tkn = MavroToken.at(addr)
        return tkn.balanceOf.call(not_owner1)
    }).then(function(balance){
           assert.equal(3525000000, balance['c'][0], "Токнов быть не должно");
    });
  });

});



