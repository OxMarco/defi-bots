// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPool } from "../interfaces/IPool.sol";
import { ICPool } from "../interfaces/ICPool.sol";
import { IAToken } from "../interfaces/IAToken.sol";
import { TokenVault } from "../utils/TokenVault.sol";
import { TokenApprover } from "../utils/TokenApprover.sol";

contract SimpleStaker is TokenApprover, TokenVault {
    IPool public immutable aave;

    constructor(address _aave) {
        aave = IPool(_aave);
    }

    function supplyToAave(address token, uint256 amount) external onlyOperator {
        _approveToken(token, address(aave));
        aave.supply(token, amount, address(this), 0);
    }

    function withdrawFromAave(address token, uint256 amount, uint256 slippage) external onlyOperator {
        uint256 amountOut = aave.withdraw(token, amount, address(this));
        require(amountOut >= amount * (10_000 - slippage) / 10_000, "Slippage too high");
    }

    function quoteAave(address _atoken, uint256 amount) external view returns (uint256, uint8) {
        IAToken atoken = IAToken(_atoken);
        uint256 currentExchangeRate = atoken.getExchangeRate();

        return (amount * currentExchangeRate, atoken.decimals());
    }

    function supplyToClearpool(address _pool, uint256 amount) external onlyOperator {
        ICPool pool = ICPool(_pool);
        _approveToken(pool.currency(), _pool);
        pool.provide(amount);
    }

    function withdrawFromClearpool(address _pool, uint256 amount) external onlyOperator {
        ICPool pool = ICPool(_pool);
        pool.redeem(amount);
    }

    function quoteClearpool(address _pool, uint256 amount) external view returns (uint256, uint256) {
        ICPool pool = ICPool(_pool);
        return (pool.getCurrentExchangeRate() * amount, pool.decimals());
    }

    function getClearpoolPoolData(address _pool) external view returns (uint256, uint256, uint256) {
        ICPool pool = ICPool(_pool);
        return (pool.getUtilizationRate(), pool.availableToWithdraw(), pool.balanceOf(address(this)));
    }
}
