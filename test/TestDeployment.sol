pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/ThrowProxy.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract AdaptorFactory {
    address creditAddr;

    constructor (address _creditAddr) public {
        creditAddr = _creditAddr;
    }

    function newAdaptor(uint256 _typeID) external{
        new ERC20Adaptor(creditAddr, _typeID);
    }
}

contract TestDeployment {
    uint256 private fungibleCreditTypeID;
    uint256 private nonFungibleCreditTypeID;

    ThrowProxy private factoryProxy;

    function beforeAll() external {
        EER2B credit = new EER2B();
        fungibleCreditTypeID = credit.create("", false);
        nonFungibleCreditTypeID = credit.create("", true);

        AdaptorFactory factory = new AdaptorFactory(address(credit));
        factoryProxy = new ThrowProxy(address(factory));
    }

    function testDeploySuccess() external{
        AdaptorFactory(address(factoryProxy)).newAdaptor(fungibleCreditTypeID);
        (bool success, ) = factoryProxy.execute();
        Assert.isTrue(success, "should not throw error");
    }

    function testDeployError() external{
        AdaptorFactory(address(factoryProxy)).newAdaptor(nonFungibleCreditTypeID);
        (bool success, ) = factoryProxy.execute();
        Assert.isFalse(success, "should throw error");
    }
}
