var MavroTokenSale = artifacts.require("./contracts/MavroTokenSale.sol");

module.exports = function(deployer) {
    deployer.deploy(MavroTokenSale);
};
