import logging
from web3 import Web3
from bot.transaction_manager import TransactionManager

class MempoolWatcher:
    def __init__(self, transaction_manager: TransactionManager):
        self.transaction_manager = transaction_manager
        logging.info("MempoolWatcher successfully started")


    def handle_event(self, event):
        # use a try / except to have the program continue if there is a bad transaction in the list
        try:
            # remove the quotes in the transaction hash
            transaction = Web3.toJSON(event).strip('"')
            # use the transaction hash that we removed the '"' from to get the details of the transaction
            transaction = self.transaction_manager.web3Handle.eth.get_transaction(transaction)
            # print the transaction and its details
            print("transaction", transaction)

        except Exception as err:
            # print transactions with errors. Expect to see transactions people submitted with errors 
            print(f'error: {err}')


    def log_loop(self, event_filter):
        while True:
            for event in event_filter.get_new_entries():
                self.handle_event(event)
            # sleep()


    def get_pending(self):
        tx_filter = self.transaction_manager.web3Handle.eth.filter('pending')
        self.log_loop(tx_filter, 2)
