//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadLine;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string desc;
        address payable recipient;
        uint value;
        string status;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadLine = block.timestamp + _deadline; //in seconds
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function contributeEth() public payable {
        require(block.timestamp < deadLine, "Deadline has passed.");
        require(msg.value >= minimumContribution, "Min Contribution is not met.");

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function refundAmount() public {
        require(block.timestamp > deadLine && raisedAmount < target,"You are not eligible for refund.");
        require(contributors[msg.sender] == 0);
        address payable contributor = payable(msg.sender);
        contributor.transfer(contributors[msg.sender]);
        contributors[contributor] = 0;
    }

    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }

    function createRequest(string memory _desc, address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.desc = _desc;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.status = "Pending";
        newRequest.noOfVoters = 0;
    }

    function vote(uint _requestNo) public{
        require(contributors[msg.sender] != 0,"You mist be a contributor.");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == true,"You have already Voted.");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
}