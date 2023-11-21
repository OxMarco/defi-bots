#!/bin/bash

source setup_env.sh

cd contracts

# Deploy SimpleStaker
STAKER=$(forge create src/strategies/SimpleStaker.sol:SimpleStaker --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2)
export STAKER_ADDRESS=$(echo "$STAKER" | grep "Deployed to:" | awk '{print $3}')

# Set operator
cast send --rpc-url=$RPC_URL $STAKER_ADDRESS  "setOperator(address)" $OPERATOR_PUBLIC_KEY --private-key=$DEPLOYER_PRIVATE_KEY

# Deposit tokens
for token in "${tokens[@]}"; do
    BALANCE=$(cast call --rpc-url=$RPC_URL $token "balanceOf(address)(uint256)" $DEPLOYER_PUBLIC_KEY)
    cast send $token --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY "approve(address,uint256)" $STAKER_ADDRESS $BALANCE
    cast send --rpc-url=$RPC_URL $STAKER_ADDRESS  "deposit(address,uint256)" $token $BALANCE --private-key=$DEPLOYER_PRIVATE_KEY
done

echo " "
echo "-------------------------------------------------------------------"
echo "Staker contract deployed to $STAKER_ADDRESS"
echo "-------------------------------------------------------------------"

cd ..
