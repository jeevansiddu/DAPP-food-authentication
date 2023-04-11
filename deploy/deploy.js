const { network, ethers } = require("hardhat");
module.exports = async (hre) => {
  const { deployments, getNamedAccounts } = hre;
  const chainId = network.config.chainId;
  const { deployer } = await getNamedAccounts();
  const { log, deploy } = deployments;
  const food_authentication = await deploy("food_authentication", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1,
  });
};
module.exports.tags = ["all"];
