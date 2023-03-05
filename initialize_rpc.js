const dotenv = require("dotenv");
dotenv.config();

const fs = require("fs");
const path = "./fRPC-Substrate/gateway/configs/quickstart_config.json";

const config = require(path);

const { ALCHEMY_RPC_URL, INFURA_RPC_URL, QUICKNODE_RPC_URL } = process.env;

config.providers = [ALCHEMY_RPC_URL, INFURA_RPC_URL, QUICKNODE_RPC_URL];

fs.writeFileSync(
  "./fRPC-Substrate/gateway/configs/config.json",
  JSON.stringify(config, null, 2)
);
