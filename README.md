

### <center>Unregulated Cross-Border Land Sale and Distribution System<center/>


#### Problem statement:

Disadvantages of existing land sales:

1. Land is typically bounded by national boundaries nowadays, and many countries prohibit cross-border land sales.
2. War is usually a feasible way for different interest groups to plunder each other's land. Many people lose their land during war.
3. As the gap between the rich and the poor widens in a society, the rich usually own more land while the poor work hard all their lives to buy land.
4. Landowners would speculate on property and make the price of land fluctuate dramatically.

Blockchain based solution:

1. Land is sold on the blockchain and is not controlled by the regime or the state.
2. Land ownership guaranteed by the blockchain is protected from the elements of war.
3. Every newborn child should be given his/her own land. If the amount of land available is not enough, it will be acquired for free on one of the people who owns the largest amount of land. This is to weaken the gap between the rich and the poor.
4. Every newborn child owns 3 pieces of land, one of which cannot be sold and the other two can be sold, this is to ensure that everyone has a place to live and the right to trade freely. Furthermore, because everyone owns land, speculation will be limited.

#### Example scenario:

When deploying a contract, you need to specify how much land there is and how many people are currently on the land. Initially, the lands are all owned by the contract each land is worth 1 Ether and each person will be assigned 3 units of land. Everyone can sell and buy land as well as view different land prices. Each land corresponding to the owner can be checked. When someone dies, his land will be inherited by a designated heir. When there is a newborn child, he will be given 3 pieces of land. If there is no vacant land, he will receive 3 pieces of land from the person who owns the most amount of land.

#### Functions:
```solidity
// sale your land
function saleLand(uint256 id, uint256 price) public;

// buy land
function buyLand(uint256 id) public payable;

// stop selling your land
function stopSelling(uint256 id) public;

// check the land owner if 0 then not owner now
function getLandOwner(uint256 id) view public returns (address owner);

// get your land list
function getMyLandList()  view public returns (uint256[] memory ids, string[] memory tradableStatus, string[] memory isSelling, uint256[] memory prices, address[] memory successors);

// get the list of sale land
function getLandSaleList() view public returns (uint256[] memory ids, uint256[] memory prices);

// assign the inheritance of your land
function assignInheritance(uint id, address to) public;

// give the newborn three land
function newborn(address neonatal) public;

// fulfilling a will if someone is died
function probate() public;
```

#### Unit Test

The unit tests are placed in the `./source_code/tests`.

#### Vulnerabilities Verification

Slither result:
![image-1](https://github.com/Zhuohua-HUANG/LandManagementContract/assets/71301342/f22f8788-4be1-4feb-9a40-ab6b15adf6cc)

#### Deploy and Verified with Etherscan

Etherscan URL:
<https://sepolia.etherscan.io/address/0xd64a9cb85c49093a5913de44e9515a10ada0ce87#code>

The Contract Address is: 0xd64a9cb85c49093a5913DE44e9515A10AdA0ce87
