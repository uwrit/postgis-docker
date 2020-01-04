import os
import sys
import uuid

from flask import Flask, Request, request, jsonify
from .modules.response import ok, bad_request, forbidden, not_found, server_error
from .modules.manager import Manager

app = Flask(__name__)
mgr = Manager()

#########################################
# Routes
#########################################
@app.route('/user', methods=['GET'])
def is_user():
    try:
        email = request.args.get('email')
        entry_code = request.args.get('entry_code')
        
        if not email or not entry_code:
            return bad_request()

        user = mgr.get_user(email, entry_code)
        if user:
            return ok({ 'user' : user })

        return not_found()

    except Exception as ex:
        sys.stderr.write(f'Error: {ex}\n')
        return server_error()    
