from flask import jsonify
from app import app, staker

@app.errorhandler(400)
def not_found_error(error):
    response = jsonify({'error': 'Bad request'})
    response.status_code = 400
    return response

@app.errorhandler(404)
def not_found_error(error):
    response = jsonify({'error': 'Not found'})
    response.status_code = 404
    return response

@app.errorhandler(415)
def not_found_error(error):
    response = jsonify({'error': 'Unsupported media type'})
    response.status_code = 415
    return response

@app.errorhandler(500)
def internal_error(error):
    response = jsonify({'error': 'Internal server error'})
    response.status_code = 500
    return response
