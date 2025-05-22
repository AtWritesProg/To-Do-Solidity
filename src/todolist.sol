// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract todoList {
    struct Task {
        uint256 id;
        string task;
        bool completed;
    }

    uint256 public taskCount = 0;
    mapping(uint256 => Task) public tasks;

    address public _owner;
    uint256 public minPayment=0.0001 ether;
    uint256 public maxTasks=100;

    constructor(address owner_, uint256 minPay, uint256 maxT) {
        _owner = owner_;
        minPayment = minPay;
        maxTasks = maxT;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can call this function");
        _;
    }

    function AddTask(string memory _task) public payable {
        require(msg.value >= minPayment, "Minimum 0.00001 ether required");

        require(taskCount < maxTasks, "Task limit reached");
        taskCount++;
        tasks[taskCount] = Task(taskCount, _task, false);
    }

    function getAllTasks() public view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](taskCount);
        for (uint256 i = 0; i < taskCount; i++) {
            allTasks[i] = tasks[i + 1];
        }
        return allTasks;
    }

    function toggleCompleted(uint256 _id) public {
        Task storage t = tasks[_id];
        t.completed = !t.completed;
    }

    function deleteTask(uint256 _id) public {
        delete tasks[_id];
        taskCount--;
    }

    function withdraw() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function taskCounting() public view returns (uint256) {
        return taskCount;
    }
}
