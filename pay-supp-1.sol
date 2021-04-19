pragma solidity >=0.5.0 <=0.8.3;

contract Paylock {
    
    enum State { Working, Completed, Done_1, Delay, Done_2, Forfeit }

    struct States {
        uint disc;
        State st;
        uint clock;
        address timeAdd;
    }
    
    States variables;
    
    event Log(string message);
    
    constructor() public {
        variables.st = State.Working;
        variables.disc = 0;
        variables.clock = 0;
        variables.timeAdd = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    }
    
    function tick() external {
        require( variables.timeAdd == msg.sender, "Wrong account");
        if (variables.clock < 4) {
            variables.clock = variables.clock + 1;
            emit Log("Tick");
        } else {
            emit Log("Clock is 4 or bigger. Did not increment the clock");
        }
         variables.st = State.Delay;
        variables.disc = 5;
        variables.clock = 0;
        emit Log("Client delayed, discount is 5");
    }

    function collect_2_Y() external {
        require( variables.st == State.Delay, "State is not DELAYED" );
        require( variables.clock < 4, "Clock bigger than 4" );
        variables.st = State.Done_2;
        variables.disc = 5;
        emit Log("Client collected later, discount is 5");
    }

    function collect_2_N() external {
        require( variables.st == State.Delay, "State is not DELAYED" );
        require( variables.clock == 4, "Clock not yet 4");
        variables.st = State.Forfeit;
        variables.disc = 0;
        emit Log("Client forfeited, discount is 0");
    }

}}

    function signal() external {
        require( variables.st == State.Working, "State is not WORKING");
        variables.st = State.Completed;
        variables.disc = 10;
        variables.clock = 0;
        emit Log("Signal recieved, discount is 10");
    }

    function collect_1_Y() external {
        require( variables.st == State.Completed, "State is not COMPLETED");
        require( variables.clock < 4, "Clock bigger than 4"  );
        variables.st = State.Done_1;
        variables.disc = 10;
        emit Log("Client collected first, discount is 10");
    }

    function collect_1_N() external {
        require( variables.st == State.Completed, "State is not COMPLETED" );
        require( variables.clock == 4, "Clock not yet 4" );
        variables.st = State.Delay;
        variables.disc = 5;
        variables.clock = 0;
        emit Log("Client delayed, discount is 5");
    }

    function collect_2_Y() external {
        require( variables.st == State.Delay, "State is not DELAYED" );
        require( variables.clock < 4, "Clock bigger than 4" );
        variables.st = State.Done_2;
        variables.disc = 5;
        emit Log("Client collected later, discount is 5");
    }

    function collect_2_N() external {
        require( variables.st == State.Delay, "State is not DELAYED" );
        require( variables.clock == 4, "Clock not yet 4");
        variables.st = State.Forfeit;
        variables.disc = 0;
        emit Log("Client forfeited, discount is 0");
    }

}

contract Supplier {

    Paylock p;
        
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }    

    State st;

    constructor(address pp) public {
        p = Paylock(pp);
        st = State.Working;
    }

    function signal_paylock() external {
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
