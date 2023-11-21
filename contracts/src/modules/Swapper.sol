// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IUniswapV2Router01 } from "../interfaces/IUniswapV2Router01.sol";
import { IQuoter } from "../interfaces/IQuoter.sol";
import { ISwapRouter } from "../interfaces/ISwapRouter.sol";
import { TokenApprover } from "../utils/TokenApprover.sol";

contract Swapper is TokenApprover {
    function quoteUniswapV2(
        address uniswapV2Router,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    )
        external
        view
        returns (uint256[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return IUniswapV2Router01(uniswapV2Router).getAmountsOut(amountIn, path);
    }

    function swapUniswapV2(
        address uniswapV2Router,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    )
        internal
    {
        _approveToken(tokenIn, uniswapV2Router);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        IUniswapV2Router01(uniswapV2Router).swapExactTokensForTokens(
            amountIn, amountOutMin, path, address(this), block.timestamp
        );
    }

    function quoteUniswapV3(
        address uniswapV3Quoter,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn
    )
        external
        returns (uint256)
    {
        IQuoter.QuoteExactInputSingleParams memory params = IQuoter.QuoteExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            amountIn: amountIn,
            sqrtPriceLimitX96: 0
        });

        (uint256 amount,,,) = IQuoter(uniswapV3Quoter).quoteExactInputSingle(params);
        (params);
        return amount;
    }

    function swapUniswapV3(
        address uniswapV3Router,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMin
    )
        internal
    {
        _approveToken(tokenIn, uniswapV3Router);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        ISwapRouter(uniswapV3Router).exactInputSingle(params);
    }
}
