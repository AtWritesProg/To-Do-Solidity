//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {todoList} from "../src/todolist.sol";

contract TodoList is Test {
    todoList public todo;
    address public owner;

    uint256 private constant value = 0.001 ether;

    function setUp() public {
        todo = new todoList(vm.envAddress("OWNER_ADDRESS"), 0.0001 ether, 100);
        owner = todo._owner();
    }

    function testAddTask() public {
        string memory task = "Test Task";
        todo.AddTask{value: value}(task);
        todoList.Task[] memory tasks = todo.getAllTasks();
        assertEq(tasks[0].task, "Test Task");
        assertEq(tasks[0].completed, false);
    }

    function testAddTaskWithInsufficientValue() public {
        string memory task = "Test Task";
        vm.expectRevert("Minimum 0.00001 ether required");
        todo.AddTask{value: 0.00000001 ether}(task);
    }

    function testOnlyOwner() public {
        owner = vm.addr(1);
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        todo = new todoList(owner, 0.0001 ether, 100);
        vm.prank(owner);
        todo.AddTask{value: 0.001 ether}("Test Task");

        uint256 before = owner.balance;

        vm.prank(owner);
        todo.withdraw();

        uint256 afterBal = owner.balance;
        assertGt(afterBal, before);
    }

    function testAddTaskWithMaxTasks() public {
        for (uint256 i = 0; i < todo.maxTasks(); i++) {
            todo.AddTask{value: value}("Test Task");
        }
        vm.expectRevert("Task limit reached");
        todo.AddTask{value: value}("Test Task");
    }

    function testGetAllTasks() public {
        string memory task1 = "Test Task 1";
        string memory task2 = "Test Task 2";

        todo.AddTask{value: value}(task1);
        todo.AddTask{value: value}(task2);
        todoList.Task[] memory tasks = todo.getAllTasks();
        assertEq(tasks[0].task, task1);
        assertEq(tasks[1].task, task2);
    }

    function testToggleCompleted() public {
        string memory task = "Test Task";
        todo.AddTask{value: value}(task);
        todo.toggleCompleted(0);
    }

    function testDeleteTask() public {
        string memory task = "Test Task";
        todo.AddTask{value: value}(task);
        todo.deleteTask(1);
        todoList.Task[] memory tasks = todo.getAllTasks();
        assertEq(tasks.length, 0);
        assert(todo.taskCounting() == 0);
    }
}
