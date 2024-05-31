import type { SnapshotRestorer } from "@nomicfoundation/hardhat-network-helpers";
import { takeSnapshot, setBalance } from "@nomicfoundation/hardhat-network-helpers";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

import { expect } from "chai";
import { ethers } from "hardhat";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import type { UniswapV3CustomToken, IERC20, TokenOne, TokenTwo } from "../typechain-types";
import config from "../hardhat.config";

if (config.networks?.hardhat?.forking?.enabled) {
    console.log("Fork", config.networks?.hardhat?.forking?.enabled);
    describe("UniswapV3 custom tokens add liquidity", function () {
        let snapshotA: SnapshotRestorer;

        // Signers.
        let deployer: SignerWithAddress, owner: SignerWithAddress, user: SignerWithAddress;
        let newDaiOwner: SignerWithAddress;
        let newUsdcOwner: SignerWithAddress;

        // Contracts.
        let uni: UniswapV3CustomToken;

        let token0: TokenOne;
        let token1: TokenTwo;

        let ownerBalance_token0: any;
        let ownerBalance_token1: any;

        let addr1: any;
        let addr2: any;

        before(async () => {
            // Getting of signers.
            [deployer, owner, user, newDaiOwner, newUsdcOwner] = await ethers.getSigners();
            owner = deployer;
            //////////////////////////////////////////////////////////////////////////////////////////
            /// ---------- Deploy contract ---------- /////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////////
            // Deploy TokenOne contract
            const TokenOne = await ethers.getContractFactory("TokenOne");
            token0 = (await TokenOne.deploy(owner.address)) as TokenOne;
            await token0.deployed();
            console.log("TokenOne deployed to : ", token0.address);
            // Deploy TokenTwo contract
            const TokenTwo = await ethers.getContractFactory("TokenTwo");
            token1 = (await TokenTwo.deploy(owner.address)) as TokenTwo;
            await token1.deployed();
            console.log("TokenTwo deployed to : ", token1.address);
            console.log("");

            // check balance of owner
            console.log("Check balance of owner after deploy tokens");
            ownerBalance_token0 = await token0.balanceOf(owner.address);
            console.log("Balance of owner (token0) : ", ownerBalance_token0.toString());
            ownerBalance_token1 = await token1.balanceOf(owner.address);
            console.log("Balance of owner (token1) : ", ownerBalance_token1.toString());
            console.log("");

            // Deploy UniswapV3 contract
            const UniswapV3 = await ethers.getContractFactory("UniswapV3CustomToken");
            uni = (await UniswapV3.deploy(token0.address, token1.address)) as UniswapV3CustomToken;
            await uni.deployed();
            console.log("UniswapV3 deployed to : ", uni.address);
            console.log("");

            // check balance of owner
            console.log("Check balance of owner after deploy UniswapV3");
            ownerBalance_token0 = await token0.balanceOf(owner.address);
            console.log("Balance of owner (token0) : ", ownerBalance_token0.toString());
            ownerBalance_token1 = await token1.balanceOf(owner.address);
            console.log("Balance of owner (token1) : ", ownerBalance_token1.toString());
            console.log("");

            snapshotA = await takeSnapshot();
        });

        afterEach(async () => await snapshotA.restore());

        describe("# Scenarios: full process", function () {
            it("Create & init pool on Uniswap V3 pair", async () => {
                console.log("");
                console.log("=============== START ======================");
                console.log("");
                console.log("Test. Step 1: Get tokens addresses for create pair on Uniswap V3 ");
                console.log("---------- *** ----------");
                console.log("Test. Token 1 : TokenOne", token0.address);
                console.log("Test. Token 2 : TokenTwo", token1.address);
                console.log("");

                console.log("Test. Step 2: Validate order of tokens addresses for create pair on Uniswap V3 ");
                console.log("---------- *** ----------");
                if (token0.address > token1.address) {
                    console.log("Token 1 is less than Token 2");
                    addr1 = token1.address;
                    addr2 = token0.address;
                } else {
                    console.log("Token 2 is less than Token 1");
                    addr1 = token0.address;
                    addr2 = token1.address;
                }
                console.log("");

                console.log("Test. Step 3: Create & initialize pool on Uniswap V3 pair");
                console.log("---------- *** ----------");
                console.log("");

                const fee = 3000;
                const tx = await uni.createAndInitializePool(addr1, addr2, fee, 5295128739, {
                    value: ethers.utils.parseEther("0.0")
                });
                console.log("");
                console.log("Test. Pool created");
                console.log("");

                console.log("Test. Step 4: Get pool info");
                console.log("---------- *** ----------");
                console.log("Test. tx hash : ", tx.hash);

                console.log("");
                // get pool info
                const pool = await uni.getPoolInfo(addr1, addr2, fee);
                console.log("Test. Pool info : ", pool);
                console.log("");
            });

            it("Validation for Uniswap V3 pair", async () => {
                console.log("Test. Step 1: Validation for Uniswap V3 pair");
                console.log("Test. Token 1 : TokenOne", token0.address);
                console.log("Test. Token 2 : TokenTwo", token1.address);
                console.log("");

                // check (token0.address< token1.address) or (token1.address < token0.address)

                if (token0.address > token1.address) {
                    console.log("Token 1 is less than Token 2");
                    addr1 = token1.address;
                    addr2 = token0.address;
                } else {
                    console.log("Token 2 is less than Token 1");
                    addr1 = token0.address;
                    addr2 = token1.address;
                }

                await uni.validator(addr1, addr2);
            });

            // this function not working properly
            // Create pool on Uniswap V3 pair:
            // Error: VM Exception while processing transaction: reverted with reason string 'LOK'
            xit("Create pool on Uniswap V3 pair", async () => {
                console.log("Test. Step 1: Create pool on Uniswap V3 pair");
                console.log("Test. Token 1 : TokenOne", token0.address);
                console.log("Test. Token 2 : TokenTwo", token1.address);
                console.log("");

                await uni.createFactoryPool(token0.address, token1.address);
                console.log("Test. Pool created");
                console.log("");
                // get pool info
                const poolFee = await uni.poolFee();
                const pool = await uni.getPoolInfo(token0.address, token1.address, poolFee);
                console.log("Test. Pool info : ", pool);
                console.log("");

                // check balance of owner
                console.log("Check balance of owner after create pool");
                ownerBalance_token0 = await token0.balanceOf(owner.address);
                console.log("Balance of owner (token0) : ", ownerBalance_token0.toString());
                console.log("");
                ownerBalance_token1 = await token1.balanceOf(owner.address);
                console.log("Balance of owner (token1) : ", ownerBalance_token1.toString());
                console.log("");

                console.log("Test. Step 2: Transfer token1 to uni contract");
                console.log("Test. Transfer token1 to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balance = await token0.balanceOf(uni.address);
                console.log("Test. Balance in token1 before transfer: ", balance.toString());
                // get owner balance
                const ownerBalance = await token0.balanceOf(owner.address);
                console.log("Test. Owner balance in token1 before transfer: ", ownerBalance.toString());
                // transfer token to uni contract
                await token0.connect(owner).transfer(uni.address, ethers.utils.parseUnits("1", 18));
                console.log("Test. Transfer token1 to uni contract");

                // check uni contract balance after transfer
                const balanceAfter = await token0.balanceOf(uni.address);
                console.log("Test. Balance in token1 after transfer : ", balanceAfter.toString());

                console.log("Test. Step 3: Transfer token2 to uni contract");
                console.log("Test. Transfer token2 to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balanceUsdc = await token1.balanceOf(uni.address);
                console.log("Test. Balance in token2 before transfer: ", balanceUsdc.toString());
                // transfer token to uni contract
                // todo: get answer for this
                // why we need to transfer again?
                const newBalance = ethers.utils.parseUnits("100000", 18);
                await setBalance(owner.address, newBalance);
                await token1.connect(owner).transfer(uni.address, ethers.utils.parseUnits("1", 18));
                console.log("Test. Transfer token2 to uni contract");
                // check uni contract balance after transfer
                const balanceUsdcAfter = await token1.balanceOf(uni.address);
                console.log("Test. Balance in token2 after transfer : ", balanceUsdcAfter.toString());

                console.log("Test. Step 4: Mint new position");
                console.log("Test. Mint new position");
                console.log("");

                // mintNewPosition
                const tx = await uni.mintNewPosition();
                console.log("");
                console.log("Test. Mint new position tx : ", tx.hash);
                console.log("");
            });

            it.only("Create & init pool on Uniswap V3 pair with mint New Position ", async () => {
                console.log("");
                console.log("=============== START ======================");
                console.log("");
                console.log("Test. Step 1: Get tokens addresses for create pair on Uniswap V3 ");
                console.log("---------- *** ----------");
                console.log("Test. Token 1 : TokenOne", token0.address);
                console.log("Test. Token 2 : TokenTwo", token1.address);
                console.log("");

                console.log("Test. Step 2: Validate order of tokens addresses for create pair on Uniswap V3 ");
                console.log("---------- *** ----------");
                if (token0.address > token1.address) {
                    console.log("Token 1 is less than Token 2");
                    addr1 = token1.address;
                    addr2 = token0.address;
                } else {
                    console.log("Token 2 is less than Token 1");
                    addr1 = token0.address;
                    addr2 = token1.address;
                }
                console.log("");

                console.log("Test. Step 3: Create & initialize pool on Uniswap V3 pair");
                console.log("---------- *** ----------");
                console.log("");

                const fee = 3000;
                const tx = await uni.createAndInitializePool(addr1, addr2, fee, 5295128739, {
                    value: ethers.utils.parseEther("0.0")
                });
                console.log("");
                console.log("Test. Pool created");
                console.log("");

                console.log("Test. Step 4: Get pool info");
                console.log("---------- *** ----------");
                console.log("Test. tx hash : ", tx.hash);

                console.log("");
                // get pool info
                const pool = await uni.getPoolInfo(addr1, addr2, fee);
                console.log("Test. Pool info : ", pool);
                console.log("");

                console.log("Test. Step 2: Transfer token1 to uni contract");
                console.log("Test. Transfer token1 to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balance = await token0.balanceOf(uni.address);
                console.log("Test. Balance in token1 before transfer: ", balance.toString());
                // get owner balance
                const ownerBalance = await token0.balanceOf(owner.address);
                console.log("Test. Owner balance in token1 before transfer: ", ownerBalance.toString());
                // transfer token to uni contract
                await token0.connect(owner).transfer(uni.address, ethers.utils.parseUnits("1", 18));
                console.log("Test. Transfer token1 to uni contract");

                // check uni contract balance after transfer
                const balanceAfter = await token0.balanceOf(uni.address);
                console.log("Test. Balance in token1 after transfer : ", balanceAfter.toString());

                console.log("Test. Step 3: Transfer token2 to uni contract");
                console.log("Test. Transfer token2 to uni contract");
                console.log("");

                // check uni contract balance before transfer
                const balanceUsdc = await token1.balanceOf(uni.address);
                console.log("Test. Balance in token2 before transfer: ", balanceUsdc.toString());
                // transfer token to uni contract
                // todo: get answer for this
                // why we need to transfer again?
                const newBalance = ethers.utils.parseUnits("100000", 18);
                await setBalance(owner.address, newBalance);
                await token1.connect(owner).transfer(uni.address, ethers.utils.parseUnits("1", 18));
                console.log("Test. Transfer token2 to uni contract");
                // check uni contract balance after transfer
                const balanceUsdcAfter = await token1.balanceOf(uni.address);
                console.log("Test. Balance in token2 after transfer : ", balanceUsdcAfter.toString());

                console.log("Test. Step 4: Mint new position");
                console.log("Test. Mint new position");
                console.log("");

                // mintNewPosition
                const tx2 = await uni.mintNewPosition();
                console.log("");
                console.log("Test. Mint new position tx : ", tx2.hash);
                console.log("");
            });

        });
    });
} else {
    console.log("FORK is Inactive");
    console.log("The Raffle.test.js assume the launch on the hardhat network only.");
}
