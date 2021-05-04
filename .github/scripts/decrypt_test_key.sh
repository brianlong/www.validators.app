#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$TEST_KEY_PASSPHRASE" \
--output config/credentials/test.key config/credentials/test_key.gpg