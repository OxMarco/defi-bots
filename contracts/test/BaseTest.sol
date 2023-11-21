// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

contract BaseTest is PRBTest, StdCheats {
    using SafeERC20 for IERC20;

    struct Token {
        address addr;
        IERC20 tkn;
        address whale;
    }

    Token public dai = Token({
        addr: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
        tkn: IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),
        whale: 0x8EB8a3b98659Cce290402893d0123abb75E3ab28
    });

    Token public usdc = Token({
        addr: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
        tkn: IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
        whale: 0xcEe284F754E854890e311e3280b767F80797180d
    });

    Token public weth = Token({
        addr: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
        tkn: IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),
        whale: 0x8EB8a3b98659Cce290402893d0123abb75E3ab28
    });

    constructor() {
        vm.createSelectFork(vm.envString("FORK_URL_MAINNET"), 18_543_567);
    }

    function _transferFromWhale(Token memory token, address to) internal {
        vm.startPrank(token.whale);
        token.tkn.safeTransfer(to, token.tkn.balanceOf(token.whale));
        vm.stopPrank();
    }
}
