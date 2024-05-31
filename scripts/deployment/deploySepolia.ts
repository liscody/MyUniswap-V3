// This is a script for deployment and automatically verification of all the contracts (`contracts/`).

import hre from "hardhat";
const ethers = hre.ethers;

import type { UniswapV3Sepolia, LiquidityUniV3Sepolia } from "../../typechain-types";

async function main() {
    const [deployer] = await ethers.getSigners();

    // Deploy UniswapV3 contract
    const UniswapV3Sepolia = (await ethers.getContractFactory("UniswapV3Sepolia")).connect(deployer);
    const uni: UniswapV3Sepolia = await UniswapV3Sepolia.deploy();
    await uni.deployed();

    // // Deploy LiquidityUniV3 contract
    // const LiquidityUniV3Sepolia = (await ethers.getContractFactory("LiquidityUniV3Sepolia")).connect(deployer);
    // const liquidity: LiquidityUniV3Sepolia = await LiquidityUniV3Sepolia.deploy();
    // await liquidity.deployed();

    console.log("UniswapV3 deployed to : ", uni.address);
    console.log("");

    // Verification of the deployed contract.
    if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
        console.log("Sleeping before verification...");
        await new Promise((resolve) => setTimeout(resolve, 60000)); // 60 seconds.

        await hre.run("verify:verify", { address: uni.address, constructorArguments: [] });
    }

    return uni;
}

// This pattern is recommended to be able to use async/await everywhere and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// deploy the contract
// npx hardhat run scripts/deployment/deploySepolia.ts --network sepolia
// npx hardhat run scripts/deployment/deploySepolia.ts --network localhost

// liquidity contract address  0xA500ECa58323192899ee6A2917D640cf51a93Aa6

// version before (ignore it)
// liquidity contract address  0x275AA62bCE491312D5A172b7Db57B8Cf86906484
// liquidity contract address  0xB16d8d3329D08ba81A2BcE1B5Bd3b09e359C4C77
// liquidity contract address  0xecB2C6Cd53434ED124686e2a4D0BD5dDF584fC0B
