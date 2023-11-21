#!/bin/bash

cd contracts
source .env
anvil --fork-url $FORK_URL_MAINNET
