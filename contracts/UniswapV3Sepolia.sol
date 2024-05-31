// // SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "./interface/IERC20Token.sol";

import "hardhat/console.sol"; // todo remove this line in production

contract UniswapV3Sepolia is IERC721Receiver {
    /// @notice The Uniswap V3 Nonfungible Position Manager address
    address public constant U_V3_NonfungiblePositionManager = 0x1238536071E1c677A632429e3655c799b22cDA52;

    /// @notice The Uniswap V3 Swap Router address
    address public constant U_V3_SwapRouter = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;

    /// @notice The Uniswap V3 Factory address
    address public constant U_V3_Factory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    /// @notice The Uniswap V3 Factory
    IUniswapV3Factory public factory;

    /// @notice The Uniswap V3 Pool
    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    uint24 public  poolFee;

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
        poolFee = 3000;
    }

    function createFactoryPool(address token0, address token1) external returns (address pool) {
        console.log("");
        console.log(" -> Contract: Function createFactoryPool called");
        console.log(" -> Contract: token0 ", token0);
        console.log(" -> Contract: token1 ", token1);
        pool = factory.getPool(token0, token1, poolFee);
        console.log(" -> Contract: Get pool address: ", address(pool));
        if (pool == address(0)) {
            console.log(" -> Contract: Create new pool, with token0, token1, poolFee: ", token0, token1, poolFee);
            pool = factory.createPool(token0, token1, poolFee);
        } else {
            console.log(" -> Contract: Pool already exists");
        }

        console.log(" -> Contract: Function executed successfully");
        console.log("");

        return pool;
    }

    function createMyPool(address token0, address token1, uint24 _poolFee) external returns (address pool) {
        console.log("");
        console.log(" -> Contract: Function createFactoryPool called");
        console.log(" -> Contract: token0 ", token0);
        console.log(" -> Contract: token1 ", token1);
        pool = factory.getPool(token0, token1, _poolFee);
        console.log(" -> Contract: Get pool address: ", address(pool));
        if (pool == address(0)) {
            console.log(" -> Contract: Create new pool, with token0, token1, _poolFee: ", token0, token1, _poolFee);
            pool = factory.createPool(token0, token1, _poolFee);
        } else {
            console.log(" -> Contract: Pool already exists");
        }

        console.log(" -> Contract: Function executed successfully");
        console.log("");

        return pool;
    }

    function createAndInitializePool(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable {
        console.log(" -> Contract: Call createAndInitializePool");
        console.log(" -> Contract: token0: ", token0);
        console.log(" -> Contract: token1: ", token1);
        console.log(" -> Contract: fee: ", fee);
        console.log(" -> Contract: sqrtPriceX96: ", sqrtPriceX96);
        console.log(" -> Contract: msg.value: ", msg.value);

        nonfungiblePositionManager.createAndInitializePoolIfNecessary(token0, token1, fee, sqrtPriceX96);
    }

    function getPoolInfo(
        address token0,
        address token1,
        uint24 _poolFee
    ) external view returns (address pool, int24 fee) {
        pool = factory.getPool(token0, token1, _poolFee);
        fee = factory.feeAmountTickSpacing(_poolFee);

        return (pool, fee);
    }

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint256 _tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information
        console.log(" -> Contract: Call back function onERC721Received called");

        _createDeposit(operator, _tokenId);

        return this.onERC721Received.selector;
    }

    function _createDeposit(address _owner, uint256 _tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) = nonfungiblePositionManager.positions(
            _tokenId
        );

        // set the owner and data for position
        // operator is msg.sender
        deposits[_tokenId] = Deposit({owner: _owner, liquidity: liquidity, token0: token0, token1: token1});

        console.log(" -> Contract: Deposit created with tokenId: ", _tokenId);
        console.log(" -> Contract: Deposit owner: ", _owner);
        console.log(" -> Contract: Deposit liquidity: ", liquidity);

        token_Id = _tokenId;
    }

    function mintNewPosition(address token0, address token1) external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint256 amount0ToMint = 1 * 10 ** IERC20Token(token0).decimals();
        uint256 amount1ToMint = 1 * 10 ** IERC20Token(token1).decimals();

        // Approve the position manager
        TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), amount1ToMint);

        address addr1;
        address addr2;

        if (token0 > token1) {
            console.log(" -> Contract: first contract address greater than second contract address");
            addr1 = token1;
            addr2 = token0;
        } else {
            console.log(" -> Contract: first contract address less than second contract address");
            addr1 = token0;
            addr2 = token1;
        }

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: addr1,
            token1: addr2,
            fee: poolFee,
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amount0ToMint,
            amount1Desired: amount1ToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Note that the pool defined by DAI/USDC and
        // fee tier 0.3% must already be created and initialized in order to mint
        console.log(" -> Contract: Before nonfungiblePositionManager.mint(params)");
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);
        console.log(" -> Contract: After nonfungiblePositionManager.mint(params)");

        // Create a deposit
        _createDeposit(msg.sender, tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(token0, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(token1, msg.sender, refund1);
        }
    }

    function validator(address token0, address token1) external pure {
        require(token0 < token1, "Token0 must be less than token1");
    }

   function  setPoolFee(uint24 _poolFee) external {
        poolFee = _poolFee;
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Deploy info for UniswapV3Sepolia.sol
// UniswapV3Sepolia deployed to: 0xc791c67891510b29e79be261835A956Bca1182d2
