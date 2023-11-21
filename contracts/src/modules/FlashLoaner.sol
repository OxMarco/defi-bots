// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { FlashLoanReceiverBase } from "@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { TokenApprover } from "../utils/TokenApprover.sol";

contract FlashLoaner is TokenApprover, FlashLoanReceiverBase {
    constructor(address provider) FlashLoanReceiverBase(IPoolAddressesProvider(provider)) { }

    function requestFlashLoan(address[] memory assets, uint256[] memory amounts, bytes memory params) internal {
        require(assets.length == amounts.length, "assets and amounts length mismatch");

        uint256[] memory modes = new uint256[](2);
        POOL.flashLoan(
            address(this), //receiverAddress
            assets,
            amounts,
            modes,
            address(this), // onBehalfOf
            params,
            0 // referralCode
        );
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address, /*operator*/
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        assert(msg.sender == address(POOL));

        _hook(assets, amounts, premiums, params);

        for (uint8 i = 0; i < assets.length; i++) {
            // uint256 amountOwing = amounts[i] + premiums[i];
            _approveToken(assets[i], address(POOL));
        }

        return true;
    }

    function _hook(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        bytes memory params
    )
        internal
        virtual
    { }
}
