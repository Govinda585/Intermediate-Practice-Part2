// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {PausablePattern} from "../src/PausablePattern.sol";

contract DeployPausablePattern is Script {
    PausablePattern public pausablePattern;
    function run() public {
        vm.startBroadcast();
        pausablePattern = new PausablePattern();
        vm.stopBroadcast();
    }
}

// forge script script/DeployPausablePattern.s.sol:DeployPausablePattern\
// --rpc-url http://127.0.0.1:8545 --private-key\
// 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d\
// --broadcast
