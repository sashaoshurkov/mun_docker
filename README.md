# MUN Blockchain Docker

# Start MUN Blockchain
docker run -d --name mun_node --restart always --network host -v $HOME/.mun:/root/.mun sashaoshurkov/mun:latest
