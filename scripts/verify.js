const addresses = require("../gemforge.deployments.json")

const hre = globalThis.hre;

(async () => {
  const { $ } = (await import('execa'))
  const rootFolder = process.cwd()

  const chainId = process.env.GEMFORGE_DEPLOY_CHAIN_ID;
  if (!chainId) {
    throw new Error("GEMFORGE_DEPLOY_CHAIN_ID env var not set");
  }

  // skip localhost
  if (chainId === "31337") {
    console.log("Skipping verification on localhost");
    return;
  }

  console.log(`Verifying on chain ${chainId} ...`);

  const networkName = Object.keys(hre.config.networks).find((name) => {
    return hre.config.networks[name].chainId === parseInt(chainId);
  });

  if (!networkName) {
    throw new Error(`No network name found for chain ${chainId}`);
  }

  console.log(`Network name: ${networkName}`);

  const contracts = addresses[chainId] || [];

  for (let { name, fullyQualifiedName, contract } of contracts) {
    let args = "";

    if (contract.constructorArgs.length) {
      args = contract.constructorArgs.join(", ")
    }

    console.log(
      `Verifying ${name} [${fullyQualifiedName}]  at ${ contract.address } with args ${args}`
    );

    if (args) {
      await $({ cwd: rootFolder })`npx hardhat verify --network ${networkName} --contract ${fullyQualifiedName} ${contract.address} ${args}`
    } else {
      await $({ cwd: rootFolder })`npx hardhat verify --network ${networkName} --contract ${fullyQualifiedName} ${contract.address}`
    }

    console.log(`Verified!`);
  }
})()
