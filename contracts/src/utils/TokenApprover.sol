// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenApprover {
    using SafeERC20 for IERC20;

    function _approveToken(address _token, address recipient) internal {
        IERC20 token = IERC20(_token);

        if (token.allowance(address(this), recipient) == 0) {
            token.safeApprove(recipient, type(uint256).max);
        }
    }
}
