
const hre = require("hardhat");
const fs = require('fs')

async function main() {
    // deploy Marketyplace contract
  const NFTMarket = await hre.ethers.getContractFactory("Market");
  const nftMarket = await NFTMarket.deploy();
  await nftMarket.deployed();
  console.log("nftMarket contract deployed to: ", nftMarket.address);

  // deploy NFT contract
  const NFT = await hre.ethers.getContractFactory("NFT");
  // remember: should  pass marketplace's address into constructor of NFT contract
  const nft = await NFT.deploy(nftMarket.address);
  await nft.deployed();
  console.log("NFT contract deployed to: ", nft.address);
  
  // export addresses of contracts into config.js
  // because in website, need use the addresses
  let config = `
  export const nftmarketaddress = '${nftMarket.address}'
  export const nftaddress = '${nft.address}'`
  // parse in JSON and write into config.js
  let data = JSON.stringify(config)
  fs.writeFileSync('config.js', JSON.parse(data))

}



main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
