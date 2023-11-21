#!/bin/bash

cd contracts
source .env
anvil --fork-url $FORK_URL_MAINNET &
ANVIL_PID=$!
sleep 2

OPERATOR_PUBLIC_KEY=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
OPERATOR_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEPLOYER_PUBLIC_KEY=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720
DEPLOYER_PRIVATE_KEY=0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

DAI=0x6B175474E89094C44Da98b954EedeAC495271d0F
USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
WHALE=0x8EB8a3b98659Cce290402893d0123abb75E3ab28

tokens=($DAI $USDC $WETH)

export RPC_URL=http://127.0.0.1:8545

REBALANCER=$(forge create src/strategies/Rebalancer.sol:Rebalancer --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0xC36442b4a4522E871399CD717aBDD847Ab11FE88)
export REBALANCER_ADDRESS=$(echo "$REBALANCER" | grep "Deployed to:" | awk '{print $3}')
echo "Rebalancer" $REBALANCER_ADDRESS
cast rpc anvil_impersonateAccount $WHALE --rpc-url=$RPC_URL
for token in "${tokens[@]}"; do
    BALANCE=$(cast call --rpc-url=$RPC_URL $token "balanceOf(address)(uint256)" $WHALE)
    cast send $token --rpc-url=$RPC_URL --unlocked --from $WHALE "transfer(address,uint256)(bool)" $DEPLOYER_PUBLIC_KEY $BALANCE
done
cast rpc anvil_stopImpersonatingAccount $WHALE --rpc-url=$RPC_URL

for token in "${tokens[@]}"; do
    BALANCE=$(cast call --rpc-url=$RPC_URL $token "balanceOf(address)(uint256)" $DEPLOYER_PUBLIC_KEY)
    cast send $token --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY "approve(address,uint256)" $REBALANCER_ADDRESS $BALANCE
    cast send --rpc-url=$RPC_URL $REBALANCER_ADDRESS  "deposit(address,uint256)" $token $BALANCE --private-key=$OPERATOR_PRIVATE_KEY > /dev/null 2>&1
done


###

SIMPLE_ARBITRAGE=$(forge create src/strategies/SimpleArbitrage.sol:SimpleArbitrage --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 0xE592427A0AEce92De3Edee1F18E0157C05861564 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F)
FLASH_LOAN_ARBITRAGE=$(forge create src/strategies/FlashLoanedArbitrage.sol:FlashLoanedArbitrage --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 0xE592427A0AEce92De3Edee1F18E0157C05861564 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e)
JIT=$(forge create src/strategies/JIT.sol:JIT --rpc-url=$RPC_URL --private-key=$DEPLOYER_PRIVATE_KEY --constructor-args 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e)


export SIMPLE_ARBITRAGE_ADDRESS=$(echo "$SIMPLE_ARBITRAGE" | grep "Deployed to:" | awk '{print $3}')
export FLASH_LOAN_ARBITRAGE_ADDRESS=$(echo "$FLASH_LOAN_ARBITRAGE" | grep "Deployed to:" | awk '{print $3}')
export STAKER_ADDRESS=$(echo "$STAKER" | grep "Deployed to:" | awk '{print $3}')
export JIT_ADDRESS=$(echo "$JIT" | grep "Deployed to:" | awk '{print $3}')

echo "SimpleArbitrage" $SIMPLE_ARBITRAGE_ADDRESS
echo "FlashLoanedArbitrage" $FLASH_LOAN_ARBITRAGE_ADDRESS
echo "SimpleStaker" $STAKER_ADDRESS
echo "JIT" $JIT_ADDRESS

cast send --rpc-url=$RPC_URL $SIMPLE_ARBITRAGE_ADDRESS  "setOperator(address)" $OPERATOR_PUBLIC_KEY --private-key=$DEPLOYER_PRIVATE_KEY > /dev/null 2>&1
cast send --rpc-url=$RPC_URL $FLASH_LOAN_ARBITRAGE_ADDRESS  "setOperator(address)" $OPERATOR_PUBLIC_KEY --private-key=$DEPLOYER_PRIVATE_KEY > /dev/null 2>&1
cast send --rpc-url=$RPC_URL $JIT_ADDRESS  "setOperator(address)" $OPERATOR_PUBLIC_KEY --private-key=$DEPLOYER_PRIVATE_KEY > /dev/null 2>&1
