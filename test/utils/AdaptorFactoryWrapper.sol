pragma solidity ^0.5.0;

import "./../../contracts/ERC20AdaptorFactory.sol";
import "truffle/Assert.sol";


contract AdaptorFactoryWrapper is ERC20AdaptorFactory {
    constructor(address _creditAddr) public ERC20AdaptorFactory(_creditAddr) {}

    function callDeployAdaptor(uint256 _creditTypeID) public {
        Assert.isNotZero(deployAdaptor(_creditTypeID), "should not return zero address");
    }
}
