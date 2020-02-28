pragma solidity ^0.5.0;

import "./ERC20Adaptor.sol";
import "credit-contract/contracts/EER2B.sol";

contract FactoryAdaptor {
    address private creditAddr;

    mapping(uint256 => address) public adaptorRegistry;

    constructor(address _creditAddr) public {
        creditAddr = _creditAddr;
    }

    /**
        @dev Factory contract deploys ERC20Adaptor contract 
        @param _creditTypeID The type id of credit 
        @return ERC20Adaptor's address
     */
    function deployToERC20Adaptor(uint256 _creditTypeID) public returns (address) {
        ERC20Adaptor erc20Adaptor = new ERC20Adaptor(creditAddr, _creditTypeID);
        adaptorRegistry[_creditTypeID] = address(erc20Adaptor);
        return address(erc20Adaptor);
    }
}
