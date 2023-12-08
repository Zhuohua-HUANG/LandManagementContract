// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract LandSaleAndDistributionSystem{
    struct Land{
        uint id;
        bool isSellable;
        bool isSelling;
        address owner;
        uint price;
        address successor;
    }
    
    address immutable birthManager;
    uint256 private immutable landNumber;
    uint256 private peopleNumber;

    mapping(address => uint256[]) peopleOwnership;
    address[] peopleOwnershipKeys;
    mapping (uint256 => Land) landMap;
    uint256[] landSaleList;
    uint256[] unusedLandList;
    mapping(address=> bool) isValidPerson;

    modifier onlyValidPerson(address person){
        require(isValidPerson[person], "not valid person");
        _;
    }

    modifier onlyBirthManager(address person){
        require(person==birthManager, "not Birth Manager");
        _;
    }

    modifier validLandID(uint id){
        require(id >= 0 && id < landNumber, "not valid id");
        _;
    }

    modifier onlyLandOwner(address person, uint id){
        require(person == landMap[id].owner,"you must be the owner of the land");
        _;
    }

    modifier onlySellable(uint id){
        require(landMap[id].isSellable=true, "the land is not sellable");
        _;
    }

    modifier onlySelling(uint id){
        require(landMap[id].isSelling=true, "the land is not selling");
        _;
    }
    
    constructor(uint256 _landNumber){
        birthManager=msg.sender;
        landNumber=_landNumber;
        peopleNumber=0;
        // sell the land if do not have owner
        for(uint i=0; i<landNumber;i++){
            landMap[i] = Land(i, true, true, address(0), 1, address(0)); 
            landSaleList.push(i);
            unusedLandList.push(i);
        }
    }
    
    // sale your land or update the price of your selling land
    function saleLand(uint256 id, uint256 price) public 
    onlyValidPerson(msg.sender) 
    validLandID(id) 
    onlyLandOwner(msg.sender,id) 
    onlySellable(id) 
    {
        require(price > 0,"not valid price");
        if(!landMap[id].isSelling){
            landSaleList.push(id);
            landMap[id].isSelling = true;
        }
        landMap[id].price = price;
    }


    function removeSellingLand(uint256 id) internal {
        // land is not selling
        if(!landMap[id].isSelling) return;
        uint i;
        bool isFound=false;
        uint len=landSaleList.length;
        // remove from landSaleList
        for(i=0;i<len;i++){
            if(landSaleList[i]==id){
                isFound=true;
                break;
            }
        }
        landSaleList[i]=landSaleList[landSaleList.length-1];
        landSaleList.pop();

        // update selling state
        landMap[id].isSelling=false;
    }

    // buy land
    function buyLand(uint256 id) public payable 
    onlyValidPerson(msg.sender) 
    validLandID(id)
    onlySelling(id)
    {
        uint price = landMap[id].price;
        require(msg.value >= price * 1 ether,"not enough Ether");
        address oldOwner=landMap[id].owner;

        removeSellingLand(id);
        
        // update landMap
        landMap[id].owner=msg.sender;
        landMap[id].successor=address(0);

        
        if(oldOwner==address(0)){
            // handle unusedLand
            uint i;
            uint len=unusedLandList.length;
            for(i=0;i<len;i++){
                if(id==unusedLandList[i]){
                    break;
                }
            }
            unusedLandList[i]=unusedLandList[unusedLandList.length-1];
            unusedLandList.pop();
        }else{
            // remove oldowner's peopleOwnership
            uint j;
            for(j=0;j<peopleOwnership[oldOwner].length;j++){
                if(id==peopleOwnership[oldOwner][j]){
                    break;
                }
            }
            peopleOwnership[oldOwner][j]=peopleOwnership[oldOwner][peopleOwnership[oldOwner].length-1];
            peopleOwnership[oldOwner].pop();
        }
        // add peopleOwnership
        peopleOwnership[msg.sender].push(id);
        
        // send money to seller
        if(oldOwner!=address(0)){
            (bool success, ) = oldOwner.call{value: price * 1 ether}("");
            require(success, "Failed to send Ether");
        }
        // return money to buyer
        uint left=msg.value-price*1 ether;
        if(left>0){
            (bool success, ) = msg.sender.call{value: left}("");
            require(success, "Failed to return Ether");
        }
    }

    // stop selling your land
    function stopSelling(uint256 id) public 
    onlyValidPerson(msg.sender) 
    validLandID(id) 
    onlyLandOwner(msg.sender, id)
    onlySelling(id)
    {
        removeSellingLand(id);
    }

    // check the land owner if 0 then not owner now
    function getLandOwner(uint256 id) view public 
    validLandID(id) 
    returns (address owner)
    {
        return landMap[id].owner;
    }

    // get your land list
    function getMyLandList()  view public 
    onlyValidPerson(msg.sender)
    returns (uint256[] memory ids, string[] memory tradableStatus, string[] memory isSelling, uint256[] memory prices, address[] memory successors)
    {
        ids = peopleOwnership[msg.sender];
        uint len=ids.length;
        tradableStatus=new string[](len);
        isSelling=new string[](len);
        prices=new uint256[](len);
        successors=new address[](len);
        for(uint i=0;i<len;i++){
            uint id=ids[i];
            string memory tradableState="false";
            if(landMap[id].isSellable){
                tradableState="true";
            }
            tradableStatus[i]=tradableState;
            string memory isSellingState="false";
            if(landMap[id].isSelling){
                isSellingState="true";
            }
            isSelling[i]=isSellingState;
            prices[i]=landMap[id].price;
            successors[i]=landMap[id].successor;
        }
    }

    // get the list of sale land
    function getLandSaleList() view public returns (uint256[] memory ids, uint256[] memory prices){
        ids=landSaleList;
        uint len=landSaleList.length;
        prices=new uint256[](len);
        for(uint i=0; i<len; i++){
            uint id=landSaleList[i];
            prices[i]=landMap[id].price;
        }
    }

    // assign the inheritance of your land
    function assignInheritance(uint id, address to) public
    onlyValidPerson(msg.sender) 
    onlyValidPerson(to)
    validLandID(id) 
    onlyLandOwner(msg.sender,id) 
    { 
        require(to != msg.sender,"can't set yourself as your successor");
        landMap[id].successor = to;
    }

    function distributeUnusedLand(address to, bool isSellable) internal {
        require(unusedLandList.length>0);
        // get the last one of unused land
        uint id=unusedLandList[unusedLandList.length-1];
        unusedLandList.pop();
        removeSellingLand(id);
        // update land info
        landMap[id].isSellable=isSellable;
        landMap[id].owner=to;
        landMap[id].successor=address(0);
        // handle peopleOwnership
        peopleOwnership[to].push(id);
    }

    function distributeFromRich(address to, bool isSellable) internal {
        // find one of the richestPerson
        address richestPerson=address(0);
        uint maxLandNumber=0;
        for(uint i=0;i<peopleNumber;i++){
            if(peopleOwnershipKeys[i]==to) continue ;
            address person=peopleOwnershipKeys[i];
            uint landN=peopleOwnership[person].length;
            if(landN>maxLandNumber){
                richestPerson=person;
                maxLandNumber=landN;
            }
        }
        // get richestPerson's first sellable land
        require(maxLandNumber>1 && richestPerson!=address(0));
        uint distrIndex=0;
        uint id=0;
        for(uint i=0;i<maxLandNumber;i++){
            id=peopleOwnership[richestPerson][i];
            if(landMap[id].isSellable){
                distrIndex=i;
                break;
            }
        }
        // stop selling
        if(landMap[id].isSelling){
            removeSellingLand(id);
        }
        // update land info
        landMap[id].isSellable=isSellable;
        landMap[id].owner=to;
        landMap[id].successor=address(0);
        // handle peopleOwnership
        peopleOwnership[richestPerson][distrIndex] = peopleOwnership[richestPerson][maxLandNumber-1];
        peopleOwnership[richestPerson].pop();
        peopleOwnership[to].push(id);
    }

    // give the newborn three land
    function newborn(address neonatal) public
    onlyBirthManager(msg.sender)
    {
        require(!isValidPerson[neonatal],"people already exists");
        require(peopleNumber + 1 <= landNumber, "land is not enough to share");
        isValidPerson[neonatal]=true;
        peopleOwnershipKeys.push(neonatal);
        peopleNumber++;
        // use unused land first
        uint unLen=unusedLandList.length;
        if(unLen>3) unLen=3;
        for(uint i=0;i<unLen;i++){
            bool isSellable=true;
            if(i==0){
                isSellable=false;
            }
            distributeUnusedLand(neonatal, isSellable);
        }
        // use richest person's land if the unused land is not enough
        if(unLen<3){
            for(uint i=unLen;i<3;i++){
                bool isSellable=true;
                if(i==0){
                    isSellable=false;
                }
                distributeFromRich(neonatal, isSellable);
            }
        }
    }

    // fulfilling a will if someone is died
    function probate() public 
    onlyValidPerson(msg.sender)
    {
        uint landLen=peopleOwnership[msg.sender].length;
        for(uint i=0;i<landLen;i++){
            uint id=peopleOwnership[msg.sender][i];
            address successor=landMap[id].successor;

            landMap[id].isSellable=true;
            landMap[id].owner=successor;
            landMap[id].successor=address(0);

            if(successor==address(0)){
                if(!landMap[id].isSelling){
                    landSaleList.push(id);
                    landMap[id].isSelling=true;
                }
                landMap[id].price=10;
                unusedLandList.push(id);
            }else{
                // update land info
                if(landMap[id].isSelling){
                    removeSellingLand(id);
                }
                // give to successor
                peopleOwnership[successor].push(id);
            }

        }
        // delete peopleOwnershipKey
        uint keyIndex;
        for(keyIndex=0;keyIndex<peopleNumber;keyIndex++){
            if(peopleOwnershipKeys[keyIndex]==msg.sender){
                break;
            }
        }
        peopleOwnershipKeys[keyIndex]=peopleOwnershipKeys[peopleNumber-1];
        peopleOwnershipKeys.pop();
        delete peopleOwnership[msg.sender];

        isValidPerson[msg.sender]=false;
        peopleNumber--;
    }
}