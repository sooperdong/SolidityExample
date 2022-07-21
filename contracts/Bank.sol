pragma solidity ^0.5.0;

contract Bank {
    address public owner;
    uint256 public balance;

    event Deposit ( address from, uint256 value);
    event Withdraw( address to, uint256 value);
    event Transfer( address from, address to, uint256 value);

    constructor() public payable{
        owner = msg.sender;
        balance = msg.value;
    }

    function deposit() public payable {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 value) public payable {
        address payable to = address( uint160(owner) );
        to.transfer(value);
        emit Withdraw(to, value);
        balance -=value;
    }

    function transfer(address payable to, uint256 value) public payable{
       require( msg.sender==owner,"msg.sender != contract owner");
        to.transfer(value);
        emit Transfer(msg.sender, to, value);
        balance -=value; 
    }

    function bankInfo() public view returns( address, uint256){
        return (owner, balance);
    }
    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function () external payable{
        deposit();
    }


    
}