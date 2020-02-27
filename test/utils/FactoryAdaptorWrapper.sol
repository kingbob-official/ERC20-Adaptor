pragma solidity ^0.5.0;

import "./../../contracts/FactoryAdaptor.sol";

contract FactoryAdaptorWrapper is FactoryAdaptor {
    constructor(address _creditAddr, uint256 _creditTypeID)
        public
        FactoryAdaptor(_creditAddr, _creditTypeID)
    {}

    function callDeployToERC20Adaptor() public {
        deployToERC20Adaptor();
    }
}
