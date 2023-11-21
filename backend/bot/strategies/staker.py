import logging
from bot.strategies.base_strategy import BaseStrategy
from bot.transaction_manager import TransactionManager
from bot.abi.STAKER import STAKER_ABI


class Staker(BaseStrategy):
    def __init__(self, contract_address: str, transaction_manager: TransactionManager):
        super().__init__(transaction_manager, contract_address, contract_abi=STAKER_ABI)
        logging.info("Staker successfully started")


    def depositAave(self, token: str, amount: int):
        token_name = self.transaction_manager.get_token_name(token)
        logging.info(f"Supplying {amount} {token_name} to Aave")
        staking_transaction = self.contract.functions.supplyToAave(token, amount)
        return self.transaction_manager.execute_contract_call(staking_transaction)


    def withdrawAave(self, token: str, amount: int, slippage: int = 0):
        token_name = self.transaction_manager.get_token_name(token)
        logging.info(f"Withdrawing {amount} {token_name} from Aave")
        staking_transaction = self.contract.functions.withdrawFromAave(token, amount, slippage * 10000)
        return self.transaction_manager.execute_contract_call(staking_transaction)


    def quoteAavePosition(self, atoken: str, amount: int):
        return self.contract.functions.quoteAave(atoken, amount).call()


    def depositClearpool(self, pool: str, amount: int):
        token_name = self.transaction_manager.get_token_name(pool)
        logging.info(f"Supplying {amount} {token_name} to Clearpool")
        staking_transaction = self.contract.functions.supplyToClearpool(pool, amount)
        return self.transaction_manager.execute_contract_call(staking_transaction)


    def withdrawCompound(self, pool: str, amount: int):
        token_name = self.transaction_manager.get_token_name(pool)
        logging.info(f"Withdrawing {amount} {token_name} from Clearpool")
        staking_transaction = self.contract.functions.withdrawFromClearpool(pool, amount)
        return self.transaction_manager.execute_contract_call(staking_transaction)


    def quoteClearpoolPosition(self, pool: str, amount: int):
        return self.contract.functions.quoteClearpool(pool, amount).call()


    def getClearpoolPoolData(self, pool: str):
        return self.contract.functions.getClearpoolPoolData(pool).call()
