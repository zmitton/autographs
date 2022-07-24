const Autographs = artifacts.require("Autographs");

module.exports = function (deployer) {
  deployer.deploy(Autographs);
};
