pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/AdaptorWrapper.sol";
import "./utils/ThrowProxy.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract TestApprove {
    ThrowProxy private ownerAccountProxy = new ThrowProxy();
    address private ownerAccount;
    address private operatorAccount = address(1);

    AdaptorWrapper private adaptor;
    address private adaptorAccount;

    function beforeAll() external {
        EER2B credit = new EER2B();
        address creditAccount = address(credit);
        uint256 typeID = credit.create("", false);

        adaptor = new AdaptorWrapper(creditAccount, typeID);
        adaptorAccount = address(adaptor);

        ownerAccount = address(ownerAccountProxy);
    }

    function testApprove() external{
        uint256 approvedAmount = 100;
        Assert.isZero(adaptor.allowance(ownerAccount, operatorAccount), "should not have allowances");

        AdaptorWrapper(ownerAccount).callApprove(operatorAccount, approvedAmount);
        (bool success, ) = ownerAccountProxy.execute(adaptorAccount);
        Assert.isTrue(success, "should not throw error approve credit to operator account");
        Assert.equal(adaptor.allowance(ownerAccount, operatorAccount), approvedAmount, "should equal to the approved amount");
    }
}
