pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/PayableThrowProxy.sol";
import "./utils/ThrowProxy.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract AdaptorWrapper is ERC20Adaptor {
    constructor(address _creditAddr, uint256 _typeID) public ERC20Adaptor(_creditAddr, _typeID){}
    function callTransfer(address recipient, uint256 amount) external {
        // @dev cannot wrap transfer function since its modifier is external
        _transfer(msg.sender, recipient, amount);
    }
}

contract TestTransfer {
    PayableThrowProxy private throwProxy = new PayableThrowProxy();
    address private fooAddress;
    address private barAddress = address(1);

    AdaptorWrapper private adaptor;
    address private adaptorAddress;

    function beforeAll() external {
        EER2B credit = new EER2B();
        address creditAddress = address(credit);
        uint256 typeID = credit.create("", false);

        adaptor = new AdaptorWrapper(creditAddress, typeID);
        adaptorAddress = address(adaptor);

        fooAddress = address(throwProxy);

        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = fooAddress;
        values[0] = 1000;
        credit.mintFungible(typeID, tos, values);

        EER2B(fooAddress).setApprovalForAll(adaptorAddress, true);
        (bool success, ) = throwProxy.execute(creditAddress);
        Assert.isTrue(success, "should not throw error setting approval to the adaptor contract");
    }

    function testTransfer() external{
        uint256 fooBalance = adaptor.balanceOf(fooAddress);
        uint256 barBalance = adaptor.balanceOf(barAddress);
        uint256 transferredAmount = 20;
        Assert.isAtLeast(fooBalance, transferredAmount, "should have enough balance");

        AdaptorWrapper(fooAddress).callTransfer(barAddress, transferredAmount);
        (bool success, ) = throwProxy.execute(adaptorAddress);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.balanceOf(fooAddress), fooBalance - transferredAmount, "foo balance should decreased by the transferred amount");
        Assert.equal(adaptor.balanceOf(barAddress), barBalance + transferredAmount, "bar balance should increased by the transferred amount");
    }
}
