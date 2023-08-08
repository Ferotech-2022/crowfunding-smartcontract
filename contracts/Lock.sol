// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ProjectContract {
    address public owner;
    string public projectName;
    uint256 public fundingGoal;
    uint256 public totalFundsRaised;
    uint256 public numMilestones;
    
    enum MilestoneStatus { NotStarted, InProgress, Completed }
    
    struct Milestone {
        string description;
        uint256 amount;
        MilestoneStatus status;
    }
    
    mapping(uint256 => Milestone) public milestones;
    mapping(address => uint256) public contributions;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    constructor(string memory _projectName, uint256 _fundingGoal, uint256 _numMilestones) {
        owner = msg.sender;
        projectName = _projectName;
        fundingGoal = _fundingGoal;
        numMilestones = _numMilestones;
    }
    
    function contribute() external payable {
        require(totalFundsRaised < fundingGoal, "Funding goal reached");
        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;
    }
    
    function createMilestone(uint256 milestoneIndex, string memory description, uint256 amount) external onlyOwner {
        require(milestoneIndex < numMilestones, "Invalid milestone index");
        milestones[milestoneIndex] = Milestone(description, amount, MilestoneStatus.NotStarted);
    }
    
    function startMilestone(uint256 milestoneIndex) external onlyOwner {
        milestones[milestoneIndex].status = MilestoneStatus.InProgress;
    }
    
    function completeMilestone(uint256 milestoneIndex) external onlyOwner {
        require(milestones[milestoneIndex].status == MilestoneStatus.InProgress, "Milestone not in progress");
        milestones[milestoneIndex].status = MilestoneStatus.Completed;
    }
    
    function releaseFunds(uint256 milestoneIndex) external onlyOwner {
        require(milestones[milestoneIndex].status == MilestoneStatus.Completed, "Milestone not completed");
        require(address(this).balance >= milestones[milestoneIndex].amount, "Insufficient contract balance");
        
        payable(owner).transfer(milestones[milestoneIndex].amount);
    }
}
