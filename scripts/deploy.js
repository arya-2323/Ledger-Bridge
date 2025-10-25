const hre = require("hardhat");

async function main() {
  const LedgerBridge = await hre.ethers.getContractFactory("LedgerBridge");
  const ledgerBridge = await LedgerBridge.deploy();
  await ledgerBridge.waitForDeployment();

  console.log("LedgerBridge deployed to:", await ledgerBridge.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
