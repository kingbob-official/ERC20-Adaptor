pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/AdaptorWrapper.sol";
import "./utils/PayableThrowProxy.sol";
import "@evrynetlabs/credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";


contract TestTransfer {
    PayableThrowProxy private senderAccountProxy = new PayableThrowProxy();
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

    function testTransfer() external {
        uint256 fooBalance = adaptor.balanceOf(senderAccount);
        uint256 barBalance = adaptor.balanceOf(recipientAccount);
        uint256 transferredAmount = 20;
        Assert.isAtLeast(fooBalance, transferredAmount, "should have enough balance");

        AdaptorWrapper(senderAccount).callTransfer(recipientAccount, transferredAmount);
        (bool success, ) = senderAccountProxy.execute(adaptorAccount);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(
            adaptor.balanceOf(senderAccount),
            fooBalance - transferredAmount,
            "foo balance should decreased by the transferred amount"
        );
        Assert.equal(
            adaptor.balanceOf(recipientAccount),
            barBalance + transferredAmount,
            "bar balance should increased by the transferred amount"
        );
    }
}
