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
    
    address resource_owner;
    bool resource_available;
    
    constructor() public {
        resource_available = true;
    }
    
    function rent_out_resource() external {
        require(resource_available == true);
        resource_owner = msg.sender;
        resource_available = false;
    }
    
    function retrieve_resource() external {
        require(resource_available == false && msg.sender == resource_owner);
        resource_available = true;
    }

}


contract Supplier {

    Paylock p;
    
    Rental r;
        
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }    
    
    bool resource_available;

    State st;

    constructor(address pp, address rr) public {
        p = Paylock(pp);
        r = Rental(rr);
        st = State.Working;
        resource_available = true;
    }
    
    function acquire_resource() external {
        require(resource_available == true);
        r.rent_out_resource();
        resource_available = false;
    }
    
    function return_resource() external {
        require(resource_available == false);
        r.retrieve_resource();
        resource_available = true;
    }

    function signal_paylock() external {
        require( resource_available == true );
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