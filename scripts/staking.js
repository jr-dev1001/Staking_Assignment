const hre = require("hardhat");
const ethers = require("ethers");
async function main() {
    const MyContract = await ethers.getContractFactory("Staking");
    // this is random address used for demo 
    const tokenAddress = '0x80f02c6AD89989EABde40010eEE56f90593850a8';
    const myContract = await MyContract.deploy(tokenAddress);
    // Send the reserved tokens to the staking contract. 
    // next we can able to use the staking functions
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });