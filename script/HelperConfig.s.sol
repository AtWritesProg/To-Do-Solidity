// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {todoList} from "../src/todolist.sol";

contract HelperConfig is Script {
    address public todoListAddress;
    todoList public todo;

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
        // Will error if OWNER_ADDRESS env var is missing
        return TodoConfig({minPayment: 0.0001 ether, maxTasks: 100, owner: vm.envAddress("OWNER_ADDRESS")});
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

    function setUp() public {
        address owner;

        // Use the activeConfig owner if already set, else fallback
        if (activeConfig.owner != address(0)) {
            owner = activeConfig.owner;
        } else {
            owner = address(0xd08ae577D973648f708B7cBFBBF112948F1Ea3fa);
        }

        vm.startBroadcast(owner);
        todo = new todoList(owner, activeConfig.minPayment, activeConfig.maxTasks);
        vm.stopBroadcast();

        todoListAddress = address(todo);
    }

    function getActiveConfig() public view returns (TodoConfig memory) {
        return activeConfig;
    }
}
