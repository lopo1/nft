// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFT is ERC721PresetMinterPauserAutoId {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    

    mapping(uint256=>EnumerableSet.UintSet) private nftList;
    mapping(uint256=>NFTInfo) private nftInfo;
    mapping(uint256=>uint256) private nftClass;

    EnumerableSet.AddressSet private owners;
    uint public constant required=2;
    uint256 public constant totalNfts=6000;
    Transaction[] public transactions;
    mapping(uint=>mapping(address=>bool))public approved;

    OwnerVote[] public ownerVotes;
    mapping(uint=>mapping(address=>bool))public ownerApproved;
    mapping(uint256=>address) public tokenOwner;

    string private BaseUri = "https://bsc-api.seascape.network/nft/metadata/";
    bytes32 private root;
    GuestInfo private guestInfo;
    uint256 public startTime;
    uint256 public endTime;


    modifier onlyOwner(){
        require(owners.contains(_msgSender()),"not onwer");
        _;
    }

    modifier txExists(uint _txId){
        require(_txId<transactions.length,"tx dows not exist");
        _;
    }
    modifier notApproved(uint _txId){
        require(!approved[_txId][_msgSender()],"tx already approved");
        _;
    }
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed,"tx already executed");
        _;
    }

    modifier txOwnerExists(uint _txId){
        require(_txId<ownerVotes.length,"tx dows not exist");
        _;
    }
    modifier notOwnerApproved(uint _txId){
        require(!ownerApproved[_txId][_msgSender()],"tx already approved");
        _;
    }
    modifier notOwnerExecuted(uint _txId){
        require(!ownerVotes[_txId].executed,"tx already executed");
        _;
    }

    constructor()ERC721PresetMinterPauserAutoId("PANBO NFT", "PANBO", "") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
        require(owners.add(_msgSender()),"add fail");
        nftInfo[1] = NFTInfo(5400,601,0.01 ether);
        nftInfo[2] = NFTInfo(300,301,0.02 ether);
        nftInfo[3] = NFTInfo(300,1,0.03 ether);
    }
    
    struct NFTInfo{
        uint256 max;
        uint256 counter;
        uint256 price;
    }

    struct GuestInfo{
        uint256 max;
        uint256 startTime;
        uint256 endTime;
    }

    struct Transaction{
        address to;
        uint256 value;
        uint256 vote;
        bool executed;
    }

    struct OwnerVote{
        address owner;
        uint256 vote;
        bool isAdd;
        bool executed;
    }
    /* ============================================== EVENT START ================================================ */
    event SafeMint(address indexed sender,address indexed to, uint256[] tokenId,uint256 number, uint256 createtime);
    event ChangeUrl(address indexed sender, string oldUrl,string newUrl, uint256 createtime);
    event Withdraw(address indexed sender, address withAddr,uint256 amount, uint256 createtime);
    event Submit(uint indexed txId);
    event Approve(address indexed owner,uint indexed txId,uint256 genre);
    event Revoke(address indexed owner,uint indexed txId,uint256 genre);
    event Execute(uint indexed txId,uint256 genre);
    event SetMerkleRoot(address indexed sender,bytes32 root,bytes32 oldRoot);
    event SetGuestInfo(address indexed sender,GuestInfo gInfo);
    event SetStartTime(address indexed sender,uint256 indexed startTime);
    event SetEndTime(address indexed sender,uint256 indexed startTime);
    /*=============================================== EVENT END ================================================== */

     /* ==================================== ERROR START ======================================== */
    error Unauthorized();
    /* ==================================== ERROR END ======================================== */

    /* =================================== Mutable Functions START ================================ */
    
    function safeMint(uint256 class,uint256 number,bytes32[] calldata proofs) payable external {
        require(startTime<=block.timestamp,"Presale hasn't started yet");
        require(endTime>=block.timestamp,"Pre -sale has ended");
        bytes32 _leaf = keccak256(abi.encodePacked(_msgSender()));
        bool _verify = MerkleProof.verify(proofs, root, _leaf);
        if(!_verify){
            require(getGuestSurplus()>=number,"guest buy nft limit");
            require(getGuestStartTime(guestInfo.startTime)<=block.timestamp,"guest buy not start");
            require(getGuestStartTime(guestInfo.endTime)>=block.timestamp,"guest buy is end");
            guestInfo.max = guestInfo.max.sub(number);
        }
        require(msg.value>=number.mul(nftInfo[class].price),"amount fail");
        require(getCanBuyNum(class)>=number,"mint limit");
        uint256[] memory tokenIds = new uint256[](number);
        tokenIds = inerMint(class, number);
        
        emit SafeMint(_msgSender(),_msgSender(),tokenIds,number,block.timestamp);
    }


    function inerMint(uint256 class,uint256 number) private returns(uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](number);
        for(uint256 i=0;i<number;i++){
            uint256 tokenId = creatTokenId(class);
            tokenIds[i] = tokenId;
            tokenOwner[tokenId] = _msgSender();
            _safeMint(_msgSender(), tokenId);
        }
        return tokenIds;
    }

    function creatTokenId(uint256 class) private  returns(uint256){
        uint256 tokenId = nftInfo[class].counter;
        require(nftList[class].length() < nftInfo[class].max,"mint limit");
        nftInfo[class].counter = nftInfo[class].counter.add(1);
        require(tokenId>0,"tokenId is fail");
        require(nftList[class].add(tokenId));

        return tokenId;
    }

    function changeUri(string memory uri) external onlyRole(MINTER_ROLE) {
        
        emit ChangeUrl(_msgSender(),BaseUri,uri,block.timestamp);
        BaseUri = uri;
    }
    function setStartTime(uint256 time) external onlyRole(MINTER_ROLE) {
        startTime = time;
        emit SetStartTime(_msgSender(),time);
    }
    function setEndTime(uint256 time) external onlyRole(MINTER_ROLE) {
        endTime = time;
        emit SetEndTime(_msgSender(),time);
    }
    function mint(address /*to*/) public virtual override(ERC721PresetMinterPauserAutoId){
        revert Unauthorized();
    }

    
    function submitOwner(address _owner,bool _isAdd) external onlyOwner{
        ownerVotes.push(OwnerVote({
            owner:_owner,
            vote:0,
            isAdd:_isAdd,
            executed:false
        }));
        emit Submit(ownerVotes.length-1);
    }

    function addOwner(uint _txId) external onlyOwner txOwnerExists(_txId) notOwnerApproved(_txId) notOwnerExecuted(_txId){
        ownerApproved[_txId][_msgSender()] = true;
        ownerVotes[_txId].vote +=1;
        if(ownerVotes[_txId].vote>owners.length().div(required)){
            executeOwner(_txId);
        }
        emit Approve(_msgSender(), _txId,1);
    }

    

    function executeOwner(uint _txId) public txOwnerExists(_txId) notOwnerExecuted(_txId){
        OwnerVote storage ownerVote = ownerVotes[_txId];
        require(ownerVote.vote>owners.length().div(required),"apprvals < requird");
        ownerVote.executed = true;
        if(ownerVote.isAdd){
            require(!owners.contains(ownerVote.owner),"owner already exists");
            require(owners.add(ownerVote.owner),"add owner fail");
        }else{
            require(owners.remove(ownerVote.owner),"remove owner fail");
        }
       
        emit Execute(_txId,1);
    }

    function revokeOwner(uint _txId) external onlyOwner txExists(_txId)  notOwnerExecuted(_txId){
        require(ownerApproved[_txId][_msgSender()],"tx not approved");
        ownerApproved[_txId][_msgSender()] = false;
        emit Revoke(_msgSender(), _txId,1);
    }


    function submit(address _to,uint _value) external onlyOwner{
        transactions.push(Transaction({
            to:_to,
            value: _value,
            vote:0,
            executed:false
        }));
        emit Submit(transactions.length-1);
    }

    function withdraw(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){
        approved[_txId][_msgSender()] = true;
        transactions[_txId].vote +=1;
        if(transactions[_txId].vote>owners.length().div(required)){
            execute(_txId);
        }
        emit Approve(_msgSender(), _txId,2);
    }

    

    function execute(uint _txId) public txExists(_txId) notExecuted(_txId){
        Transaction storage transaction = transactions[_txId];
        require(transaction.vote>owners.length().div(required),"apprvals < requird");
        transaction.executed = true;
        payable(transaction.to).transfer(transaction.value);
        emit Execute(_txId,2);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId)  notExecuted(_txId){
        require(approved[_txId][_msgSender()],"tx not approved");
        approved[_txId][_msgSender()] = false;
        emit Revoke(_msgSender(), _txId,2);
    }

    function setMerkleRoot(bytes32 _root) external onlyRole(MINTER_ROLE) {
        require(_root!=root,"There is no change");
        emit SetMerkleRoot(_msgSender(),_root,root);
        root = _root;
    }

    function setGuestInfo(GuestInfo memory gInfo) external onlyRole(MINTER_ROLE) {
        require(getTotalSurplus() >= gInfo.max,"exceed the limit");
        require(gInfo.max>0,"number fail");
        guestInfo = gInfo;
        emit SetGuestInfo(_msgSender(),gInfo);

    }

    /* =================================== Mutable Functions END ================================ */



    /* ====================================== View Functions START ================================ */
    function getGuestStartTime(uint256 start) public view returns(uint256){
        return block.timestamp.div(86400).mul(86400).add(start);
    }
    
    function getGuestSurplus() public view returns(uint256 max) {
        if(getTotalSurplus()<guestInfo.max){
            max = getTotalSurplus();
        }
        max = guestInfo.max;
    }

    function getGuestInfo() external view returns(GuestInfo memory) {
        return guestInfo;
    }

    function getTotalSurplus() public view returns(uint256){
        return totalNfts.sub(totalSupply()); 
    }

    function getMyNFT(address addr) external view returns(uint256[] memory infos) {
        uint256 total =  balanceOf(addr);
        infos = new uint256[](total);
        if (total > 0) {
            for (uint256 i=0; i < total; i++) {
                uint256  tokenID = tokenOfOwnerByIndex(addr, i);
                infos[i] = tokenID;
            }
        }
    }

    function getApprovalCount(uint _txId) external view returns(uint count){
        count = transactions[_txId].vote;
    }
    function getNftClass(uint256 tokenId) external view returns(uint256) {
        return nftClass[tokenId];
    }
    function getCanBuyNum(uint256 class) public view returns(uint256) {
        return nftInfo[class].max.sub(nftList[class].length());
    }
    function getClassIndex(uint256 class) external view returns(uint256){
        return nftInfo[class].counter;
    }

    function getClassInfo(uint256 class) external view returns(NFTInfo memory){
        return nftInfo[class];
    }
    function getClassNfts(uint256 class) external view returns(uint256[] memory) {
        return nftList[class].values();
    }
     function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
            internal
            whenNotPaused
            override(ERC721PresetMinterPauserAutoId)
        {
            super._beforeTokenTransfer(from, to, tokenId);
        }
    function _baseURI() internal view virtual override(ERC721PresetMinterPauserAutoId) returns(string memory)
        {
            return BaseUri;
        }
    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721PresetMinterPauserAutoId)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    /* ====================================== View Functions END ================================ */
    
   
}
