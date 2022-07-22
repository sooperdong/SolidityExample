pragma solidity ^0.5.0;

contract Token {
    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public totalSupply;

    //contractManager가 mint, burn을 실행할 수 있도록 변경
    address payable public contractManager;

    mapping (address => uint256) _balances;
    
    //       holder             spender     value
    mapping (address => mapping(address => uint256)) _allowed;

    mapping ( address => bool ) public _isFreeze;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    constructor() public {
        name = "DAON01";
        symbol = "DAON";
        decimals = 18;
        totalSupply = 10000* 10**18;

        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        contractManager = msg.sender;
    }
    
    
    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }
    
    // transfer 공통함수 internal로 선언
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success){
        // [차단조건1] 잔액보다 많은 금액을 보낼 경우
        require(_balances[_from] >= _value);

        // [차단조건2] 표현할수 있는 값(uint)보다 더 큰 잔액이 되었을 경우
        require(_balances[_to] + _value >= _balances[_to]);

        require( _isFreeze[_from] == false );

        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender,_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // MSG.SENDER에게 위임을 받았는지 확인필요
        // 위임 받은 수량이 얼마인지 확인 (전송하려는 금액이, 위암받은 금액보다 적어야함)
        require(_allowed[_from][msg.sender] >= _value);
        _allowed[_from][msg.sender] -= _value;
        _transfer(_from,_to,_value);
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // 위임
        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256){
        return _allowed[_owner][_spender];
    }

    function destruct() public returns(bool){
        selfdestruct(msg.sender);
    }

    function mint(address _to, uint256 _value) public returns (bool){
        // contractManager만 실행 가능하도록 조건추가
        require(msg.sender == contractManager);

        // [차단조건] 표현할수 있는 값(uint)보다 더 큰 잔액이 되었을 경우
        require(_balances[_to] + _value >= _balances[_to]);

        _balances[_to] += _value;
        totalSupply += _value;
        emit Transfer(address(0), _to, _value);

        return true;
    }

    function _mint( address _to, uint256 _value) internal returns(bool){
        require( _balances[_to] + _value >= _balances[_to]);

        _balances[_to] += _value;
        totalSupply += _value;
        emit Transfer( address(0), _to, _value);
        return true;        
    }
    
    function burn(address _from, uint256 _value) public returns (bool){
        // contractManager만 실행 가능하도록 조건추가
        require(msg.sender == contractManager);
        
        // [차단조건] 잔액보다 많은 금액을 소각 경우
        require(_balances[_from]  >= _value);
        
        _balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer(_from, address(0), _value);

        return true;
    }

    function freeze( address _target ) public returns(bool){
        require( msg.sender == contractManager);
        _isFreeze[_target] = true;
        return true;
    }

    function unFreeze( address _target ) public returns(bool){
        require( msg.sender == contractManager);
        _isFreeze[_target] = false;
        return true;
    }

    function () external payable {
        uint256 eth = msg.value;
        uint256 token = eth * 100;
        _mint(msg.sender, token);

        contractManager.transfer(eth);
    }


}
