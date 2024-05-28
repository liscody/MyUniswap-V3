// // SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "hardhat/console.sol"; // todo remove this line in production

contract UniswapV3 is IERC721Receiver {
    /// @notice The Uniswap V3 Nonfungible Position Manager address
    address public constant U_V3_NonfungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    /// @notice The Uniswap V3 Swap Router address
    address public constant U_V3_SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    /// @notice The Uniswap V3 Factory address
    address public constant U_V3_Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    /// @notice The DAI token address
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    /// @notice The USDC token address
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    /// @notice The Uniswap V3 Factory
    IUniswapV3Factory public factory;

    /// @notice The Uniswap V3 Pool
    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    uint24 public constant poolFee = 3000;

    /// @notice Represents the deposit of an NFT
    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    /// @dev deposits[tokenId] => Deposit
    mapping(uint256 => Deposit) public deposits;

    uint256 public token_Id;

    constructor() {
        nonfungiblePositionManager = INonfungiblePositionManager(U_V3_NonfungiblePositionManager);
        factory = IUniswapV3Factory(U_V3_Factory);
    }

    function createFactoryPool(address token0, address token1) external returns (address pool) {
        console.log("");
        console.log("Contract: Function createFactoryPool called");
        console.log("Contract: token0 ", token0);
        console.log("Contract: token1 ", token1);
        pool = factory.getPool(token0, token1, poolFee);
        console.log("Contract: Get pool address: ", address(pool));
        if (pool == address(0)) {
            console.log("Create new pool, with token0, token1, poolFee: ", token0, token1, poolFee);
            pool = factory.createPool(token0, token1, poolFee);
        } else {
            console.log("Contract: Pool already exists");
        }

        console.log("Contract: Function executed successfully");
        console.log("");

        return pool;
    }

    function getPoolInfo(address token0, address token1) external view returns (address pool, int24 fee) {
        pool = factory.getPool(token0, token1, poolFee);
        fee = factory.feeAmountTickSpacing(poolFee);

        return (pool, fee);
    }

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information

        _createDeposit(operator, tokenId);

        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) = nonfungiblePositionManager.positions(
            tokenId
        );

        // set the owner and data for position
        // operator is msg.sender
        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }
}
