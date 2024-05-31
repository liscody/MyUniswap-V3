// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol";
import "hardhat/console.sol";

contract LiquidityUniV3Sepolia is IERC721Receiver {
    address public constant TOKENT_ONE = 0x70D0a1e31E0227747B120BbE6aA6E2bc2442eD0f;
    address public constant TOKEN_TWO = 0x5EC4d20a83771C685F8d346Af3789Bf08a86E3a2;

    // 0.01% fee
    uint24 public poolFee;

    INonfungiblePositionManager public nonfungiblePositionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

    /// @notice Represents the deposit of an NFT
    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    /// @dev deposits[tokenId] => Deposit
    mapping(uint => Deposit) public deposits;

    // Store token id used in this example
    uint public tokenId;

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint _tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        _createDeposit(operator, _tokenId);
        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint _tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) = nonfungiblePositionManager.positions(
            _tokenId
        );
        // set the owner and data for position
        // operator is msg.sender
        deposits[_tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});

        console.log("Token id", _tokenId);
        console.log("Liquidity", liquidity);

        tokenId = _tokenId;
    }

    function mintNewPosition() external returns (uint _tokenId, uint128 liquidity, uint amount0, uint amount1) {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint amount0ToMint = 100 * 1e18;
        uint amount1ToMint = 100 * 1e18;

        // Approve the position manager
        TransferHelper.safeApprove(TOKENT_ONE, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(TOKEN_TWO, address(nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: TOKENT_ONE,
            token1: TOKEN_TWO,
            fee: poolFee,
            // By using TickMath.MIN_TICK and TickMath.MAX_TICK,
            // we are providing liquidity across the whole range of the pool.
            // Not recommended in production.
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amount0ToMint,
            amount1Desired: amount1ToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Note that the pool defined by TOKENT_ONE/USDC and fee tier 0.01% must
        // already be created and initialized in order to mint
        (_tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Create a deposit
        _createDeposit(msg.sender, _tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(TOKENT_ONE, address(nonfungiblePositionManager), 0);
            uint refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(TOKENT_ONE, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(TOKEN_TWO, address(nonfungiblePositionManager), 0);
            uint refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(TOKEN_TWO, msg.sender, refund1);
        }
    }

    function mintNewPositionVersion2(
        address token_one,
        address token_two
    ) external returns (uint _tokenId, uint128 liquidity, uint amount0, uint amount1) {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint amount0ToMint = 100 * 1e18;
        uint amount1ToMint = 100 * 1e18;

        // Approve the position manager
        TransferHelper.safeApprove(token_one, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(token_two, address(nonfungiblePositionManager), amount1ToMint);

        address addr1;
        address addr2;

        if (token_one > token_two) {
            console.log(" -> Contract: first contract address greater than second contract address");
            addr1 = token_two;
            addr2 = token_one;
        } else {
            console.log(" -> Contract: first contract address less than second contract address");
            addr1 = token_one;
            addr2 = token_two;
        }

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: addr1,
            token1: addr2,
            fee: poolFee,
            // By using TickMath.MIN_TICK and TickMath.MAX_TICK,
            // we are providing liquidity across the whole range of the pool.
            // Not recommended in production.
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amount0ToMint,
            amount1Desired: amount1ToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Note that the pool defined by TOKENT_ONE/USDC and fee tier 0.01% must
        // already be created and initialized in order to mint
        (_tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Create a deposit
        _createDeposit(msg.sender, _tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(TOKENT_ONE, address(nonfungiblePositionManager), 0);
            uint refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(TOKENT_ONE, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(TOKEN_TWO, address(nonfungiblePositionManager), 0);
            uint refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(TOKEN_TWO, msg.sender, refund1);
        }
    }

    function mintNewPositionVersion3(
        address token_one,
        address token_two,
        uint256 income1,
        uint256 income2
    ) external returns (uint _tokenId, uint128 liquidity, uint amount0, uint amount1) {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint amount0ToMint = income1 * 1e18;
        uint amount1ToMint = income2 * 1e18;

        // Approve the position manager
        TransferHelper.safeApprove(token_one, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(token_two, address(nonfungiblePositionManager), amount1ToMint);

        address addr1;
        address addr2;

        if (token_one > token_two) {
            console.log(" -> Contract: first contract address greater than second contract address");
            addr1 = token_two;
            addr2 = token_one;
        } else {
            console.log(" -> Contract: first contract address less than second contract address");
            addr1 = token_one;
            addr2 = token_two;
        }

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: addr1,
            token1: addr2,
            fee: poolFee,
            // By using TickMath.MIN_TICK and TickMath.MAX_TICK,
            // we are providing liquidity across the whole range of the pool.
            // Not recommended in production.
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amount0ToMint,
            amount1Desired: amount1ToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Note that the pool defined by TOKENT_ONE/USDC and fee tier 0.01% must
        // already be created and initialized in order to mint
        (_tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Create a deposit
        _createDeposit(msg.sender, _tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(TOKENT_ONE, address(nonfungiblePositionManager), 0);
            uint refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(TOKENT_ONE, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(TOKEN_TWO, address(nonfungiblePositionManager), 0);
            uint refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(TOKEN_TWO, msg.sender, refund1);
        }
    }

    function collectAllFees() external returns (uint256 amount0, uint256 amount1) {
        // set amount0Max and amount1Max to uint256.max to collect all fees
        // alternatively can set recipient to msg.sender and avoid another transaction in `sendToOwner`
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        console.log("fee 0", amount0);
        console.log("fee 1", amount1);
    }

    function increaseLiquidityCurrentRange(
        uint256 amountAdd0,
        uint256 amountAdd1
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
        TransferHelper.safeTransferFrom(TOKENT_ONE, msg.sender, address(this), amountAdd0);
        TransferHelper.safeTransferFrom(TOKEN_TWO, msg.sender, address(this), amountAdd1);

        TransferHelper.safeApprove(TOKENT_ONE, address(nonfungiblePositionManager), amountAdd0);
        TransferHelper.safeApprove(TOKEN_TWO, address(nonfungiblePositionManager), amountAdd1);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amountAdd0,
                amount1Desired: amountAdd1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);

        console.log("liquidity", liquidity);
        console.log("amount 0", amount0);
        console.log("amount 1", amount1);
    }

    function getLiquidity(uint _tokenId) external view returns (uint128) {
        (, , , , , , , uint128 liquidity, , , , ) = nonfungiblePositionManager.positions(_tokenId);
        return liquidity;
    }

    function decreaseLiquidity(uint128 liquidity) external returns (uint amount0, uint amount1) {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
            .DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);

        console.log("amount 0", amount0);
        console.log("amount 1", amount1);
    }

    function setPoolFee(uint24 _poolFee) external {
        poolFee = _poolFee;
    }
}
