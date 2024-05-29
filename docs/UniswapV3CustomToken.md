# Solidity API

## UniswapV3CustomToken

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

### DAI

```solidity
address DAI
```

The DAI token address

### USDC

```solidity
address USDC
```

The USDC token address

### factory

```solidity
contract IUniswapV3Factory factory
```

The Uniswap V3 Factory

### nonfungiblePositionManager

```solidity
contract INonfungiblePositionManager nonfungiblePositionManager
```

The Uniswap V3 Pool

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
mapping(uint256 => struct UniswapV3CustomToken.Deposit) deposits
```

_deposits[tokenId] => Deposit_

### token_Id

```solidity
uint256 token_Id
```

### constructor

```solidity
constructor(address token0, address token1) public
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
function onERC721Received(address operator, address, uint256 _tokenId, bytes) external returns (bytes4)
```

### _createDeposit

```solidity
function _createDeposit(address _owner, uint256 _tokenId) internal
```

### mintNewPosition

```solidity
function mintNewPosition() external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
```

