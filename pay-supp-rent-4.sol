pragma solidity >=0.5.0 <=0.8.3;

contract Paylock {
    
    enum State { Working, Completed, Done_1, Delay, Done_2, Forfeit }

    struct States {
        uint disc;
        State st;
        uint clock;
        address timeAdd;
        address supp1Add;
    }
    
    States variables;
    
    constructor() public {
        variables.st = State.Working;
        variables.disc = 0;
        variables.clock = 0;
        variables.timeAdd = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    }
    
    function tick() external {
        require( variables.timeAdd == msg.sender );
        if (variables.clock < 4) {
            variables.clock = variables.clock + 1;
        }
    }

    function signal() external {
        require( variables.st == State.Working );
        variables.st = State.Completed;
        variables.disc = 10;
        variables.clock = 0;
        variables.supp1Add = msg.sender;
    }

    function collect_1_Y() external {
        require( variables.st == State.Completed );
        require( variables.clock < 4 );
        variables.st = State.Done_1;
        variables.disc = 10;
    }

    function collect_1_N() external {
        require( variables.st == State.Completed );
        require( variables.clock == 4 );
        variables.st = State.Delay;
        variables.disc = 5;
        variables.clock = 0;
    }

    function collect_2_Y() external {
        require( variables.st == State.Delay );
        require( variables.clock < 4 );
        variables.st = State.Done_2;
        variables.disc = 5;
    }

    function collect_2_N() external {
        require( variables.st == State.Delay );
        require( variables.clock == 4 );
        variables.st = State.Forfeit;
        variables.disc = 0;
    }

}


contract Rental {

    uint256 public deposit = 1 wei;
    
    address resource_owner;
    bool resource_available;
    
    constructor() public {
        resource_available = true;
    }
    
    function rent_out_resource() external payable {
        require(resource_available == true);
        require(msg.value == deposit);
        resource_owner = msg.sender;
        resource_available = false;
    }
    
    function retrieve_resource() external {
        require(resource_available == false && msg.sender == resource_owner);
        (bool sucess,) = resource_owner.call.value(deposit)("");
        require(sucess);
        resource_available = true;
    }
    
    function report_balance() external view returns(uint256) {
        return address(this).balance;
    }
    
    receive() external payable {
    }

}


contract Supplier {

    Paylock p;
    
    Rental r;
        
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }    
    State st;
    enum State_Rent { Aquired, Returned }
    State_Rent st_rent;

    constructor(address pp, address payable rr) public {
        p = Paylock(pp);
        r = Rental(rr);
        st = State.Working;
        st_rent = State_Rent.Returned;
    }
    
    function acquire_resource() payable external {
        r.rent_out_resource.value(1 wei)();
        st_rent = State_Rent.Aquired;
    }
    
    function return_resource() external {
        r.retrieve_resource();
        st_rent = State_Rent.Returned;
    }
    
    receive() external payable {
        if (r.report_balance() >= 1 wei) {
            r.retrieve_resource();
        }
    }

    function signal_paylock() external {
        require( st_rent == State_Rent.Aquired );
        require( st == State.Working );
        st = State.Completed;
        p.signal();
    }

    function getpaid_1_Y() external {
        require( st == State.Completed );
        st = State.Done_1;
        p.collect_1_Y();
    }

    function getpaid_1_N() external {
        require( st == State.Completed );
        st = State.Delay;
        p.collect_1_N();
    }

    function getpaid_2_Y() external {
        require( st == State.Delay );
        st = State.Done_2;
        p.collect_2_Y();
    }

    function getpaid_2_N() external {
        require( st == State.Delay );
        st = State.Forfeit;
        p.collect_2_N();
    }

}
