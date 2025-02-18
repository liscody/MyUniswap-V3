// This script contains the function for deployment and verification of the `contracts/PositiveEvenSetter.sol`.

import hre from "hardhat";
const ethers = hre.ethers;

import type { UniswapV3Sepolia } from "../../../../typechain-types";

async function deployPositiveEvenSetter(): Promise<UniswapV3Sepolia> {
    /*
     * Hardhat always runs the compile task when running scripts with its command line interface.
     *
     * If this script is run directly using `node`, then it should be called compile manually
     * to make sure everything is compiled.
     */
    // await hre.run("compile");

    const [deployer] = await ethers.getSigners();

    // Deploy UniswapV3 contract
    const UniswapV3Sepolia = (await ethers.getContractFactory("UniswapV3Sepolia")).connect(deployer);
    const uni: UniswapV3Sepolia = await UniswapV3Sepolia.deploy();
    await uni.deployed();

    console.log("UniswapV3 deployed to : ", uni.address);
    console.log("");
    console.log(`\`positiveEvenSetter\` is deployed to ${uni.address}.`);

    // Verification of the deployed contract.
    if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
        console.log("Sleeping before verification...");
        await new Promise((resolve) => setTimeout(resolve, 60000)); // 60 seconds.

        await hre.run("verify:verify", { address: uni.address, constructorArguments: [] });
    }

    return uni;
}

export { UniswapV3Sepolia };

// deployUniswapV3CustomTokenSepolia.ts
