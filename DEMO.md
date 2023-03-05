1 - Run ganache

```sh
source .env.local && ganache -f $INFURA_RPC_URL
```

2 - Deploy contract on ganache

```sh
source .env.local && forge script ./script/Deploy.s.sol --rpc-url $RPC_URL --private-key $DEPLOYMENT_PRIVATE_KEY -vvv --broadcast
```

3 - Run frontend

```sh
  cd frontend && yarn dev
```

4 - Stake through frontend

5 - Register validator throug defender and api

```sh
  cd api && node demo/run.js
```

6 - Add Rewards
```sh
source .env.local && AMOUNT=5 SCA=0x0a08a41b691ec9954cc3170f9fb9ae819686ba00 forge script ./script/AddRewards.s.sol --rpc-url $GANACHE_RPC_URL --broadcast --private-key $GANACHE_PRIVATE_KEY -vvvv
```


7 - Claim rewards through front

8 - Stake more eth through front

9 - Unstake available eth through front