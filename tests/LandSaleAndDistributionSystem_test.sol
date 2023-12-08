// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../LandSaleAndDistributionSystem.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testLandSaleAndDistributionSystem is LandSaleAndDistributionSystem{
    //000000000000000000
    address[] testPeopleList=[
        TestsAccounts.getAccount(1), 
        TestsAccounts.getAccount(2), 
        TestsAccounts.getAccount(3), 
        TestsAccounts.getAccount(4), 
        TestsAccounts.getAccount(5)
    ];

    address testBirthManager= TestsAccounts.getAccount(0);

    address testNeonatal = TestsAccounts.getAccount(6);
    address testNeonatal2 = TestsAccounts.getAccount(7);
    address testNeonatal3 = TestsAccounts.getAccount(8);
    address testNeonatal4 = TestsAccounts.getAccount(9);



    uint256[] testIds1=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,28,27];
    uint256[] testPrices1=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,5];

    uint256[] testIds2=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,27];
    uint256[] testPrices2=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5];

    uint256[] testIds3=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
    uint256[] testPrices3=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

    uint256[] testIds4=[1,0,27];

    event Log(uint land);

    constructor() LandSaleAndDistributionSystem(30) {}

    function beforeAll() public {
        uint len=testPeopleList.length;
        for(uint i=0;i<len;i++){
            newborn(testPeopleList[i]);
        }
    }

    function checkUintArray(uint[] memory a, uint[] memory b, uint start) private pure returns (bool) {
        if(a.length!=b.length) return false;
        for(uint i=start;i<a.length;i++){
            if(a[i]!= b[i]){
                return false;
            }
        }
        return true;
    }

    /// #sender: account-1
    function saleLandTest() public {
        saleLand(28, 7);
        saleLand(27, 5);
        (uint256[] memory ids, uint256[] memory prices) = getLandSaleList();
        bool ok=checkUintArray(testIds1, ids, 0);
        Assert.ok(ok,"saleLand Error");

        ok=checkUintArray(testPrices1, prices, 0);
        Assert.ok(ok,"saleLand Error");
    }

    /// #sender: account-2
    /// #value: 10000000000000000000
    function buyLandTest() payable public {
        Assert.equal(msg.value, 10000000000000000000, "not good money");
        buyLand(28);
        (uint256[] memory ids, uint256[] memory prices) = getLandSaleList();
        bool ok=checkUintArray(testIds2, ids, 0);
        Assert.ok(ok,"buyLand Error");

        ok=checkUintArray(testPrices2, prices, 0);
        Assert.ok(ok,"buyLand Error");

        (uint256[] memory ids2, string[] memory tradableStatus2, string[] memory isSelling2, uint256[] memory prices2, address[] memory successors2)=getMyLandList();
        Assert.equal(ids2[3], 28, "buyLand Error");
        Assert.equal(tradableStatus2[3], "true", "buyLand Error");
        Assert.equal(isSelling2[3], "false", "buyLand Error");
        Assert.equal(prices2[3], 7, "buyLand Error");
        Assert.equal(successors2[3], address(0), "buyLand Error");
    }

    /// #sender: account-1
    function stopSellingTest() public {
        stopSelling(27);
        (uint256[] memory ids, uint256[] memory prices) = getLandSaleList();
        bool ok=checkUintArray(testIds3, ids, 0);
        Assert.ok(ok,"stopSelling Error");

        ok=checkUintArray(testPrices3, prices, 0);
        Assert.ok(ok,"stopSelling Error");
    }

    function getLandOwnerTest() public {
        address owner1=getLandOwner(28);
        Assert.equal(owner1, testPeopleList[1] ,"getLandOwner Error");
    }

    /// #sender: account-2
    function getMyLandListTest() public {
        (uint256[] memory ids2, string[] memory tradableStatus2, string[] memory isSelling2, uint256[] memory prices2, address[] memory successors2)=getMyLandList();
        Assert.equal(ids2[3], 28, "getMyLandList Error");
        Assert.equal(tradableStatus2[3], "true", "getMyLandList Error");
        Assert.equal(isSelling2[3], "false", "getMyLandList Error");
        Assert.equal(prices2[3], 7, "getMyLandList Error");
        Assert.equal(successors2[3], address(0), "getMyLandList Error");
        Assert.equal(ids2[0], 26, "getMyLandList Error");
        Assert.equal(tradableStatus2[0], "false", "getMyLandList Error");
        Assert.equal(isSelling2[0], "false", "getMyLandList Error");
        Assert.equal(prices2[0], 1, "getMyLandList Error");
        Assert.equal(successors2[0], address(0), "getMyLandList Error");
    }

    function getLandSaleListTest() public {
        (uint256[] memory ids, uint256[] memory prices) = getLandSaleList();
        bool ok=checkUintArray(testIds3, ids, 0);
        Assert.ok(ok,"stopSelling Error");
        ok=checkUintArray(testPrices3, prices, 0);
        Assert.ok(ok,"stopSelling Error");
    }

    /// #sender: account-2
    function assignInheritanceTest() public{
        assignInheritance(26, testPeopleList[0]);
        assignInheritance(25, testPeopleList[2]);
        (, , , , address[] memory successors)=getMyLandList();
        Assert.equal(successors[0], testPeopleList[0], "getMyLandList Error");
        Assert.equal(successors[1], testPeopleList[2], "getMyLandList Error");
    }

    // make the account 1 become richest person

    /// #sender: account-1
    /// #value: 1000000000000000000
    function buyLandBeforeNewbornTest1() payable public {
        buyLand(14);
    }
    /// #sender: account-1
    /// #value: 1000000000000000000
    function buyLandBeforeNewbornTest2() payable public {
        buyLand(13);
    }

    /// #sender: account-1
    /// #value: 1000000000000000000
    function buyLandBeforeNewbornTest3() payable public {
        buyLand(12);
    }

    /// #sender: account-1
    /// #value: 1000000000000000000
    function buyLandBeforeNewbornTest4() payable public {
        buyLand(11);
    }


    function newbornTest() public {
        newborn(testNeonatal);
        newborn(testNeonatal2);
        newborn(testNeonatal3);
        newborn(testNeonatal4);
        for(uint i=0;i<3;i++){
            address owner=getLandOwner(testIds4[i]);
            Assert.equal(owner, testNeonatal4, "newborn Error");
        }
    }

    /// #sender: account-2 
    function probateTest() public {
        probate();
        address successor1=getLandOwner(26);
        Assert.equal(successor1, testPeopleList[0], "newborn Error");
        address successor2=getLandOwner(25);
        Assert.equal(successor2, testPeopleList[2], "newborn Error");
    }
}
    