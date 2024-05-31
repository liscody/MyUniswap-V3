// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;

contract CalculateSqrtPriceX96 {
    function calculateSqrtPriceX96(uint256 priceToken0Token1) public pure returns (uint160) {
        uint256 sqrtPrice = sqrt(priceToken0Token1);
        uint256 sqrtPriceX96 = sqrtPrice * (2 ** 96);
        return uint160(sqrtPriceX96);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}