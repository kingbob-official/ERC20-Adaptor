pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/AdaptorWrapper.sol";
import "./utils/PayableThrowProxy.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract TestTransferFrom {
    PayableThrowProxy private operatorAccountProxy = new PayableThrowProxy();
    PayableThrowProxy private senderAccountProxy = new PayableThrowProxy();
    address private operatorAccount;
    address private senderAccount;
    address private recipientAccount = address(1);

    AdaptorWrapper private adaptor;
    address private adaptorAccount;

    function beforeAll() external {
        EER2B credit = new EER2B();
        address creditAccount = address(credit);
        uint256 typeID = credit.create("", false);

        adaptor = new AdaptorWrapper(creditAccount, typeID);
        adaptorAccount = address(adaptor);

        operatorAccount = address(operatorAccountProxy);
        senderAccount = address(senderAccountProxy);

        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = senderAccount;
        values[0] = 1000;
        credit.mintFungible(typeID, tos, values);

        EER2B(senderAccount).setApprovalForAll(adaptorAccount, true);
        (bool success, ) = senderAccountProxy.execute(creditAccount);
        Assert.isTrue(success, "should not throw error setting approval to the adaptor contract");
    }

    function testTransferFromSuccess() external{
        // approve fooAccount to operate over barAccount
        uint256 approvedAmount = 100;
        AdaptorWrapper(senderAccount).callApprove(operatorAccount, approvedAmount);
        (bool success, ) = senderAccountProxy.execute(adaptorAccount);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount, "should equal to the approved amount");

        uint256 transferredAmount = 30;
        uint256 senderBalance = adaptor.balanceOf(senderAccount);
        uint256 recipientBalance = adaptor.balanceOf(recipientAccount);
        Assert.isAtLeast(senderBalance, transferredAmount, "sender should have enough balance");
        Assert.isAtLeast(approvedAmount, transferredAmount, "should approved enough balance");

        AdaptorWrapper(operatorAccount).callTransferFrom(senderAccount, recipientAccount, transferredAmount);
        (success, ) = operatorAccountProxy.execute(adaptorAccount);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.balanceOf(senderAccount), senderBalance - transferredAmount, "sender balance should decreased by the transferred amount");
        Assert.equal(adaptor.balanceOf(recipientAccount), recipientBalance + transferredAmount, "recipient balance should increased by the transferred amount");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount - transferredAmount, "approved amount should decrease by the transferred amount");
    }

    function testErrorInsufficientApprovedAmount() external{
        // approve fooAccount to operate over barAccount
        uint256 approvedAmount = 10;
        AdaptorWrapper(senderAccount).callApprove(operatorAccount, approvedAmount);
        (bool success, ) = senderAccountProxy.execute(adaptorAccount);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount, "should equal to the approved amount");

        uint256 transferredAmount = 30;
        uint256 senderBalance = adaptor.balanceOf(senderAccount);
        Assert.isAtLeast(senderBalance, transferredAmount, "sender should have enough balance");
        Assert.isBelow(approvedAmount, transferredAmount, "should approved insufficient balance");

        AdaptorWrapper(operatorAccount).callTransferFrom(senderAccount, recipientAccount, transferredAmount);
        (success, ) = operatorAccountProxy.execute(adaptorAccount);
        Assert.isFalse(success, "should throw error transferring credit to account");
    }
}
