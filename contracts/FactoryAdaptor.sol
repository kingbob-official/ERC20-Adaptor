pragma solidity ^0.5.0;

import './ERC20Adaptor.sol';
import '@credit-contract/contracts/EER2B.sol';

contract FactoryAdaptor {
    uint256 public creditTypeID;
    address public creditAddr;

    mapping(uint256 => address) public adaptorRegistry;
    event Log(address x);
    constructor(address _creditAddr, uint256 _creditTypeID) public {
        emit Log(address(3));
        creditTypeID = _creditTypeID;
        creditAddr = _creditAddr;
    }

    function DeployToERC20Adaptor() external returns (address) {
        emit Log(address(1));
        ERC20Adaptor erc20Adaptor = new ERC20Adaptor(creditAddr, creditTypeID);
        emit Log(address(0));
        adaptorRegistry[creditTypeID] = address(erc20Adaptor);
        emit Log(address(erc20Adaptor));
        return address(erc20Adaptor);
    }

    function AA() external returns (string memory) {
        emit Log(address(4));
        return 'heelo';
    }
}
