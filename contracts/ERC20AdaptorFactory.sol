pragma solidity ^0.5.0;

import "./ERC20Adaptor.sol";
import "@Evrynetlabs/credit-contract/contracts/EER2B.sol";

contract ERC20AdaptorFactory {
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
    function deployAdaptor(uint256 _creditTypeID) public returns (address) {
        require(
            adaptorRegistry[_creditTypeID] == address(0),
            "ERC20AdaptorFactory: cannot deploy the credit type id that has already deployed contract"
        );
        ERC20Adaptor erc20Adaptor = new ERC20Adaptor(creditAddr, _creditTypeID);
        adaptorRegistry[_creditTypeID] = address(erc20Adaptor);
        return address(erc20Adaptor);
    }
}
