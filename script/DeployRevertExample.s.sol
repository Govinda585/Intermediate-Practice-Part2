// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {RevertExample} from "../src/RevertExample.sol";
import {Script} from "forge-std/Script.sol";

contract DeployRevertExample is Script {
    function run() public {
        vm.startBroadcast();
        RevertExample revertExample = new RevertExample();
        vm.stopBroadcast();
    }
}
