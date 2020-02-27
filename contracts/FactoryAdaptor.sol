pragma solidity ^0.5.0;

import "./ERC20Adaptor.sol";
import "credit-contract/contracts/EER2B.sol";

contract FactoryAdaptor {
    uint256 private creditTypeID;
    address private creditAddr;

    mapping(uint256 => address) public adaptorRegistry;

    constructor(address _creditAddr, uint256 _creditTypeID) public {
        creditTypeID = _creditTypeID;
        creditAddr = _creditAddr;
    }

    function deployToERC20Adaptor() public returns (address) {
        ERC20Adaptor erc20Adaptor = new ERC20Adaptor(creditAddr, creditTypeID);
        adaptorRegistry[creditTypeID] = address(erc20Adaptor);
        return address(erc20Adaptor);
    }
}
