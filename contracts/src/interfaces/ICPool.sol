// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICPool {
    /// @notice Function is used to provide liquidity for Pool in exchange for cpTokens
    /// @dev Approval for desired amount of currency token should be given in prior
    /// @param currencyAmount Amount of currency token that user want to provide
    function provide(uint256 currencyAmount) external;

    /// @notice Function is used to redeem previously provided liquidity with interest, burning cpTokens
    /// @param tokens Amount of cpTokens to burn (MaxUint256 to burn maximal possible)
    function redeem(uint256 tokens) external;

    /// @notice Function returns current (with accrual) amount of funds available to LP for withdrawal
    /// @return Current available to withdraw funds
    function availableToWithdraw() external view returns (uint256);

    /// @notice Function returns current (with accrual) exchange rate of cpTokens for currency tokens
    /// @return Current exchange rate as 18-digits decimal
    function getCurrentExchangeRate() external view returns (uint256);

    /// @notice Function to get current utilization rate
    /// @return Utilization rate as 18-digit decimal
    function getUtilizationRate() external view returns (uint256);

    function currency() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}
