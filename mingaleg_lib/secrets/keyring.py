from pathlib import Path

from Crypto.PublicKey import RSA

CWD = Path(__file__).parent


class Keyring:
    def __init__(self):
        self.public_keys = {}
        for public_key_file in (CWD / "public_keyring").glob("*.pem"):
            self.public_keys[public_key_file.stem] = RSA.import_key(public_key_file.read_bytes())
