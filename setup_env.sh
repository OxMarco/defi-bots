#!/bin/bash

export OPERATOR_PUBLIC_KEY=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export OPERATOR_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export DEPLOYER_PUBLIC_KEY=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720
export DEPLOYER_PRIVATE_KEY=0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

export DAI=0x6B175474E89094C44Da98b954EedeAC495271d0F
export USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
export WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
export WHALE=0x8EB8a3b98659Cce290402893d0123abb75E3ab28
export tokens=($DAI $USDC $WETH)

export RPC_URL=http://127.0.0.1:8545

cast rpc anvil_impersonateAccount $WHALE --rpc-url=$RPC_URL
for token in "${tokens[@]}"; do
    BALANCE=$(cast call --rpc-url=$RPC_URL $token "balanceOf(address)(uint256)" $WHALE)
    cast send $token --rpc-url=$RPC_URL --unlocked --from $WHALE "transfer(address,uint256)(bool)" $DEPLOYER_PUBLIC_KEY $BALANCE
done
cast rpc anvil_stopImpersonatingAccount $WHALE --rpc-url=$RPC_URL
