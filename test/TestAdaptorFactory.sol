pragma solidity ^0.5.0;

import "./../contracts/ERC20AdaptorFactory.sol";
import "./utils/AdaptorFactoryWrapper.sol";
import "./utils/ThrowProxy.sol";
import "truffle/Assert.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";

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
        adaptorFactory = new AdaptorFactoryWrapper(creditAddr);
    }

    function testDeploySuccess() external {
        AdaptorFactoryWrapper(address(creatorAccount)).callDeployAdaptor(fungibleCreditTypeID);
        (bool success, ) = creatorAccount.execute(address(adaptorFactory));
        Assert.isTrue(success, "should not throw error");
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
        AdaptorFactoryWrapper(address(creatorAccount)).callDeployAdaptor(nonFungibleCreditTypeID);
        (bool success, ) = creatorAccount.execute(address(adaptorFactory));
        Assert.isFalse(success, "should throw error");
    }
}
