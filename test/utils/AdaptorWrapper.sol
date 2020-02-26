pragma solidity ^0.5.0;

import "../../contracts/ERC20Adaptor.sol";
import "truffle/Assert.sol";


contract AdaptorWrapper is ERC20Adaptor {
    constructor(address _creditAddr, uint256 _typeID) public ERC20Adaptor(_creditAddr, _typeID) {}

    /**
    * @dev Cannot wrap transfer function since its modifier is external
    */
    function callTransfer(address recipient, uint256 amount) external {
        _transfer(msg.sender, recipient, amount);
    }

    /**
    * @dev Cannot wrap approve function since its modifier is external
    */
    function callApprove(address spender, uint256 amount) external {
        _approve(msg.sender, spender, amount);
    }

    function callTransferFrom(address sender, address recipient, uint256 amount) external {
        Assert.isTrue(transferFrom(sender, recipient, amount), "transfer failed");
    }
}
