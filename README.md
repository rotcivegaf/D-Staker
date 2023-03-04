# D-Staker

A decentralized, permissionless staking service that allows anyone to stake any amount of ether, receive rewards and contribute to the ecosystem health without any restrictions.

## Tracks
* Build a Staking Pool - SSV Network
* Build a DVT-based Staking Service
* Test locally with zero-config forking using Infura's free archive node access
* Integrate Tenderly Web3 Gateway
* Tenderly Simulation API Integration
* Use fRPC to connect your dApp to Blockchain
* Connect the world with Chainlink
* Chainlink Functions

## How to run the tests
There're diffent ways to run tests
### Forge test using a goerli's fork
```sh
source .env.local && forge test --fork-url $INFURA_RPC_URL -vvv
```

### Local deployment using ganache
1 - Run ganache in one terminal
```sh
  source .env.local && ganache -f $INFURA_RPC_URL
```

2 - Deploy the contracts
```sh
  source .env.local && forge script ./script/Deploy.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY
```

3 - Run the frontend
```sh
  cd frontend && yarn dev-frontend-local
```

### Local deployment using anvil
1 - Run anvil
```sh
  source .env.local && anvil --fork-url $INFURA_RPC_URL
```

2 - Deploy the contracts
```sh
  source .env.local && forge script ./script/Deploy.s.sol --rpc-url $RPC_URL --private-key $DEPLOYMENT_PRIVATE_KEY -vvv --broadcast
```

### Deploy on a testnet
1 - Deploy the contracts using tenderly gateway
```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url $TENDERLY_GATEWAY --broadcast --private-key $PRIVATE_KEY --legacy
```

2 - Start the frontend
```sh
  yarn dev-frontend-remote
```













## Setup
1 - Install https://github.com/ethereum/staking-deposit-cli


## Create validator keys

```sh
./deposit.sh new-mnemonic --num_validators=<NUM_VALIDATORS> --mnemonic_language=english --chain=<CHAIN_NAME> --folder=<YOUR_FOLDER_PATH>
```

get operators
// https://api.ssv.network/api/v2/prater/operators - list all operators
// https://api.ssv.network/api/v2/prater/operators/42/? - get an operator data


# run the node
source .env && anvil --fork-url $INFURA_RPC_URL

# run the test locally
source .env && forge test --fork-url $INFURA_RPC_URL -vvv

# run tests on local node

# Initialization Stage
1 - Generate validator keys through ethereum staking service
2 - Select operators from ssv through ssv api (batches of four operators)
3 - Validator key distribution among operators using ssv key distributor service
4 - Registry validators in registry contract
5 - Fund operators with sufficient ssv tokens

* NOTE: validator could be registry after the stake reachs 32 ether (on demand)

#


```sh
source .env.local && forge test --fork-url $INFURA_RPC_URL
```

## Deploy on local node

### First terminal
```sh
source .env && anvil --fork-url $INFURA_RPC_URL
```

### Second Terminal
```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```


### Deploy with tenderly gateway
```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url https://goerli.gateway.tenderly.co/4qcCAJIkvm7jWdk51yzcu9 --broadcast --private-key $PRIVATE_KEY --legacy
```

### USE fRPC

1 - Clone https://github.com/fluencelabs/fRPC-Substrate
2 - Follow the guide

```sh
npm run run configs/quickstart_config.json
```



### Use ganache for local testing

1 -

```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url http://127.0.01:8545 --broadcast --private-key 0xa545b25e3591733f315337baaf4d972104470122f39a441295d8378c6ee05edb
```





### Test locally with zero-config forking using Infura's free archive node access
- A list of any challenges or benefits you encountered while using Ganache

- Judging will lean towards full MVPs and applications that interact with pre-deployed contracts





https://github.com/fluencelabs/ethdenver-2023/blob/main/README.md


### Add Rewards
1 - On ganache (localy)
```sh
  source .env.local && forge script ./script/AddRewards.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY
```

2 - Remotely
```sh
  source .env.local && forge script ./script/AddRewards.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

### Stake
1 - On ganache (localy)
```sh
  source .env.local && forge script ./script/Stake.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY
```

2 - Remotely
```sh
  source .env.local && forge script ./script/Stake.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```

### Unstake
1 - On ganache (localy)
```sh
  source .env.local && forge script ./script/Unstake.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY
```

2 - Remotely
```sh
  source .env.local && forge script ./script/Unstake.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
```




## add rewards on anvil
source .env.local && AMOUNT=30 SCA=0x0a08a41b691ec9954cc3170f9fb9ae819686ba00 forge script ./script/AddRewards.s.sol --rpc-url $ANVIL_RPC_URL --broadcast --private-key $ANVIL_PRIVATE_KEY -vvvv

## add rewards on ganache
source .env.local && AMOUNT=30 SCA=0x0a08a41b691ec9954cc3170f9fb9ae819686ba00 forge script ./script/AddRewards.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY -vvvv