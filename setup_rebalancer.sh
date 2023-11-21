#!/bin/bash

source setup_env.sh

cd contracts

# Deploy Rebalancer
REBALANCER=$(forge create src/strategies/Rebalancer.sol:Rebalancer --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0xC36442b4a4522E871399CD717aBDD847Ab11FE88)
export REBALANCER_ADDRESS=$(echo "$REBALANCER" | grep "Deployed to:" | awk '{print $3}')

# Set operator
cast send --rpc-url=$RPC_URL $REBALANCER_ADDRESS  "setOperator(address)" $OPERATOR_PUBLIC_KEY --private-key=$DEPLOYER_PRIVATE_KEY

# Deposit tokens
for token in "${tokens[@]}"; do
    BALANCE=$(cast call --rpc-url=$RPC_URL $token "balanceOf(address)(uint256)" $DEPLOYER_PUBLIC_KEY)
    cast send $token --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY "approve(address,uint256)" $REBALANCER_ADDRESS $BALANCE
    cast send --rpc-url=$RPC_URL $REBALANCER_ADDRESS  "deposit(address,uint256)" $token $BALANCE --private-key=$DEPLOYER_PRIVATE_KEY
done

echo " "
echo "-------------------------------------------------------------------"
echo "Rebalancer contract deployed to $REBALANCER_ADDRESS"
echo "-------------------------------------------------------------------"

cd ..
