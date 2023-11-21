import time
from flask import Flask, request, jsonify
from marshmallow import ValidationError
from setup import setup_rebalancer, setup_staker, setup_transaction_manager, setup_logger
from schemas.staker import AaveDepositSchema, AaveWithdrawalSchema, ClearpoolDepositSchema, ClearpoolWithdrawalSchema

# Setup
app = Flask(__name__)
transaction_manager = setup_transaction_manager()
#rebalancer = setup_rebalancer(transaction_manager)
staker = setup_staker(transaction_manager)

# Routes
@app.route('/', methods=['GET'])
def index():
    return jsonify({ "status": "active", "timestamp": time.time() })

@app.route('/status', methods=['GET'])
def status():
    transaction_manager.get_pending()
    chain_id, block_number, gas_price = transaction_manager.get_status()
    return jsonify({
        "chainId": chain_id,
        "blockNumber": block_number,
        "gasPrice": gas_price
    })

from bot.routes.errors import *
from bot.routes.staker import *

# Program main
def run_app():
    app.run(host='0.0.0.0', port=5000)

if __name__ == '__main__':
    setup_logger(False)
    run_app()
