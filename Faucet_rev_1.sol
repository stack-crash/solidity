// SPDX-License-Identifier: MIT
// ^ used to supress compiler warning. Fix this later

//Test contract written from template on pg. 27 of Mastering Ethereum
//Implements a Faucet on Ropsten Test Network

// Version of Solidity compiler this program was written for
pragma solidity 0.8.11;

// contract template has features to be inherited by Faucet contract (main)
contract owner_protected {

    // owner var is the EOA that initializes this SC
    address owner;

    // Executes ONLY on contract initialization
    // hence: msg.sender will be the contract creator's address
    constructor () {
        owner = msg.sender;
    }

    // modifer ensures that only owner of contract can interact
    modifier only_owner {

        // assert that sender (EOA calling this fn.) is owner 
        require(msg.sender == owner, "failed to execute: owner address expected");

        // resume standard flow
        _;
    }
}


contract Faucet is owner_protected {

    // Withdrawal and deposit events:
    //  - will have following format in report log:
    //  - "Withdrawal { to: '0xabcd....01234'
    //                  amount: BigNumber { s: 1, e: 18, c: [ 10000 ] } }"
    event Withdrawal (address indexed to, uint amount);
    event Deposit (address indexed from, uint amount);

    // Give out limited ether to anyone who asks, not that the return part is void 
    // because this just sends ETH to the requester and finishes w/o returning a datatype
    function withdraw(uint withdraw_amount) public {
        
        // Limit withdrawal amount
        require(withdraw_amount <= 0.1 ether, "attempted withdrawal of ETH in excess of MAX=0.1");
        // Verify that requested funds are present
        require(withdraw_amount <= address(this).balance, "faucet has insufficient funds to satisfy request");

        payable(msg.sender).transfer(withdraw_amount);
        emit Withdrawal(msg.sender, withdraw_amount);
    }

    // Self-destruction function (note: Vitalik hates these, research why)
    function destroy_and_liquidate () public only_owner {

        // liquidate funds to creator's address
        selfdestruct(payable(address(owner)));

    }


    // Accept any incoming amount
    // this is a "fallback" or "default" function, and handles receiving funds that are sent to this test faucet
    receive () external payable {
        emit Deposit(msg.sender, msg.value);
    }
    //  the empty function definition (i.e. everything in {}) means this does nothing but receive. Simple as.

}