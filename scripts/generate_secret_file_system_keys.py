import sys
from pathlib import Path

from Crypto.PublicKey import RSA


def generate_secret_file_system_keys(key_name: str):
    """
    Generate a GPG key for the secret file system.
    """
    key = RSA.generate(2048)

    secret_keychain_dir = Path("secrets", "keyring", key_name)
    secret_keychain_dir.mkdir(parents=True, exist_ok=True)

    private_key = key.export_key()
    with open(secret_keychain_dir / "private.pem", "wb") as f:
        f.write(private_key)

    public_key = key.publickey().export_key()
    with open(secret_keychain_dir / "public.pem", "wb") as f:
        f.write(public_key)

    public_keychain_dir = Path("mingaleg_lib", "secrets", "public_keyring")
    public_keychain_dir.mkdir(parents=True, exist_ok=True)
    with open(public_keychain_dir / f"{key_name}.pem", "wb") as f:
        f.write(public_key)


def main():
    """
    Generate a GPG key for the secret file system.
    """
    key_name = sys.argv[1]
    generate_secret_file_system_keys(
        key_name=key_name,
    )


if __name__ == "__main__":
    main()
