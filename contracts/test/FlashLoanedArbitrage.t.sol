// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseTest } from "./BaseTest.sol";
import { SimpleArbitrage } from "../src/strategies/SimpleArbitrage.sol";
import { FlashLoanedArbitrage } from "../src/strategies/FlashLoanedArbitrage.sol";

contract FlashLoanedArbitrageTest is BaseTest {
    address public constant UNIV2ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant UNIV3ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant SUSHIROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant PROVIDER = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    FlashLoanedArbitrage public immutable flashLoanedArbitrage;

    constructor() BaseTest() {
        flashLoanedArbitrage = new FlashLoanedArbitrage(UNIV2ROUTER, UNIV3ROUTER, SUSHIROUTER, PROVIDER);
        dai.tkn.approve(address(flashLoanedArbitrage), type(uint256).max);
        weth.tkn.approve(address(flashLoanedArbitrage), type(uint256).max);
    }

    function setUp() public {
        _transferFromWhale(dai, address(this));
        _transferFromWhale(weth, address(this));
    }

    function testFlashloanedArbitrageUniV2toV3DaiWeth() public {
        uint256 amount = 1000 * 1e18;
        flashLoanedArbitrage.deposit(dai.addr, amount);

        SimpleArbitrage.SwapParams memory from = SimpleArbitrage.SwapParams({
            dex: SimpleArbitrage.Dex.UNISWAPV2,
            tokenIn: dai.addr,
            tokenOut: weth.addr,
            fee: 0,
            amountIn: amount,
            amountOutMin: 0
        });
        SimpleArbitrage.Dex to = SimpleArbitrage.Dex.UNISWAPV3;
        uint24 fee = 3000;
        uint256 amountOutMin = 0;
        flashLoanedArbitrage.execute(from, to, fee, amountOutMin);
    }
}
