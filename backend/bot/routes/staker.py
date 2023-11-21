from flask import Flask, request, jsonify
from marshmallow import ValidationError
from schemas.staker import AaveDepositSchema, AaveWithdrawalSchema, ClearpoolDepositSchema, ClearpoolWithdrawalSchema
from app import app, staker

@app.route('/staker/depositAave', methods=['POST'])
def deposit_aave():
    request_data = request.json
    schema = AaveDepositSchema()
    try:
        result = schema.load(request_data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    token = result["token"]
    amount = result["amount"]
    status, msg, gas = staker.depositAave(token, amount)

    if status:
        return jsonify({ "txHash": msg, "gasCost": gas })
    else:
        return jsonify({ "error": msg })

@app.route('/staker/withdrawAave', methods=['POST'])
def withdraw_aave():
    request_data = request.json
    schema = AaveWithdrawalSchema()
    try:
        result = schema.load(request_data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    token = result["token"]
    amount = result["amount"]
    slippage = result["slippage"]
    status, msg, gas = staker.withdrawAave(token, amount, slippage)

    if status:
        return jsonify({ "txHash": msg, "gasCost": gas })
    else:
        return jsonify({ "error": msg })

@app.route('/staker/depositClearpool', methods=['POST'])
def deposit_clearpool():
    request_data = request.json
    schema = ClearpoolDepositSchema()
    try:
        result = schema.load(request_data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    pool = result["pool"]
    amount = result["amount"]
    status, msg, gas = staker.depositClearpool(pool, amount)

    if status:
        return jsonify({ "txHash": msg, "gasCost": gas })
    else:
        return jsonify({ "error": msg })

@app.route('/staker/withdrawClearpool', methods=['POST'])
def withdraw_clearpool():
    request_data = request.json
    schema = ClearpoolWithdrawalSchema()
    try:
        result = schema.load(request_data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    pool = result["pool"]
    amount = result["amount"]
    status, msg, gas = staker.withdrawClearpool(pool, amount)

    if status:
        return jsonify({ "txHash": msg, "gasCost": gas })
    else:
        return jsonify({ "error": msg })
