// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./ERC20_complate.sol";

contract SimpleDefi{

    address public contractManager;
    mapping( string => IERC20) public tokens;
    mapping( string => uint256) public exchangeRatio;
    Token public defiToken;
    mapping( address => mapping( string => uint256)) public balances;
    

    constructor () public {
        //디파이 컨트랙트가 생성되면, 디파이 토큰 컨트랙트를 배포하여 자장해 둡니다.
        defiToken = new Token();
        //디파이 컨트랙트의 관리자를 저장합니다. 
        contractManager = msg.sender;
    }


    function deposit(string memory tokenSYM, uint256 amount) public {
        require( address(tokens[tokenSYM]) != address(0),"등록되지 않은 토큰입니다.");

        // transferFrom을 통해 msg.sender 가 보유한 토큰을 컨트랙트로 전송합니다.
        tokens[tokenSYM].transferFrom( msg.sender, address(this), amount);

        // 교환비율만큼 디파이토큰을 발행하여, msg.sender에게 줍니다.
        defiToken.mint( msg.sender, amount * exchangeRatio[tokenSYM]);
    }

    function withdraw(string memory tokenSYM, uint256 amount) public {
        require( address(tokens[tokenSYM]) != address(0),"등록되지 않은 토큰입니다.");
        IERC20 tokenCA = tokens[tokenSYM];
        
        // 요청한 토큰 수량지급에 필요한 디파이 토큰 수량을 계산합니다.
        uint256 requiredAmount = amount * exchangeRatio[tokenSYM];
        require( defiToken.balanceOf(msg.sender) >= requiredAmount,"보유한 디파이 토큰수량이 부족합니다");
        require(tokenCA.balanceOf( address(this) ) >= amount,"컨트랙트가 보유한 토큰이 부족하여 출금이 불가능 합니다");
        
        // msg.sender가 보유한 디파이 토큰을 소각합니다.
        defiToken.burn(msg.sender, requiredAmount);

        // 컨트랙트가 보유한 토큰은 msg.sender 에게 전송합니다.
        tokenCA.transfer(msg.sender,amount);
    }
    
    function addSupportToken(IERC20 _newToken, uint256 _exchangeRatio ) public {
        require( msg.sender == contractManager);
        string memory sym = _newToken.symbol();
        require( address(tokens[sym]) == address(0),"동일한 토큰이 이미 등록되어 있습니다.");
        tokens[sym] = _newToken;
        exchangeRatio[sym] = _exchangeRatio;
    }



}


interface IERC20 {
    function symbol() external view returns(string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}