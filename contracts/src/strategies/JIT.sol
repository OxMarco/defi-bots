// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { FlashLoaner } from "../modules/FlashLoaner.sol";
import { LiquidityManager } from "../modules/LiquidityManager.sol";
import { TokenVault } from "../utils/TokenVault.sol";

contract JIT is TokenVault, LiquidityManager, FlashLoaner {
    constructor(
        address nonFungiblePositionManager,
        address provider
    )
        LiquidityManager(nonFungiblePositionManager)
        FlashLoaner(provider)
    { }

    function execute(
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
    {
        address[] memory assets = new address[](2);
        assets[0] = token0;
        assets[1] = token1;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amount0;
        amounts[1] = amount0;

        bytes memory params = abi.encode(token0, token1, poolFee, amount0, amount1, tickLower, tickUpper);

        requestFlashLoan(assets, amounts, params);
    }

    function _hook(address[] memory, uint256[] memory, uint256[] memory, bytes memory params) internal override {
        (
            address token0,
            address token1,
            uint24 poolFee,
            uint256 amount0,
            uint256 amount1,
            int24 tickLower,
            int24 tickUpper
        ) = abi.decode(params, (address, address, uint24, uint256, uint256, int24, int24));

        mintNewPosition(token0, token1, poolFee, amount0, amount1, tickLower, tickUpper);

        // @todo WIP
    }
}
