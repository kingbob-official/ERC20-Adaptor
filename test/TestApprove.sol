pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "./utils/ThrowProxy.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract AdaptorWrapper is ERC20Adaptor {
    constructor(address _creditAddr, uint256 _typeID) public ERC20Adaptor(_creditAddr, _typeID){}
    function callApprove(address spender, uint256 amount) external {
        // @dev cannot wrap approve function since its modifier is external
        _approve(msg.sender, spender, amount);
    }
}

contract TestApprove {
    ThrowProxy private throwProxy = new ThrowProxy();
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
    }

    function testApprove() external{
        uint256 approvedAmount = 100;
        Assert.isZero(adaptor.allowance(fooAddress, barAddress), "should not have allowances");

        AdaptorWrapper(fooAddress).callApprove(barAddress, approvedAmount);
        (bool success, ) = throwProxy.execute(adaptorAddress);
        Assert.isTrue(success, "should not throw error transferring credit to account");
        Assert.equal(adaptor.allowance(fooAddress, barAddress), approvedAmount, "should equal to the approved amount");
    }
}
