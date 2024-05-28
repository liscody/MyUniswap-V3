# Solidity API

## UniswapV3Liquidity

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

### positionManager

```solidity
contract INonfungiblePositionManager positionManager
```

### swapRouter

```solidity
contract ISwapRouter swapRouter
```

### factory

```solidity
contract IUniswapV3Factory factory
```

### amount0Desired

```solidity
uint256 amount0Desired
```

### amount1Desired

```solidity
uint256 amount1Desired
```

### poolFee

```solidity
uint24 poolFee
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
mapping(uint256 => struct UniswapV3Liquidity.Deposit) deposits
```

_depositId => Deposit_

### tokenId

```solidity
uint256 tokenId
```

### constructor

```solidity
constructor() public
```

### onERC721Received

```solidity
function onERC721Received(address operator, address from, uint256 _tokenId, bytes data) external returns (bytes4)
```

### _createDeposit

```solidity
function _createDeposit(address _owner, uint256 _tokenId) internal
```

### mintNewPosition

```solidity
function mintNewPosition(address token0, address token1) external returns (uint256 _tokenId, uint128 _liquidity, uint256 _amount0, uint256 _amount1)
```

### createFactoryPool

```solidity
function createFactoryPool(address token0, address token1) external returns (address pool)
```

### getPoolInfo

```solidity
function getPoolInfo(address token0, address token1) external view returns (address pool, int24 fee)
```

