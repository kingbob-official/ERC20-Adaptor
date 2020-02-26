pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/PayableThrowProxy.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract AdaptorWrapper is ERC20Adaptor {
    constructor(address _creditAddr, uint256 _typeID) public ERC20Adaptor(_creditAddr, _typeID){}
    function callApprove(address spender, uint256 amount) external {
        // @dev cannot wrap approve function since its modifier is external
        _approve(msg.sender, spender, amount);
    }
    function callTransferFrom(address sender, address recipient, uint256 amount) external {
        Assert.isTrue(transferFrom(sender, recipient, amount), "transfer failed");
    }
}

contract TestTransferFrom {
    PayableThrowProxy private operatorAccountProxy = new PayableThrowProxy();
    PayableThrowProxy private senderAccountProxy = new PayableThrowProxy();
    address private operatorAccount;
    address private senderAccount;
    address private recipientAccount = address(1);

    AdaptorWrapper private adaptor;
    address private adaptorAddress;

    function beforeAll() external {
        EER2B credit = new EER2B();
        address creditAddress = address(credit);
        uint256 typeID = credit.create("", false);

        adaptor = new AdaptorWrapper(creditAddress, typeID);
        adaptorAddress = address(adaptor);

        operatorAccount = address(operatorAccountProxy);
        senderAccount = address(senderAccountProxy);

        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = senderAccount;
        values[0] = 1000;
        credit.mintFungible(typeID, tos, values);

        EER2B(senderAccount).setApprovalForAll(adaptorAddress, true);
        (bool success, ) = senderAccountProxy.execute(creditAddress);
        Assert.isTrue(success, "should not throw error setting approval to the adaptor contract");
    }

    function testTransferFromSuccess() external{
        // approve fooAccount to operate over barAccount
        uint256 approvedAmount = 100;
        AdaptorWrapper(senderAccount).callApprove(operatorAccount, approvedAmount);
        (bool success, ) = senderAccountProxy.execute(adaptorAddress);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount, "should equal to the approved amount");

        uint256 transferredAmount = 30;
        uint256 senderBalance = adaptor.balanceOf(senderAccount);
        uint256 recipientBalance = adaptor.balanceOf(recipientAccount);
        Assert.isAtLeast(senderBalance, transferredAmount, "sender should have enough balance");
        Assert.isAtLeast(approvedAmount, transferredAmount, "should approved enough balance");

        AdaptorWrapper(operatorAccount).callTransferFrom(senderAccount, recipientAccount, transferredAmount);
        (success, ) = operatorAccountProxy.execute(adaptorAddress);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.balanceOf(senderAccount), senderBalance - transferredAmount, "sender balance should decreased by the transferred amount");
        Assert.equal(adaptor.balanceOf(recipientAccount), recipientBalance + transferredAmount, "recipient balance should increased by the transferred amount");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount - transferredAmount, "approved amount should decrease by the transferred amount");
    }

    function testErrorInsufficientApprovedAmount() external{
        // approve fooAccount to operate over barAccount
        uint256 approvedAmount = 10;
        AdaptorWrapper(senderAccount).callApprove(operatorAccount, approvedAmount);
        (bool success, ) = senderAccountProxy.execute(adaptorAddress);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.allowance(senderAccount, operatorAccount), approvedAmount, "should equal to the approved amount");

        uint256 transferredAmount = 30;
        uint256 senderBalance = adaptor.balanceOf(senderAccount);
        Assert.isAtLeast(senderBalance, transferredAmount, "sender should have enough balance");
        Assert.isBelow(approvedAmount, transferredAmount, "should approved insufficient balance");

        AdaptorWrapper(operatorAccount).callTransferFrom(senderAccount, recipientAccount, transferredAmount);
        (success, ) = operatorAccountProxy.execute(adaptorAddress);
        Assert.isFalse(success, "should throw error transferring credit to account");
    }
}
