//Token with restriction on transfer to two specific addresses
//with similar interval for every transaction (first as well as subsequent transactions)

pragma solidity ^0.6.0;
//0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on Uint256
contract AdnanToken is IERC20{
    //Extending Uint256 with SafeMath Library.
    using SafeMath for uint256;
    
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;

    //the amount of tokens in existence
    uint256 private _totalSupply;
    
    //Capping for total tokens
    uint256 private _tokenCap;
    
    //Time of contract
    uint256 private today;
    
    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    
    address[] restrict_transfer;
   

    constructor () public {
        name = "Adnan's Currency Token";
        symbol = "A-Coin";
        decimals = 2;
        owner = msg.sender;

        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        _tokenCap = _totalSupply + 50000 * (10 ** uint256(decimals));
        
        today = block.timestamp;
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //restrict transfer
        restrict_transfer = [0xDc9C3A21F6332274c4aE42e0F9f6513cBeDFDDA2,0xf2fBe2701a23d5Bad57aE8BB344b2F2160D16B81];
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
     
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
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
        
        //checking condition if the transfer to a address is restricted or not
        if(recipient == restrict_transfer[0] || recipient == restrict_transfer[1]){
            require(block.timestamp >= today + 2 days,"A-Coin: transfer before lapse of 2days is not allowed");
            if (true){
                today = block.timestamp;
            }
        }
            
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
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public  virtual override returns (bool) {
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
}