pragma solidity ^0.5.0;

import "./../../contracts/ERC20AdaptorFactory.sol";

contract FactoryAdaptorWrapper is ERC20AdaptorFactory {
    constructor(address _creditAddr) public ERC20AdaptorFactory(_creditAddr) {}

    function callDeployAdaptor(uint256 _creditTypeID) public {
        deployAdaptor(_creditTypeID);
    }
}
