from bot.transaction_manager import TransactionManager


class BaseStrategy:
    def __init__(self, transaction_manager: TransactionManager, contract_address: str, contract_abi):
        self.transaction_manager = transaction_manager
        self.contract_address = contract_address
        self.contract = self.transaction_manager.web3Handle.eth.contract(address=contract_address, abi=contract_abi)


    def get_balances(self, tokens: list[str]) -> dict:
        amounts = {}
        for token in tokens:
            amount = self.transaction_manager.get_token_balance(token, self.contract_address)
            amounts[token] = amount
        return amounts
