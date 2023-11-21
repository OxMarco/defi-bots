import logging
import web3
from web3 import Web3
from web3.gas_strategies.rpc import rpc_gas_price_strategy
from web3.middleware import construct_sign_and_send_raw_middleware, geth_poa_middleware
from web3.exceptions import ContractLogicError, TransactionNotFound, TimeExhausted
from bot.abi.ERC20 import ERC20_ABI

class TransactionManager:
    def __init__(
        self,
        rpc_url: str,
        private_key: str,
    ):
        self.rpc_url = rpc_url
        self.private_key = private_key
        self._init_web_handle()
        self._init_account()
        assert(self.web3Handle.is_connected())
        logging.info("TransactionManager successfully started")


    def _init_web_handle(self) -> None:
        self.web3Handle = Web3(
            Web3.HTTPProvider(self.rpc_url)
        )


    def _init_account(self) -> None:
        self.account = web3.Account.from_key(self.private_key)
        self.web3Handle.middleware_onion.add(
            construct_sign_and_send_raw_middleware(self.account)
        )
        self.web3Handle.middleware_onion.inject(geth_poa_middleware, layer=0)
        self.web3Handle.eth.set_gas_price_strategy(rpc_gas_price_strategy)


    def resolve_address(address) -> str:
        if Web3.is_address(address):
            return Web3.to_checksum_address(address)
        else:
            raise ValueError(f"Could not resolve address: {address}")


    def get_eth_balance(self, address: str) -> int:
        return self.web3Handle.eth.get_balance(address)


    def get_token_balance(self, token_address: str, balance_address: str) -> (str, int):
        try:
            token_contract = self.web3Handle.eth.contract(address=token_address, abi=ERC20_ABI)
            decimal_units = token_contract.functions.decimals().call()
            balance = token_contract.functions.balanceOf(balance_address).call()
            return balance, decimal_units
        except web3.exceptions.ContractLogicError:
            logging.error("Invalid token")
            exit(-1)


    def get_token_name(self, token_address: str) -> str:
        try:
            token_contract = self.web3Handle.eth.contract(address=token_address, abi=ERC20_ABI)
            return token_contract.functions.symbol().call()
        except web3.exceptions.ContractLogicError:
            logging.error("Invalid token")
            return None


    def execute_contract_call(self, contract_function):
        try:
            maybe_gas_price = self.web3Handle.eth.generate_gas_price()
            gas_price = maybe_gas_price * 2 if maybe_gas_price is not None else None

            gas_units = contract_function.estimate_gas({"from": self.account.address})

            txn_data = contract_function.build_transaction({
                "from": self.account.address,
                "gas": gas_units,
                "gasPrice": gas_price,
                "nonce": self.web3Handle.eth.get_transaction_count(self.account.address),
            })

            eth_balance_before = self.get_eth_balance(self.account.address)

            signed_txn = self.web3Handle.eth.account.sign_transaction(
                txn_data, private_key=self.private_key
            )
            tx_hash = self.web3Handle.eth.send_raw_transaction(signed_txn.rawTransaction)
            
            try:
                self.web3Handle.eth.wait_for_transaction_receipt(tx_hash.hex(), timeout=120)  # timeout in seconds
            except TimeExhausted:
                logging.warn("Transaction receipt not received within the expected time")
            
            eth_balance_after = self.get_eth_balance(self.account.address)

            return True, Web3.to_hex(tx_hash), eth_balance_before - eth_balance_after

        except ContractLogicError as e:
            logging.error(f"Contract logic error during transaction: {e}")
            return False, e.message, 0
        except TransactionNotFound as e:
            logging.error(f"Transaction not found: {e}")
            return False, e.message, 0
        except AssertionError:
            logging.error("Insufficient balance to perform transaction")
            return False, "insufficient gas", 0
        except Exception as e:
            logging.error(f"An unexpected error occurred: {e}")
            return False, e.message, 0


    def get_status(self):
        return self.web3Handle.eth.chain_id, self.web3Handle.eth.block_number, self.web3Handle.eth.gas_price

