# Solidity API

## LiquidityExamples

### U_V3_NonfungiblePositionManager

```solidity
address U_V3_NonfungiblePositionManager
```

The Uniswap V3 Nonfungible Position Manager address

### U_V3_SwapRouter

```solidity
address U_V3_SwapRouter
```

The Uniswap V3 Swap Router address

### U_V3_Factory

```solidity
address U_V3_Factory
```

The Uniswap V3 Factory address

### factory

```solidity
contract IUniswapV3Factory factory
```

### DAI

```solidity
address DAI
```

### USDC

```solidity
address USDC
```

### poolFee

```solidity
uint24 poolFee
```

### nonfungiblePositionManager

```solidity
contract INonfungiblePositionManager nonfungiblePositionManager
```

### Deposit

```solidity
struct Deposit {
  address owner;
  uint128 liquidity;
  address token0;
  address token1;
}
```

### deposits

```solidity
mapping(uint256 => struct LiquidityExamples.Deposit) deposits
```

_deposits[tokenId] => Deposit_

### constructor

```solidity
constructor() public
```

### createFactoryPool

```solidity
function createFactoryPool(address token0, address token1) external returns (address pool)
```

### getPoolInfo

```solidity
function getPoolInfo(address token0, address token1) external view returns (address pool, int24 fee)
```

### onERC721Received

```solidity
function onERC721Received(address operator, address, uint256 tokenId, bytes) external returns (bytes4)
```

### _createDeposit

```solidity
function _createDeposit(address owner, uint256 tokenId) internal
```

### mintNewPosition

```solidity
function mintNewPosition() external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
```

Calls the mint function defined in periphery, mints the same amount of each token. For this example we are providing 1000 DAI and 1000 USDC in liquidity

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the newly minted ERC721 |
| liquidity | uint128 | The amount of liquidity for the position |
| amount0 | uint256 | The amount of token0 |
| amount1 | uint256 | The amount of token1 |

