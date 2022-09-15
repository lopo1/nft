# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

## 公共说明
- nft类型一共只有3种class 1 普通NFT,2 中等NFT,3 高级NFT
- rinkeby NFT 合约地址 0x5fD8BAfa6a03228E6bed8019C9Dccbe5749d8347

```
 struct NFTInfo{
        uint256 max; // nft最大可铸造数
        uint256 counter; //nft tokenID 下标
        uint256 price; //铸造单个NFT的价格
    }

    struct GuestInfo{
        uint256 max; //最大铸造数
        uint256 startTime; // 开始时间段时间(s) 如：每天8点，那么设置就是28800
        uint256 endTime; //结束时间段时间(s)
    }
```

### 1. 根据nft类型 获取NFT设置信息 getClassInfo(uint256 class)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| class | uint256 | nft 类型 |

### 2. 获取nft类型下所有的NFT列表 getClassNfts(uint256 class)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| class | uint256 | nft 类型 |

### 3. 获取nft类型下还可以铸造的nft数量 getCanBuyNum(uint256 class)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| class | uint256 | nft 类型 |

### 4. 获取nft是什么类型 getNftClass(uint256 tokenId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| tokenId | uint256 | nft tokenId |

### 5. 获取用户的nft列表  getMyNFT(address addr)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| tokenId | uint256 | nft tokenId |

### 6. 铸造nft  safeMint(uint256 class,uint256 number,bytes32[] calldata proofs)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| class | uint256 | nft 类型 |
| number | uint256 | 铸造NFT数量 |
| proofs | bytes32[] | 子节点数据 |

### 7. 提案添加、删除审核地址  submitOwner(address _owner,bool _isAdd)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _owner | address | nft 类型 |
| _isAdd | bool | true新增，false删除 |

### 8. 审批添加审核地址提案 addOwner(uint _txId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _txId | uint | 提案id |

### 9. 删除添加审核地址提案 revokeOwner(uint _txId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _txId | uint | 提案id |

### 10. 移除提现提案 revoke(uint _txId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _txId | uint | 提案id |

### 11. 提现提案多签审核 withdraw(uint _txId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _txId | uint | 提案id |

### 12. 设置默克尔树根节点 setMerkleRoot(bytes32 _root)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _root | bytes32 | 默克尔树根节点 |

### 13. 设置非白名单铸造信息 setGuestInfo(GuestInfo memory gInfo)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| gInfo | GuestInfo | 非白名单铸造信息 |

### 14. 获取非白名单还可铸造的nft数 getGuestSurplus()
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |


### 15. 获取游客铸造信息 getGuestInfo()
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |


### 16. 获取剩余可铸造的nft数 getTotalSurplus()
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |

### 17. 获取提现目前审核数 getApprovalCount(uint _txId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| _txId | uint | 提案id |

### 18. 获取原始铸造地址 tokenOwner(uint256 tokenId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| tokenId | uint256 | tokenId |

### 19. 获取NFT拥有者 ownerOf(uint256 tokenId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| tokenId | uint256 | tokenId |

### 20. 获取NFT URL tokenURI (uint256 tokenId)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| tokenId | uint256 | tokenId |

### 21. 获取NFT 出售时间 startTime()
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |

### 22. 获取NFT 出售结束时间 endTime()
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |

### 23. 设置NFT 出售开始时间 setStartTime(uint256 time)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| time | uint256 | 开始时间戳 |
### 23. 设置NFT 出售结束时间 setEndTime(uint256 time)
|字段| 类型 | 说明 |
| :----: | :----:  | :----: |
| time | uint256 | 结束时间戳 |

