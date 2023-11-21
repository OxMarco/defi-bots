// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVault is Ownable {
    using SafeERC20 for IERC20;

    address public operator;

    event Deposit(address indexed token, uint256 amount);
    event Withdrawal(address indexed token, uint256 amount);
    event Operatorchanged(address operator);

    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == owner(), "Restricted to operator");
        _;
    }

    constructor() {
        operator = msg.sender;
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;

        emit Operatorchanged(operator);
    }

    function deposit(address _token, uint256 amount) external {
        IERC20 token = IERC20(_token);
        require(amount <= token.allowance(msg.sender, address(this)), "Insufficient allowance");
        require(amount <= token.balanceOf(msg.sender), "Insufficient balance");

        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(_token, amount);
    }

    function withdraw(address _token, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        require(amount <= token.balanceOf(address(this)), "Insufficient balance");

        token.safeTransfer(msg.sender, amount);

        emit Withdrawal(_token, amount);
    }
}
