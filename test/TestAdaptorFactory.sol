pragma solidity ^0.5.0;

import "./../contracts/ERC20AdaptorFactory.sol";
import "./utils/AdaptorFactoryWrapper.sol";
import "./utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";

contract TestAdaptorFactory {
    uint256 private fungibleCreditTypeID;
    uint256 private nonFungibleCreditTypeID;
    address private creditAddr;

    ThrowProxy private creatorAccount = new ThrowProxy();
    ERC20AdaptorFactory private adaptorFactory;

    function beforeAll() external {
        EER2B credit = new EER2B();
        fungibleCreditTypeID = credit.create("", false);
        nonFungibleCreditTypeID = credit.create("", true);

        creditAddr = address(credit);
        adaptorFactory = new ERC20AdaptorFactory(creditAddr);
    }

    function testDeploySuccess() external {
        address adaptorAddr = adaptorFactory.deployAdaptor(fungibleCreditTypeID);
        Assert.equal(
            adaptorAddr,
            adaptorFactory.adaptorRegistry(fungibleCreditTypeID),
            "adaptor factory address should be equal to address which mapping by credit type id"
        );
    }

    function testDeploySameTheFungibleCreditTypeIDTwiceTimes() external {
        address fooFactoryAddr = adaptorFactory.deployAdaptor(fungibleCreditTypeID);
        address barFactoryAddr = adaptorFactory.deployAdaptor(fungibleCreditTypeID);
        Assert.equal(
            fooFactoryAddr,
            barFactoryAddr,
            "foo adaptor factory address should be equal to bar adaptor factory address"
        );
    }

    function testDeployErrorWithNonFungibleCreditType() external {
        adaptorFactory = new AdaptorFactoryWrapper(creditAddr);
        AdaptorFactoryWrapper(address(creatorAccount)).callDeployAdaptor(nonFungibleCreditTypeID);
        (bool success, ) = creatorAccount.execute(address(adaptorFactory));
        Assert.isFalse(success, "should throw error");
    }
}
