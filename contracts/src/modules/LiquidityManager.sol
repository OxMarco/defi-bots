// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { INonfungiblePositionManager } from "../interfaces/INonfungiblePositionManager.sol";
import { TokenApprover } from "../utils/TokenApprover.sol";

contract LiquidityManager is TokenApprover, IERC721Receiver {
    enum Events {
        CREATE,
        UPDATE,
        DELETE
    }

    INonfungiblePositionManager public immutable nonFungiblePositionManager;

    event Action(
        uint256 indexed tokenId,
        address indexed token0,
        address indexed token1,
        int24 tickLower,
        int24 tickUpper,
        uint256 tokensOwed0,
        uint256 tokensOwed1,
        Events e
    );
    event FeesCollected(uint256 indexed tokenId, uint256 amount0, uint256 amount1);

    constructor(address _nonFungiblePositionManager) {
        nonFungiblePositionManager = INonfungiblePositionManager(_nonFungiblePositionManager);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _logAction(uint256 tokenId, Events e) internal {
        (
            ,
            ,
            address token0,
            address token1,
            ,
            int24 tickLower,
            int24 tickUpper,
            ,
            ,
            ,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = nonFungiblePositionManager.positions(tokenId);

        emit Action(tokenId, token0, token1, tickLower, tickUpper, tokensOwed0, tokensOwed1, e);
    }

    function mintNewPosition(
        address token0,
        address token1,
        uint24 poolFee,
        uint256 amount0,
        uint256 amount1,
        int24 tickLower,
        int24 tickUpper
    )
        internal
        returns (uint256, uint256)
    {
        _approveToken(token0, address(nonFungiblePositionManager));
        _approveToken(token1, address(nonFungiblePositionManager));

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (uint256 tokenId,, uint256 amount0Out, uint256 amount1Out) = nonFungiblePositionManager.mint(params);
        _logAction(tokenId, Events.CREATE);

        return (amount0Out, amount1Out);
    }

    function collectAllFees(uint256 tokenId) internal returns (uint256, uint256) {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });
        (uint256 amount0, uint256 amount1) = nonFungiblePositionManager.collect(params);

        emit FeesCollected(tokenId, amount0, amount1);

        return (amount0, amount1);
    }

    function increaseLiquidityPosition(
        uint256 tokenId,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 slippage
    )
        internal
        returns (uint256, uint256)
    {
        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
            tokenId: tokenId,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: amount0Desired - (amount0Desired * slippage / 10_000),
            amount1Min: amount1Desired - (amount1Desired * slippage / 10_000),
            deadline: block.timestamp
        });

        (, uint256 amount0, uint256 amount1) = nonFungiblePositionManager.increaseLiquidity(params);
        _logAction(tokenId, Events.UPDATE);

        return (amount0, amount1);
    }

    function decreaseLiquidityPosition(uint256 tokenId, uint128 liquidity) internal returns (uint256, uint256) {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
            .DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (uint256 amount0, uint256 amount1) = nonFungiblePositionManager.decreaseLiquidity(params);
        _logAction(tokenId, Events.UPDATE);

        return (amount0, amount1);
    }

    function burn(uint256 tokenId) internal {
        nonFungiblePositionManager.burn(tokenId);
    }
}
