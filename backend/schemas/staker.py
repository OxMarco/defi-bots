from marshmallow import Schema, fields

class AaveDepositSchema(Schema):
    token = fields.Str(required=True)
    amount = fields.Int(required=True)

class AaveWithdrawalSchema(Schema):
    token = fields.Str(required=True)
    amount = fields.Int(required=True)
    slippage = fields.Int(required=True)

class ClearpoolDepositSchema(Schema):
    pool = fields.Str(required=True)
    amount = fields.Int(required=True)

class ClearpoolWithdrawalSchema(Schema):
    pool = fields.Str(required=True)
    amount = fields.Int(required=True)
