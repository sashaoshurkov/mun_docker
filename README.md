# Install utils
```bash
apt update && apt install -y curl jq
```

# Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
```

# Initialize the validator with a moniker name (Example moniker_name: solid-moon-rock)
```bash
docker run --rm --name mun_init --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest mund init [moniker_name] --chain-id testmun
```

# Add a new wallet address, store seeds and buy TMUN to it (Example wallet_name: solid-moon-rock)
```bash
docker run --rm -it --name mun_init --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest mund keys add [wallet_name] --keyring-backend test
```

# Fetch genesis.json from genesis node
```bash
curl --tlsv1 https://node1.mun.money/genesis? | jq ".result.genesis" > $HOME/.mun/config/genesis.json
```

# Set up node configuration
```bash
seeds="9240277fca3bfa0c3b94efa60215ca10cf54f249@45.76.68.116:26656"; \
sed -i "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.mun/config/config.toml; \
sed -i "s/stake/utmun/g" ~/.mun/config/genesis.json
```

# Start MUN Validator
```bash
docker run -d --name mun_node --restart always --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest
```

# Verify node is running properly
```bash
docker exec -it mun_node mund status
```

# After buying TMUN, stake it to become a validator
```bash
tendermint=$(docker exec -it mun_node mund tendermint show-validator); \
docker exec -it mun_node mund tx staking create-validator --from [wallet_name] --moniker [moniker_name] --pubkey $tendermint --chain-id testmun --keyring-backend test --amount 50000000000utmun --commission-max-change-rate 0.01 --commission-max-rate 0.2 --commission-rate 0.1 --min-self-delegation 1 --fees 200000utmun --gas auto --gas=auto --gas-adjustment=1.5 -y
```
# Get out of jail
```bash
docker exec -it mun_node mund tx slashing unjail --from [wallet_name] --chain-id testmun --keyring-backend test
```