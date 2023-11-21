// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Swapper } from "../modules/Swapper.sol";
import { TokenVault } from "../utils/TokenVault.sol";

contract SimpleArbitrage is TokenVault, Swapper {
    enum Dex {
        UNISWAPV2,
        UNISWAPV3,
        SUSHISWAP
    }

    struct SwapParams {
        Dex dex;
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountIn;
        uint256 amountOutMin;
    }

    address public immutable uniswapV2Router;
    address public immutable uniswapV3Router;
    address public immutable sushiRouter;

    constructor(address _uniswapV2Router, address _uniswapV3Router, address _sushiRouter) Swapper() {
        uniswapV2Router = _uniswapV2Router;
        uniswapV3Router = _uniswapV3Router;
        sushiRouter = _sushiRouter;
    }

    function _swap(SwapParams memory swap) internal {
        if (swap.dex == Dex.UNISWAPV2) {
            swapUniswapV2(uniswapV2Router, swap.tokenIn, swap.tokenOut, swap.amountIn, swap.amountOutMin);
        } else if (swap.dex == Dex.UNISWAPV3) {
            swapUniswapV3(uniswapV3Router, swap.tokenIn, swap.tokenOut, swap.fee, swap.amountIn, swap.amountOutMin);
        } else if (swap.dex == Dex.SUSHISWAP) {
            swapUniswapV2(sushiRouter, swap.tokenIn, swap.tokenOut, swap.amountIn, swap.amountOutMin);
        }
    }

    function execute(SwapParams memory from, Dex to, uint24 fee, uint256 amountOutMin) external virtual onlyOperator {
        IERC20 tokenIn = IERC20(from.tokenIn);
        uint256 initialBalanceTokenIn = tokenIn.balanceOf(address(this));

        IERC20 tokenOut = IERC20(from.tokenOut);
        uint256 initialBalanceTokenOut = tokenOut.balanceOf(address(this));

        _swap(from);

        SwapParams memory params = SwapParams({
            dex: to,
            tokenIn: from.tokenOut,
            tokenOut: from.tokenIn,
            fee: fee,
            amountIn: tokenOut.balanceOf(address(this)) - initialBalanceTokenOut,
            amountOutMin: amountOutMin
        });
        _swap(params);

        assert(tokenIn.balanceOf(address(this)) >= initialBalanceTokenIn);
    }
}
