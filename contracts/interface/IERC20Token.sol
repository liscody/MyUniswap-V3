// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Token is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function decimals() external view returns (uint8);
}
