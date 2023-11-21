import os
import os
import logging
from constants import tokens
from bot.strategies.rebalancer import Rebalancer
from bot.strategies.staker import Staker
from bot.transaction_manager import TransactionManager


def setup_logger(console_logging: bool = False) -> None:
    log_format = '%(levelname)s: %(asctime)s %(message)s'
    
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    if(console_logging):
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(logging.Formatter(log_format))
        logger.addHandler(console_handler)
    else:
        file_handler = logging.FileHandler('./logs/err.log')
        file_handler.setLevel(logging.INFO)
        file_handler.setFormatter(logging.Formatter(log_format))
        logger.addHandler(file_handler)


def setup_transaction_manager() -> TransactionManager:
    try:
        rpc_url = os.environ["RPC_URL"]
        private_key = os.environ["OPERATOR_PRIVATE_KEY"]

        return TransactionManager(
            rpc_url=rpc_url,
            private_key=private_key,
        )
    except KeyError as e:
        logging.error(f"Error: {e}")
        exit(-1)

def setup_rebalancer(transaction_manager) -> Rebalancer:
    try:
        rebalancer_address = os.environ["REBALANCER_ADDRESS"]
        return Rebalancer(
            contract_address=rebalancer_address,
            transaction_manager=transaction_manager,
        )
    except KeyError as e:
        logging.error(f"Error: {e}")
        exit(-1)


def setup_staker(transaction_manager) -> Staker:
    staker_address = os.environ["STAKER_ADDRESS"]
    return Staker(
        contract_address=staker_address,
        transaction_manager=transaction_manager,
    )
