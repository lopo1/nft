const {ethers} = require("ethers");
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
async function main() {

// 白名单地址，这里采用了硬编码，实际开发应该从数据库读取
// 这里我们随机生成几个地址，作为白名单示例
let list =[{address:"0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"},{address:"0x39Ef50bd29Ae125FE10C6a909E42e1C6a94Dde29"},{address:"0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"},{address:"0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"}];
    //叶子结点数据
  let leafs = [];
  for (let k = 0; k < list.length; k++) {
    let leaf = ethers.utils.solidityKeccak256(["address"], [list[k].address]);
    leafs.push(leaf);
  }

  //树根
  let tree = new MerkleTree(leafs, keccak256, { sort: true });
 // 打印查看 Root 数据，需要设置到合约中
  let root = tree.getHexRoot();
  console.log("root = ",root);

  const rootHash = tree.getRoot();
  console.log("rootHash = ",rootHash);
  //叶子proof
  let proofs = [];
  leafs.map((item) => {
    proofs.push(tree.getHexProof(item));
  });

  let res = [];
  for (let index = 0; index < list.length; index++) {
    res.push([list[index].address, proofs[index]]);
  }
   //组装的数据
  console.log("res = ",res);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });