pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/ThrowProxy.sol";
import "credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract AdaptorFactory {
    address creditAccount;

    constructor(address _creditAccount) public {
        creditAccount = _creditAccount;
    }

    function newAdaptor(uint256 _typeID) external {
        new ERC20Adaptor(creditAccount, _typeID);
    }
}

contract TestDeployment {
    uint256 private fungibleCreditTypeID;
    uint256 private nonFungibleCreditTypeID;
    address private factoryAccount;

    ThrowProxy private creatorAccount = new ThrowProxy();

    function beforeAll() external {
        EER2B credit = new EER2B();
        fungibleCreditTypeID = credit.create("", false);
        nonFungibleCreditTypeID = credit.create("", true);

        AdaptorFactory factory = new AdaptorFactory(address(credit));
        factoryAccount = address(factory);
    }

    function testDeploySuccess() external {
        AdaptorFactory(address(creatorAccount)).newAdaptor(fungibleCreditTypeID);
        (bool success, ) = creatorAccount.execute(factoryAccount);
        Assert.isTrue(success, "should not throw error");
    }

    function testDeployError() external {
        AdaptorFactory(address(creatorAccount)).newAdaptor(nonFungibleCreditTypeID);
        (bool success, ) = creatorAccount.execute(factoryAccount);
        Assert.isFalse(success, "should throw error");
    }
}
