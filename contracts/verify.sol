// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Verify {
    
    struct Node {
        string[] abilities;
        bool hireable;
        uint256 balance;
        address owner; 
    }

    mapping(address => Node) private nodes;
    mapping(address => bool) private nodeExists;
    address public nodeContract;  
    address public mainContract;  

    event NodeCreated(address indexed nodeAddress, address owner);
    event HireableStatusUpdated(address indexed nodeAddress, bool newStatus);
    event NodeQuit(address indexed nodeAddress, uint256 refundAmount);

    modifier nodeExistsCheck(address _node) {
        require(nodeExists[_node], "Node bulunamadi");
        _;
    }

    constructor(address _nodeContract, address _mainContract) {
        nodeContract = _nodeContract;
        mainContract = _mainContract;
    }

    function createNode(address _node, string[] memory _abilities, address _owner) public {
        
        
        if (!nodeExists[_node]) {
            nodes[_node] = Node({
                abilities: _abilities,
                hireable: true,
                balance: 0,
                owner: _owner
            });
            nodeExists[_node] = true;
            emit NodeCreated(_node, _owner);  
        }
    }

    function getNode(address _node) public view nodeExistsCheck(_node) returns (string[] memory, bool, address) {
        Node memory node = nodes[_node];
        return (node.abilities, node.hireable, node.owner);
    }

    function updateHireableStatus(address _node) public nodeExistsCheck(_node) {
        bool isSubmitted = INode(nodeContract).submit(_node);
        bool isFinished = INode(nodeContract).finishWork(_node);
        
        if (isSubmitted && !isFinished) {
            nodes[_node].hireable = false;
        } else if (isFinished) {
            nodes[_node].hireable = true; 
        }
        emit HireableStatusUpdated(_node, nodes[_node].hireable); 
        
    }

    function quit(address _node) public nodeExistsCheck(_node) {
        Node storage node = nodes[_node];

        uint256 refundAmount = IMainContract(mainContract).withdraw(_node);

        payable(node.owner).transfer(refundAmount);

        emit NodeQuit(_node, refundAmount);  

        INode(nodeContract).finishWork(_node);

        delete nodes[_node];
        nodeExists[_node] = false;
    }

    fallback() external payable {}

    receive() external payable {}
}

interface INode {
    function submit(address _node) external view returns (bool);
    function finishWork(address _node) external view returns (bool);
}

interface IMainContract {
    function withdraw(address _node) external returns (uint256);
}
