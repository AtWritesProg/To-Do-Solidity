// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {todoList} from "../src/todolist.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployTodo is Script {
    function run() external {
        HelperConfig config = new HelperConfig();
        HelperConfig.TodoConfig memory active = config.getactiveConfig();

        vm.startBroadcast();
        todoList todo = new todoList(active.owner, active.minPayment, active.maxTasks);
        vm.stopBroadcast();
    }
}
