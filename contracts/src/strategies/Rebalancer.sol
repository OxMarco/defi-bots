// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { LiquidityManager } from "../modules/LiquidityManager.sol";
import { TokenVault } from "../utils/TokenVault.sol";

contract Rebalancer is TokenVault, LiquidityManager {
    constructor(address nonFungiblePositionManager) LiquidityManager(nonFungiblePositionManager) { }

    function mint(
        address token0,
        address token1,
        uint24 poolFee,
        uint256 amount0,
        uint256 amount1,
        int24 tickLower,
        int24 tickUpper
    )
        external
        onlyOperator
        returns (uint256, uint256)
    {
        return mintNewPosition(token0, token1, poolFee, amount0, amount1, tickLower, tickUpper);
    }

    function collect(uint256 tokenId) external onlyOperator returns (uint256, uint256) {
        return collectAllFees(tokenId);
    }

    function increaseLiquidity(
        uint256 tokenId,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 slippage
    )
        external
        onlyOperator
        returns (uint256, uint256)
    {
        return increaseLiquidityPosition(tokenId, amount0Desired, amount1Desired, slippage);
    }

    function decreaseLiquidity(uint256 tokenId, uint128 liquidity) external onlyOperator returns (uint256, uint256) {
        return decreaseLiquidityPosition(tokenId, liquidity);
    }

    function exit(uint256 tokenId) external onlyOperator {
        burn(tokenId);
    }
}
