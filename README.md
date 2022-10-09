# Install utils
apt update && apt install -y curl jq 

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Initialize the validator with a moniker name (Example moniker_name: solid-moon-rock)
docker run --rm --name mun_init --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest mund init [moniker_name] --chain-id testmun

# Add a new wallet address, store seeds and buy TMUN to it. (Example wallet_name: solid-moon-rock)
docker run --rm --name mun_init --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest mund keys add [wallet_name] --keyring-backend test

# Fetch genesis.json from genesis node
curl --tlsv1 https://node1.mun.money/genesis? | jq ".result.genesis" > ~/.mun/config/genesis.json

# Update seed in config.toml to make p2p connection
seeds="9240277fca3bfa0c3b94efa60215ca10cf54f249@45.76.68.116:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.mun/config/config.toml

# Replace stake to TMUN
sed -i 's/stake/utmun/g' ~/.mun/config/genesis.json

# Start MUN Validator
docker run -d --name mun_node --restart always --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest

# Verify node is running properly
docker exec -it mun_node mund status

# After buying TMUN, stake it to become a validator
docker exec -it mun_node mund tx staking create-validator --from [wallet_name] --moniker [moniker_name] --pubkey $(mund tendermint show-validator) --chain-id testmun --keyring-backend test --amount 50000000000utmun --commission-max-change-rate 0.01 --commission-max-rate 0.2 --commission-rate 0.1 --min-self-delegation 1 --fees 200000utmun --gas auto --gas=auto --gas-adjustment=1.5 -y
