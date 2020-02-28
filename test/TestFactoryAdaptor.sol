pragma solidity ^0.5.0;

import "./../contracts/FactoryAdaptor.sol";
import "./utils/FactoryAdaptorWrapper.sol";
import "./utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "credit-contract/contracts/EER2B.sol";

contract TestFactoryAdaptor {
    uint256 private fungibleCreditTypeID;
    uint256 private nonFungibleCreditTypeID;
    address private creditAddr;

    ThrowProxy private creatorAccount = new ThrowProxy();

    function beforeAll() external {
        EER2B credit = new EER2B();
        fungibleCreditTypeID = credit.create("", false);
        nonFungibleCreditTypeID = credit.create("", true);

        creditAddr = address(credit);
    }

    function testDeploySuccess() external {
        FactoryAdaptor factoryAdaptor = new FactoryAdaptor(creditAddr);
        address factoryAdaptorAddr = factoryAdaptor.deployToERC20Adaptor(fungibleCreditTypeID);
        Assert.equal(
            factoryAdaptorAddr,
            factoryAdaptor.adaptorRegistry(fungibleCreditTypeID),
            "factory adaptor address should be equal to address which mapping by credit type id"
        );
    }

    function testDeployError() external {
        FactoryAdaptor factoryAdaptor = new FactoryAdaptorWrapper(creditAddr);
        FactoryAdaptorWrapper(address(creatorAccount)).callDeployToERC20Adaptor(
            nonFungibleCreditTypeID
        );
        (bool success, ) = creatorAccount.execute(address(factoryAdaptor));
        Assert.isFalse(success, "should throw error");
    }
}
