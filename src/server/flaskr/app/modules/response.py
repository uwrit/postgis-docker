def ok(data = ''):
    return data, 200

def bad_request():
    return '', 400

def forbidden():
    return '', 403

def not_found():
    return '', 404

def server_error():
    return '', 500