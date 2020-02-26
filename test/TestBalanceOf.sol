pragma solidity ^0.5.0;

import "./../contracts/ERC20Adaptor.sol";
import "@credit-contract/contracts/EER2B.sol";
import "truffle/Assert.sol";

contract TestBalanceOf {
    EER2B private credit;
    uint256 private typeID;
    ERC20Adaptor private adaptor;

    function beforeAll() external {
        credit = new EER2B();
        typeID = credit.create("", false);

        adaptor = new ERC20Adaptor(address(credit), typeID);
    }

    function testBalanceOf() external{
        uint256 expectedAmount = 1000;
        address fooAccount = address(1);
        address[] memory tos = new address[](1);
        uint256[] memory values = new uint256[](1);
        tos[0] = fooAccount;
        values[0] = expectedAmount;

        Assert.equal(adaptor.balanceOf(fooAccount),      0,        "account balance should be zero");

        credit.mintFungible(typeID, tos, values);
        Assert.equal(adaptor.balanceOf(fooAccount), expectedAmount, "account balance should be increased equal to the minted amount");
    }
}
