// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {Database} from "../src/Database.sol";
import {Proxy} from "../src/Proxy.sol";

contract ResolutionScript is Script {
    Database internal implementation;
    Proxy internal proxy;
    address internal user;

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
        // write your solution here !
        
    }

    function isSolved() internal view returns (bool) {
        return address(proxy).balance == 0;
    }
}
