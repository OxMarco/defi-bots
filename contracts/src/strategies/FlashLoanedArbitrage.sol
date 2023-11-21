// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { FlashLoaner } from "../modules/FlashLoaner.sol";
import { SimpleArbitrage } from "./SimpleArbitrage.sol";
import { TokenVault } from "../utils/TokenVault.sol";

contract FlashLoanedArbitrage is TokenVault, SimpleArbitrage, FlashLoaner {
    constructor(
        address uniswapV2Router,
        address uniswapV3Router,
        address sushiRouter,
        address provider
    )
        SimpleArbitrage(uniswapV2Router, uniswapV3Router, sushiRouter)
        FlashLoaner(provider)
    { }

    function execute(SwapParams memory from, Dex to, uint24 fee, uint256 amountOutMin) external override onlyOperator {
        address[] memory assets = new address[](1);
        assets[0] = from.tokenIn;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = from.amountIn;

        bytes memory params = abi.encode(from, to, fee, amountOutMin);

        requestFlashLoan(assets, amounts, params);
    }

    function _hook(
        address[] memory,
        uint256[] memory,
        uint256[] memory premiums,
        bytes memory params
    )
        internal
        override
    {
        (SwapParams memory from, Dex to, uint24 fee, uint256 amountOutMin) =
            abi.decode(params, (SwapParams, Dex, uint24, uint256));

        IERC20 tokenIn = IERC20(from.tokenIn);
        uint256 initialBalanceTokenIn = tokenIn.balanceOf(address(this));

        IERC20 tokenOut = IERC20(from.tokenOut);
        uint256 initialBalanceTokenOut = tokenOut.balanceOf(address(this));

        _swap(from);

        SwapParams memory swapParams = SwapParams({
            dex: to,
            tokenIn: from.tokenOut,
            tokenOut: from.tokenIn,
            fee: fee,
            amountIn: tokenOut.balanceOf(address(this)) - initialBalanceTokenOut,
            amountOutMin: amountOutMin
        });
        _swap(swapParams);

        assert(tokenIn.balanceOf(address(this)) >= initialBalanceTokenIn + premiums[0]);
    }
}
