// // SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface UniswapV3CustomTokenSepolia is IERC721Receiver {
    function createFactoryPool(address token0, address token1) external returns (address pool);

    function createMyPool(address token0, address token1, uint24 _poolFee) external returns (address pool);

    function createAndInitializePool(address token0, address token1, uint24 fee, uint160 sqrtPriceX96) external payable;

    function getPoolInfo(
        address token0,
        address token1,
        uint24 _poolFee
    ) external view returns (address pool, int24 fee);

    function onERC721Received(
        address operator,
        address,
        uint256 _tokenId,
        bytes calldata
    ) external override returns (bytes4);

    function mintNewPosition(
        address token0,
        address token1
    ) external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    function validator(address token0, address token1) external pure;
}
