// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseTest } from "./BaseTest.sol";
import { Rebalancer } from "../src/strategies/Rebalancer.sol";

contract RebalancerTest is BaseTest {
    address public constant MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    Rebalancer public immutable rebalancer;

    constructor() BaseTest() {
        rebalancer = new Rebalancer(MANAGER);
        usdc.tkn.approve(address(rebalancer), type(uint256).max);
        weth.tkn.approve(address(rebalancer), type(uint256).max);
    }

    function setUp() public {
        _transferFromWhale(usdc, address(this));
        _transferFromWhale(weth, address(this));
    }

    function testProvideLiquidity() public {
        uint256 amountUSDC = 2000 * 1e6;
        rebalancer.deposit(usdc.addr, amountUSDC);
        uint256 amountWETH = 1 * 1e18;
        rebalancer.deposit(weth.addr, amountWETH);

        rebalancer.mint(usdc.addr, weth.addr, 3000, amountUSDC, amountWETH, 10, 20);

        assert(usdc.tkn.balanceOf(address(this)) >= amountUSDC);
        assert(weth.tkn.balanceOf(address(this)) >= amountWETH);
    }
}
