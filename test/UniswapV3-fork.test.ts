import type { SnapshotRestorer } from "@nomicfoundation/hardhat-network-helpers";
import { takeSnapshot, setBalance } from "@nomicfoundation/hardhat-network-helpers";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

import { expect } from "chai";
import { ethers } from "hardhat";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import type { UniswapV3, IERC20 } from "../typechain-types";
import config from "../hardhat.config";

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";

const dai_whale = "0x28C6c06298d514Db089934071355E5743bf21d60";
const usdc_whale = "0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa";

if (config.networks?.hardhat?.forking?.enabled) {
    console.log("Fork", config.networks?.hardhat?.forking?.enabled);
    describe("UniswapV3 add liquidity", function () {
        let snapshotA: SnapshotRestorer;

        // Signers.
        let deployer: SignerWithAddress, owner: SignerWithAddress, user: SignerWithAddress;
        let newDaiOwner: SignerWithAddress;
        let newUsdcOwner: SignerWithAddress;

        // Contracts.
        let uni: UniswapV3;

        let dai: IERC20;
        let usdc: IERC20;

        before(async () => {
            // Getting of signers.
            [deployer, owner, user, newDaiOwner, newUsdcOwner] = await ethers.getSigners();
            //////////////////////////////////////////////////////////////////////////////////////////
            /// ---------- hardhat set balance ---------- ////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            const newBalance = ethers.utils.parseEther("100000000000");
            // set ETH balance to user1 by hardhat setter
            await setBalance(deployer.address, newBalance);
            await setBalance(owner.address, newBalance);
            await setBalance(newDaiOwner.address, newBalance);
            await setBalance(newUsdcOwner.address, newBalance);

            //////////////////////////////////////////////////////////////////////////////////////////
            /// ---------- Validate the balance of the account ---------- ////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            const balance = await ethers.provider.getBalance(deployer.address);
            const balanceOwner = await ethers.provider.getBalance(owner.address);
            const balanceDai = await ethers.provider.getBalance(newDaiOwner.address);
            const balanceUsdc = await ethers.provider.getBalance(newUsdcOwner.address);
            console.log("Balance deployer : ", balance.toString());
            console.log("Balance owner : ", balanceOwner.toString());
            console.log("Balance newDaiOwner : ", balanceDai.toString());
            console.log("Balance newUsdcOwner : ", balanceUsdc.toString());
            console.log("");

            //////////////////////////////////////////////////////////////////////////////////////////
            /// ---------- Get contract and impersonate account ---------- ///////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            dai = await ethers.getContractAt("IERC20", DAI);
            usdc = await ethers.getContractAt("IERC20", USDC);
            // get whale balances
            const dai_balance = await dai.balanceOf(dai_whale);
            const usdc_balance = await usdc.balanceOf(usdc_whale);
            console.log("Whale balances");
            console.log("DAI balance : ", dai_balance);
            console.log("USDC balance : ", usdc_balance);
            console.log("");

            // impersonate account
            await helpers.impersonateAccount(dai_whale);
            newDaiOwner = await ethers.getSigner(dai_whale);
            // impersonate account
            await helpers.impersonateAccount(usdc_whale);
            newUsdcOwner = await ethers.getSigner(usdc_whale);

            //////////////////////////////////////////////////////////////////////////////////////////
            /// ---------- Deploy contract ---------- /////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            const UniswapV3 = await ethers.getContractFactory("UniswapV3");
            uni = (await UniswapV3.deploy()) as UniswapV3;
            await uni.deployed();
            console.log("UniswapV3 deployed to : ", uni.address);
            console.log("");

            owner = deployer;
            snapshotA = await takeSnapshot();
        });

        afterEach(async () => await snapshotA.restore());

        describe("# Scenarios: full process", function () {
            it.only("Create pool on Uniswap V3 pair", async () => {
                console.log("Test. Step 1: Create pool on Uniswap V3 pair");
                console.log("Test. Token 1 : DAI", DAI);
                console.log("Test. Token 2 : USDC", USDC);
                console.log("");
                await uni.createFactoryPool(DAI, USDC);
                console.log("Test. Pool created");
                console.log("");
                // get pool info
                const pool = await uni.getPoolInfo(DAI, USDC);
                console.log("Test. Pool info : ", pool);
                console.log("");

                console.log("Test. Step 2: Transfer DAI to uni contract");
                console.log("Test. Transfer DAI to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balance = await dai.balanceOf(uni.address);
                console.log("Test. Balance in DAI before transfer: ", balance.toString());
                // transfer token to uni contract
                await dai.connect(newDaiOwner).transfer(uni.address, ethers.utils.parseUnits("1", 18));
                console.log("Test. Transfer DAI to uni contract");
                // check uni contract balance after transfer
                const balanceAfter = await dai.balanceOf(uni.address);
                console.log("Test. Balance in DAI after transfer : ", balanceAfter.toString());

                console.log("Test. Step 3: Transfer USDC to uni contract");
                console.log("Test. Transfer USDC to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balanceUsdc = await usdc.balanceOf(uni.address);
                console.log("Test. Balance in USDC before transfer: ", balanceUsdc.toString());
                // transfer token to uni contract
                // todo: get answer for this
                // why we need to transfer again?
                const newBalance = ethers.utils.parseUnits("100000", 18);
                await setBalance(newUsdcOwner.address, newBalance);
                await usdc.connect(newUsdcOwner).transfer(uni.address, ethers.utils.parseUnits("1", 6));
                console.log("Test. Transfer USDC to uni contract");
                // check uni contract balance after transfer
                const balanceUsdcAfter = await usdc.balanceOf(uni.address);
                console.log("Test. Balance in USDC after transfer : ", balanceUsdcAfter.toString());

                console.log("Test. Step 4: Mint new position");
                console.log("Test. Mint new position");
                console.log("");

                // // mintNewPosition
                // const result = await uni.mintNewPosition();
                // console.log("result", result);
            });
        });
    });
} else {
    console.log("FORK is Inactive");
    console.log("The Raffle.test.js assume the launch on the hardhat network only.");
}
