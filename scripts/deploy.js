async function main() {
    const { ethers } = require("hardhat");
  
    const Verify = await ethers.getContractFactory("Verify");
  
    const tempNodeContractAddress = "0x0000000000000000000000000000000000000000";
    const tempMainContractAddress = "0x0000000000000000000000000000000000000000"; 
  
    const verify = await Verify.deploy(tempNodeContractAddress, tempMainContractAddress);
  
    await verify.deployed();
  
    console.log("adress", verify.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
