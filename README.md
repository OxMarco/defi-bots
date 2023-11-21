# DeFi Strategies
A collection of smart contracts to create defi strategies.

## Backend
### Installation
Prerequisites are:
- Python
- Pip
- Virtualenv

## Contracts
### List
* **SimpleStaker** provide liquidity to AaveV3 and Clearpool
* **Rebalancer** manage liquidity on UniV3 positions
* **SimpleArbitrage** arbitrage between two exchanges
* **FlashLoanedArbitrage** arbitrage between two exchanges using flash loans
* **JIT** just in time liquidity provision via flash loans

### Installation
Prerequisites are:
- Git
- Rust
- Foundry (installation guide: https://book.getfoundry.sh/getting-started/installation)

Create an environment file `.env` copying the template environment file

```bash
cp .env.example .env
```

and add the following content:

```text
FORK_URL_MAINNET="https://..." needed to run ethereum mainnet fork tests
```

Load it in your local env with `source .env` and finally you can install foundry and compile the contracts:

```bash
forge install
forge build
```

Finally, to test the codebase you can run

```bash
forge test
```

and to view in details the specific transactions stacktrace

```bash
forge test -vvvv
```
