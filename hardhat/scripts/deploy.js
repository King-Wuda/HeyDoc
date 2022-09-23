const { ethers } = require("hardhat");

async function main() {
  const databaseContract = await ethers.getContractFactory("MedicDatabase");
  const deployedDatabase = await databaseContract.deploy();
  await deployedDatabase.deployed();
  console.log("MedicDatabase contract address:", deployedDatabase.address);

  const nftContract = await ethers.getContractFactory("BasicNft");
  const deployedNft = await nftContract.deploy();
  await deployedNft.deployed();
  console.log("DoctorNFT contract address:", deployedNft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
