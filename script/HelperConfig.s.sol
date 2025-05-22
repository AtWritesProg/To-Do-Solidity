//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {todoList} from "../src/todolist.sol";

contract HelperConfig is Script {
    address public todoListAddress;

    struct TodoConfig {
        uint256 minPayment; // Minimum ether to add a task
        uint256 maxTasks; // Max allowed tasks
        address owner; // Owner address to deploy or test with
    }

    TodoConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else if (block.chainid == 31337) {
            activeConfig = getAnvilConfig();
        } else {
            revert("No config for this network");
        }
    }

    function getSepoliaConfig() public view returns (TodoConfig memory) {
        return TodoConfig({minPayment: 0.0001 ether, maxTasks: 100, owner: vm.envAddress("OWNER_ADDRESS")});
    }

    function setUp() public {
        todoListAddress = address(new todoList(activeConfig.owner, activeConfig.minPayment, activeConfig.maxTasks));
    }

    function getAnvilConfig() public returns (TodoConfig memory) {
        // For local testing, deploy a fresh owner address and return config
        if (activeConfig.owner != address(0)) {
            return activeConfig;
        }

        vm.startBroadcast();
        address owner = vm.addr(1);
        vm.deal(owner, 10 ether); // Fund owner for tests
        vm.stopBroadcast();

        return TodoConfig({minPayment: 0.001 ether, maxTasks: 100, owner: owner});
    }

    function getactiveConfig() public view returns (TodoConfig memory) {
        return activeConfig;
    }
}
