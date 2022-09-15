// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
let fs = require('fs');

async function main() {
  var contracts = {};
  let filePath = "./Contract.json";
  if (!fs.existsSync(filePath)){
    fs.writeFileSync(filePath, JSON.stringify(contracts))
  }
  contracts= JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();
  await nft.deployed();
  console.log("NFT deployed to:", nft.address);
  contracts.NFT = nft.address;
  
  console.log(contracts)

  // 写入文件
  try {
    const data = fs.writeFileSync('./Contract.json',JSON.stringify(contracts));
    console.log(data)
    //文件写入成功。
  } catch (err) {
    console.error(err)
  }

  //verify 
  await verifyContract("contracts/NFT.sol:NFT", contracts.NFT);


}
async function verifyContract(contractName, contractAddress, args) {
  try {
      console.log("Verifying contract...");
      await hre.run("verify:verify", {
          contract: contractName, address: contractAddress, constructorArguments: args
      });
      console.log('Verification Completed')
      console.log("\n");
  } catch (err) {
      console.log('Already Verified')
      console.log("\n");
      console.log(err)
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
