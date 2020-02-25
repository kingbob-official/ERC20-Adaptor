pragma solidity ^0.5.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@credit-contract/contracts/EER2B.sol';


contract ERC20Adaptor is IERC20 {
    // library was imported in EER-2 contract
    using SafeMath for uint256;
    EER2B private credit;
    uint256 typeID;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(address _creditAddr, uint256 _typeID) public {
        credit = EER2B(_creditAddr);
        require(credit.isFungible(_typeID), 'ERC20Adaptor: the credit is not fungible credit type');
        typeID = _typeID;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return credit.totalSupply(typeID);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return credit.balanceOf(account, typeID);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * See EER2A for the requirements
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - see {EER2A-safeTransferFrom}.
     * - the caller must have allowance for `sender`'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements: see {EER2A-safeTransferFrom}
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        credit.safeTransferFrom(_from, _to, typeID, _value, '0x0');
        emit Transfer(_from, _to, _value);
    }
}
