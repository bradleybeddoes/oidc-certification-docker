import os

BASEDIR = os.path.abspath(os.path.dirname(__file__))

SERVER_CERT = "certs/cert.pem"
SERVER_KEY = "certs/key.pem"
CA_BUNDLE = None

TLS = True
BASE = 'https://127.0.0.1' 

ENT_PATH = 'entities'
ENT_INFO = 'entity_info'
PRE_HTML = 'html/tt'

KEYS = [
    {"key": "keys/enc.key", "type": "RSA", "use": ["enc"]},
    {"key": "keys/sig.key", "type": "RSA", "use": ["sig"]},
    {"crv": "P-256", "type": "EC", "use": ["sig"]},
    {"crv": "P-256", "type": "EC", "use": ["enc"]}
]
