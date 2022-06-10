pragma solidity ^0.4.24;

//--------------------------------------------------------------
//'Miller Time' token contract

//Deployed to : 0x63A30a72cb60D588A16Bf97a581bc1aE8cE47FfF
//Symbol      : MTT
//Name        : Miller Time Token
//Total Supply: 1000000000000
//decimals    : 0
//--------------------------------------------------------------



//--------------------------------------------------------------
//Safe Maths
//--------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c){
        c = a + b;
        require(c>=a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c){
        require(b<=a);
        c = a - b;
    }
        
    function safeMul(uint a, uint b) public pure returns (uint c){
        c = a * b;
        require(a==0 || c/a==b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c){
        require(b>0);
        c = a / b;
    }
}


//--------------------------------------------------------------
//ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
//--------------------------------------------------------------
contract ERC20Interface {

    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens)public returns (bool success);
    function approve(address spender, uint tokens)public returns (bool success);
    function transferFrom(address from, address to, uint tokens)public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


//--------------------------------------------------------------
//Contract function to recieve approval and execute function
//--------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


//--------------------------------------------------------------
//ERC20 Token and assisted token Transfers
//--------------------------------------------------------------
contract MTT is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    //--------------------------------------------------------------
    //Constructor
    //--------------------------------------------------------------
    constructor() public {
        symbol = "MTT";
        name = "Miller Time Token";
        decimals = 0;
        _totalSupply = 1000000000000;
        balances[0x63A30a72cb60D588A16Bf97a581bc1aE8cE47FfF] =_totalSupply;
        emit Transfer(address(0),0x63A30a72cb60D588A16Bf97a581bc1aE8cE47FfF , _totalSupply);
    }


    //--------------------------------------------------------------
    //Total supply
    //--------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }


    //--------------------------------------------------------------
    //Get the token balance of the tokenOwner account
    //--------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    //--------------------------------------------------------------
    //Transfer tokens from owner's account to the (to) account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    //--------------------------------------------------------------
    function transfer(address to, uint tokens) public returns(bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to],tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    //--------------------------------------------------------------
    //Token owner can Approve spender to transfer tokens (transferFrom) from the owners's account
    //--------------------------------------------------------------
    function approve(address spender, uint tokens) public returns(bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    //--------------------------------------------------------------
    //Transfer tokens form the (from) account to the (to) account
    //
    //The calling account must already have sufficient tokens (approve)
    //for spending from the (from) account and
    // - The from account must have sufficient balance to transfer
    // - The spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    //--------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer (from, to, tokens);
        return true;
    }


    //--------------------------------------------------------------
    //Returns the amount of tokens (approved by the owner) 
    //that can be transferred to the spender's account
    //--------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    //--------------------------------------------------------------
    //Token owner can approve spender to transfer tokens (transferFrom) from token owner's account
    //The spender contract is then executed (receiveApproval)
    //--------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    //--------------------------------------------------------------
    //Don't accept ETH
    function() public payable {
        revert();
    }


    //--------------------------------------------------------------
    //Owner can transfer accidentally sent ERC20 tokens out
    //--------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}