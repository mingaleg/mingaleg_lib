[![Main](https://github.com/mingaleg/mingaleg_lib/actions/workflows/main.yml/badge.svg)](https://github.com/mingaleg/mingaleg_lib/actions/workflows/main.yml)
[![PyPI](https://img.shields.io/pypi/v/mingaleg-lib)](https://pypi.org/project/mingaleg-lib/)

# mingaleg-lib

[@mingaleg](https://github.com/mingaleg)'s personal Python library.

Its main feature is a **secret file system**: a directory of private files, encrypted
into the repository so it can be committed to git, and readable at runtime by anyone
holding one of the corresponding RSA private keys.

## In this README :point_down:

- [Installation](#installation)
- [The secret file system](#the-secret-file-system)
  - [Reading secrets](#reading-secrets)
  - [Writing secrets](#writing-secrets)
  - [How it works](#how-it-works)
- [Development](#development)
- [Releases](#releases)

## Installation

Requires **Python 3.11 or newer**.

```bash
pip install mingaleg-lib
```

Or from source:

```bash
git clone https://github.com/mingaleg/mingaleg_lib.git
cd mingaleg_lib
pip install -e .
```

## The secret file system

### Reading secrets

The encrypted archives ship inside the package, so reading a secret only needs a private
key. Point `MINGALEG_SECRET_FS_PRIVATE_KEY` at your PEM-encoded key:

```python
from mingaleg_lib.secrets.file_system import secret_file_system

hello = secret_file_system()["hello.txt"].read().decode("utf-8")
```

Indexing returns a binary file object, and paths are relative to the root of the secret
file system. A missing path raises `FileNotFoundError`.

The key can also be passed explicitly, which skips the environment variable:

```python
secret_file_system(private_key=Path("~/.keys/mingamini.pem").expanduser().read_bytes())
```

`secret_file_system()` is cached, so repeated calls reuse one decrypted archive. It tries
every bundled archive in turn and returns the first one your key opens; if none do, it
raises `InvalidPrivateKey`. A missing `MINGALEG_SECRET_FS_PRIVATE_KEY` with no explicit
key raises `SecretFileSystemException`.

### Writing secrets

Keep the plaintext files in a directory outside version control — `/secrets/` and
`/keyring/` at the repo root are both gitignored for this. To re-encrypt them for every
public key in [`mingaleg_lib/secrets/public_keyring/`](mingaleg_lib/secrets/public_keyring):

```bash
python -m mingaleg_lib.secrets.encrypt /path/to/plaintext/dir
```

This rewrites one `.bin` per public key in
[`mingaleg_lib/secrets/encrypted/`](mingaleg_lib/secrets/encrypted), which are the files
you commit. Adding a new reader means dropping their public key into `public_keyring/`
and re-running the command; revoking one means deleting both their `.pem` and their
`.bin`, then rotating whatever they could read.

### How it works

Each archive is the plaintext directory as a gzipped tarball, encrypted with a random
AES-128-EAX session key; that session key is itself encrypted to one RSA public key with
PKCS#1 OAEP. The `.bin` layout is the encrypted session key, then the 16-byte nonce, the
16-byte tag, and the ciphertext. Because the payload is encrypted once per recipient
rather than shared, each holder needs only their own private key.

## Development

The project uses [uv](https://docs.astral.sh/uv/):

```bash
uv sync --extra dev
```

Then:

```bash
make run-checks   # isort, black, ruff, mypy, pytest
make fix-checks   # same, but applies the formatters' and ruff's fixes
make docs         # live-reloading Sphinx build
```

:warning: The test suite reads the secret file system, so `make run-checks` needs
`MINGALEG_SECRET_FS_PRIVATE_KEY` set. In CI it comes from the repository secret of the
same name, decrypting the `github-ci` archive.

## Releases

Bump the version in `mingaleg_lib/version.py` and follow
[`RELEASE_PROCESS.md`](./RELEASE_PROCESS.md). Tagging triggers the GitHub Actions
workflow that publishes both the GitHub release and the PyPI package.
