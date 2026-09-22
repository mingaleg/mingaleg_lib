#!/bin/bash

set -e

# prepare_changelog.py imports mingaleg_lib, which isn't on sys.path when a
# script under scripts/ is run directly.
export PYTHONPATH="${PYTHONPATH:-.}"

TAG=$(python -c 'from mingaleg_lib.version import VERSION; print("v" + VERSION)')

read -p "Creating new release for $TAG. Do you want to continue? [Y/n] " prompt

if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
    python scripts/prepare_changelog.py
    git add -A
    git commit -m "Bump version to $TAG for release" || true && git push
    echo "Creating new git tag $TAG"
    git tag "$TAG" -m "$TAG"
    # Push the tag on its own rather than with --tags, and give the branch push
    # above a moment to settle first: a tag pushed immediately after a branch
    # push can be dropped by GitHub without creating a tag event, which leaves
    # the release workflow untriggered. This silently skipped the v0.2.1 and
    # v0.3.0 releases.
    sleep 5
    git push origin "$TAG"
    echo "Pushed $TAG. Check that the release workflow started:"
    echo "  https://github.com/mingaleg/mingaleg_lib/actions"
else
    echo "Cancelled"
    exit 1
fi
