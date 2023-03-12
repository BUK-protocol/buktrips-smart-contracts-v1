import * as hre from "hardhat";
import { Web3Service } from "../utils/functions/web3";
import { CONTRACT } from "../utils/config";
import { utils } from "ethers"

async function main() {
  const web3Service = new Web3Service()
  const supplierName = "BukTrips.com Powered by Expedia"
  const name = utils.formatBytes32String("BukTrips.com Powered by Expedia")
  const result = await web3Service.registerSupplier(supplierName, name, CONTRACT.BUK_WALLET, "https://ipfs.io/ipfs/bafkreia3cbw2xztf2xyl4ivuxhbtxa3xjlbpvk4eyolbkzhlnpnclgsa3q")
  console.log("🚀 ~ file: registerHotel.ts:10 ~ main ~ result", result)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
