from pathlib import Path

from mingaleg_lib.secrets.encrypt import encrypt_secret_file_system_all

CWD = Path(__file__).parent


def main():
    """
    Encrypt the secret file system.
    """
    encrypt_secret_file_system_all(CWD.parent / "secrets" / "file_system")


if __name__ == "__main__":
    main()
