pragma solidity ^0.5.0;

import "./../../contracts/FactoryAdaptor.sol";

contract FactoryAdaptorWrapper is FactoryAdaptor {
    constructor(address _creditAddr) public FactoryAdaptor(_creditAddr) {}

    function callDeployToERC20Adaptor(uint256 _creditTypeID) public {
        deployToERC20Adaptor(_creditTypeID);
    }
}
