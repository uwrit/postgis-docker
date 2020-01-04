import os
import sys
import uuid

from flask import Flask, Request, request, jsonify
from .modules.response import ok, bad_request, forbidden, not_found, server_error
from .modules.postgis import PostgisConnector

app = Flask(__name__)
postgis = PostgisConnector()

#########################################
# Routes
#########################################
@app.route('/latlong', methods=['GET'])
def latlong():
    try:
        address = request.args.get('q')
        
        if not address:
            return bad_request()

        data = postgis.get_lat_long(address)
        if data:
            return ok(jsonify(data))

        return not_found()

    except Exception as ex:
        sys.stderr.write(f'Error: {ex}\n')
        return server_error()    

@app.route('/helloworld', methods=['GET'])
def hello():
    return ok(jsonify({ 'data': 'Hello World!' }))
