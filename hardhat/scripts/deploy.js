const { ethers } = require("hardhat");

async function main() {
  const databaseContract = await ethers.getContractFactory("medicDatabase");
  const deployedDatabase = await databaseContract.deploy();
  console.log("MedicDatabase contract address:", deployedDatabase.address);

  const nftContract = await ethers.getContractFactory("doctorNft");
  const deployedNft = await nftContract.deploy();
  console.log("DoctorNFT contract address:", deployedNft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
