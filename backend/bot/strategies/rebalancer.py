import logging
from bot.strategies.base_strategy import BaseStrategy
from bot.transaction_manager import TransactionManager
from bot.abi.REBALANCER import REBALANCER_ABI


class Rebalancer(BaseStrategy):
    def __init__(self, contract_address: str, transaction_manager: TransactionManager):
        super().__init__(transaction_manager, contract_address, contract_abi=REBALANCER_ABI)
        logging.info("Rebalancer successfully started")


    def mint(self, token0: str, token1: str, poolFee: int, amount0: int, amount1: int, tick_lower: int, tick_upper: int):
        logging.info("Minting a new position")
        mint_function = self.contract.functions.mint(
            token0,
            token1,
            poolFee,
            amount0,
            amount1,
            tick_lower,
            tick_upper,
        )
        self.transaction_manager.execute_contract_call(mint_function)


    def burn(self, tokenId: int):
        logging.info(f"Burning position #{tokenId}")
        burn_function = self.contract.functions.exit(tokenId)
        self.transaction_manager.execute_contract_call(burn_function)


    def collect(self, tokenId: int):
        logging.info(f"Collecting fees for position #{tokenId}")
        collect_function = self.contract.functions.collect(tokenId)
        self.transaction_manager.execute_contract_call(collect_function)


    def increaseLiquidity(self, tokenId: int, amount0Desired: int, amount1Desired: int, amount0Min: int, amount1Min: int):
        logging.info(f"Increasing liquidity for position #{tokenId}")
        increase_liquidity_function = self.contract.functions.increaseLiquidity(
            tokenId,
            amount0Desired,
            amount1Desired,
            amount0Min,
            amount1Min,
        )
        self.transaction_manager.execute_contract_call(increase_liquidity_function)

    
    def decreaseLiquidity(self, tokenId: int, liquidity: int, amount0Min: int, amount1Min: int):
        logging.info(f"Decreasing liquidity for position #{tokenId}")
        decrease_liquidity_function = self.contract.functions.decreaseLiquidity(
            tokenId,
            liquidity,
            amount0Min,
            amount1Min,
        )
        self.transaction_manager.execute_contract_call(decrease_liquidity_function)
