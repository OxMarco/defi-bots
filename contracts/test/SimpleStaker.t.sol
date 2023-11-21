// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseTest } from "./BaseTest.sol";
import { SimpleStaker } from "../src/strategies/SimpleStaker.sol";

contract SimpleStakerTest is BaseTest {
    address public constant AAVE = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address public constant cpPOR_USDC = 0x4a90c14335E81829D7cb0002605f555B8a784106;
    SimpleStaker public immutable simpleStaker;

    constructor() BaseTest() {
        simpleStaker = new SimpleStaker(AAVE);
        usdc.tkn.approve(address(simpleStaker), type(uint256).max);
    }

    function setUp() public {
        _transferFromWhale(usdc, address(this));
    }

    function testAave() public {
        uint256 amount = 1000 * 1e6;
        simpleStaker.deposit(usdc.addr, amount);

        simpleStaker.supplyToAave(usdc.addr, amount);
        simpleStaker.withdrawFromAave(usdc.addr, amount, 0);

        assert(usdc.tkn.balanceOf(address(this)) >= amount);
    }

    function testClearpool() public {
        uint256 amount = 1000 * 1e6;
        simpleStaker.deposit(usdc.addr, amount);

        simpleStaker.supplyToClearpool(cpPOR_USDC, amount);
        (,, uint256 balance) = simpleStaker.getClearpoolPoolData(cpPOR_USDC);
        simpleStaker.withdrawFromClearpool(cpPOR_USDC, balance);

        assert(usdc.tkn.balanceOf(address(this)) >= amount);
    }
}
