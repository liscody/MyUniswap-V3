// This is a script for deployment and automatically verification of all the contracts (`contracts/`).

import hre from "hardhat";
const ethers = hre.ethers;

import type { LiquidityExamplesSepolia } from "../../typechain-types";

async function main() {
    const [deployer] = await ethers.getSigners();

    // Deploy UniswapV3 contract
    const LiquidityExamplesSepolia = (await ethers.getContractFactory("LiquidityExamplesSepolia")).connect(deployer);
    const les: LiquidityExamplesSepolia = await LiquidityExamplesSepolia.deploy(
        "0x1238536071E1c677A632429e3655c799b22cDA52"
    );
    await les.deployed();

    console.log("UniswapV3 deployed to : ", les.address);
    console.log("");

    // Verification of the deployed contract.
    if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
        console.log("Sleeping before verification...");
        await new Promise((resolve) => setTimeout(resolve, 60000)); // 60 seconds.

        await hre.run("verify:verify", { address: les.address, constructorArguments: [] });
    }

    return les;
}

// This pattern is recommended to be able to use async/await everywhere and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// deploy the contract
// npx hardhat run scripts/deployment/deployLiquidityExamplesSepolia.ts --network sepolia

// verify the contract
// npx hardhat verify --network sepolia 0x1da4e4855a04E0967f51b26b5bF7ADd50F247dB0 "0x1238536071E1c677A632429e3655c799b22cDA52"


// 0xf08A50178dfcDe18524640EA6618a1f965821715 usdc = sepolia 
// dai = 0x68194a729C2450ad26072b3D33ADaCbcef39D574