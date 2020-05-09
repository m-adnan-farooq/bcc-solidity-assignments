pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

contract AdnanToken is IERC20{

    //Extending Uint256 with SafeMath Library.
    using SafeMath for uint256;
    using Address for address;
    
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;

    //the amount of tokens in existence
    uint256 private _totalSupply;
    
    //Capping for total tokens
    uint256 private _tokenCap;
    
    //owner
    address payable public owner;
    
    string public name;
    string public symbol;
    uint8 public decimals;

    //Exchange Value
    uint public aValue;

    constructor () public {
        name = "Adnan's Currency Token";
        symbol = "A-Coin";
        decimals = 18;
        owner = msg.sender;

        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        _tokenCap = _totalSupply + 50000 * (10 ** uint256(decimals));
        
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        
        //Setting exchange Value
        aValue = 4;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
     
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    
    // Setting exchange Value - A-Coin against wei i.e., 1wei equals to how many A-coins
    
    function adjustValue(uint _aValue) onlyOwner public{
        aValue = _aValue;
    }
    
    //buying tokens through transfer of Ether
    function tokenBuy() private {
        address recipient = msg.sender;
        
        //Checking whether the sender of ether (recipent of ERC20 taken) is an EOA
        require(recipient.isContract()==false,"Another Contract as a buyer not allowed");
        //transfering received ether to owner 
        owner.transfer(msg.value);
        uint256 tranferAmount = msg.value * aValue;
        transferForEther(recipient,tranferAmount);
        
    }
    //Token Capping
    function tokenCap() public view returns (uint256){
        return _tokenCap;
    }
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual  override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "A-Coin: transfer from the zero address");
        require(recipient != address(0), "A-Coin: transfer to the zero address");
        require(_balances[sender] > amount,"A-Coin: transfer amount exceeds balance");
        
        //decrease the balance of token sender account
        _balances[sender] = _balances[sender].sub(amount);
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) public view virtual  override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     * msg.sender: TokenOwner;
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override  returns (bool) {
        address tokenOwner = msg.sender;
        require(tokenOwner != address(0), "A-Coin: approve from the zero address");
        require(spender != address(0), "A-Coin: approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     * msg.sender: Spender
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender];
        require(_allowance > amount, "A-Coin: transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance.sub(amount);
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner].sub(amount); 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
     /**
     * This function will allow owner to Mint more tokens.
     * 
     * Requirements:
     * - the caller must have Owner of Contract
     * - amount should be valid incremental value.
     */
    function mint(uint256 amount) public onlyOwner returns(uint256){
        require(amount > 0,"A-Coin: Invalid Amount. Minted amount should be greater than 0");
        require(amount <= (_tokenCap - _totalSupply), "A-Coin: Invalid Amount. Minted amount is greated than amount allowed");
        _balances[owner] = _balances[owner].add(amount);
        _totalSupply = _totalSupply + amount;
        
    }
    
   
    modifier onlyOwner(){
        require(msg.sender == owner,"A-Coin owner can execute this feature");
        _;
    }
    
    //fallback function which will call tokenbuy() function when ether are transfered to the contract
    fallback() payable external{
        tokenBuy();
    }
    
    function transferForEther(address recipient, uint256 amount) private returns (bool) {
        address sender = owner;
        require(_balances[sender] > amount,"A-Coin: transfer amount exceeds balance");
        
        //decrease the balance of token from owner account
        _balances[sender] = _balances[sender].sub(amount);
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
       
}