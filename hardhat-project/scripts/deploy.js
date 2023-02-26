const {ethers} = require("hardhat");

require("dotenv").config({path:".env"});
const {WHITELIST_CONTRACT_ADDRESS, METADATA_URL} = require("../constants")


async function main() {
   const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
   const metadataUrl = METADATA_URL;

   const SprintersContract = await ethers.getContractFactory("Sprinters");
   const deployedSprintersContract = await SprintersContract.deploy(
    metadataUrl,
    whitelistContract
   );

   await deployedSprintersContract.deployed();

   console.log("Sprinters NFT Contract Address:", deployedSprintersContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });