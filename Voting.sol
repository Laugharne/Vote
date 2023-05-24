// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


/**
 * @author  Franck Maussnd
 * @title   "Voting" contract simulator
 * @dev     "Voting" contract simulator for Alyra school
 * @notice  You can use this contract only for educational purpose
 */
contract Voting is Ownable {

	// Status
	// ------
	enum WorkflowStatus {
		RegisteringVoters,				// [enregistrement des électeurs]	recording the voters
		ProposalsRegistrationStarted,	// [on récolte les propositions]	recording proposals
		ProposalsRegistrationEnded,		// [on clos les propositions]		end of proposals recording
		VotingSessionStarted,			// [le vote est commencé]			we sart the vote
		VotingSessionEnded,				// [le vote est clos]				we stop the vote
		VotesTallied					// [le décompte est fait]			the voting session is ended, we compute...
	}

	string[] private _workFlowStatusDesc = [
		"RegisteringVoters",
		"ProposalsRegistrationStarted",
		"ProposalsRegistrationEnded",
		"VotingSessionStarted",
		"VotingSessionEnded",
		"VotesTallied"
	];

	WorkflowStatus private _workFlowStatus;

	event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);



	// Voters
	// ------
	struct Voter {
		bool isRegistered;		// voter is registred by administrator (true)
		bool hasVoted;			// voter has already voted (true)
		uint votedProposalId;	// he/she has voted for THIS proposal (ID)
	}

	mapping( address => Voter) private _voters;
	address[] private _votersList;
	uint256   private _nnVoters;

	struct VoterFullData {
		Voter   voterData;
		address voterAddress;
	}

	event VoterRegistered(address voterAddress); 
	event Voted (address voter, uint proposalId);



	// Proposals
	// ---------
	struct Proposal {
		string description;		// proposal desc. (short text as description)
		uint   voteCount;		// number of vote for this proposal
	}

	//mapping( address => Proposal) private _proposals;
	Proposal[] private _proposals;

	event ProposalRegistered(uint proposalId);



	// Winner
	// ------
	uint   private _winningProposalId;
	string private _winningProposalDesc;
	bool   private _hasWinner;



	/**
	 * @notice  Contract constructor.
	 * @dev     Initialize some states
	 */
	 constructor() {
		_workFlowStatus      = WorkflowStatus.RegisteringVoters;
		_nnVoters            = 0;
		_hasWinner           = false;
		_winningProposalDesc = "";
	}


	/**
	 * @notice  Get current Workflow Status ID.
	 * @dev     Return private _workFlowStatus atttribute (ID)
	 * @return  WorkflowStatus.
	 */
	function getCurrentStatusId() public view returns( WorkflowStatus) {
		return _workFlowStatus;
	}


	/**
	 * @notice  Get current Workflow Status description.
	 * @dev     Return private _workFlowStatusDesc atttribute (string)
	 * @return  string memory
	 */
	 function getCurrentStatusDescription() public view returns( string memory) {
		return _workFlowStatusDesc[ uint(_workFlowStatus)];
	}


	/**
	 * @notice  Allow to administrator to change the status of the vote process.
	 * @dev     Manage workflow status, launch _countVote() and emit WorkflowStatusChange() event.
	 */
	function nextStatus() public onlyOwner {
		require( _workFlowStatus != WorkflowStatus.VotesTallied, "Votes are tallied");

		WorkflowStatus previousStatus = _workFlowStatus;
		_workFlowStatus = WorkflowStatus( uint( previousStatus) + 1);

		if( _workFlowStatus == WorkflowStatus.VotesTallied) {
			_countVotes();
		}

		emit WorkflowStatusChange( previousStatus, _workFlowStatus);
	}


	/**
	 * @notice  Count the vote for all proposals.
	 * @dev     Determine the winner with the most important vote count
	 */
	function _countVotes() internal {
		uint nn        = _proposals.length;
		uint max       = 0;
		uint id        = 0;
		bool hasResult = false;

		for( uint i = 0; i < nn; i++) {
			if( max > _proposals[i].voteCount) continue;
			max       = _proposals[i].voteCount;
			id        = i;
			hasResult = true;
		}

		require( hasResult == true, "No legetim winner !");
		_hasWinner           = true;
		_winningProposalId   = id;
		_winningProposalDesc = _proposals[id].description;
	}


	/**
	 * @notice  Allow to administrator to add a new voter.
	 * @dev     Just add new default 'Voter' struct to a mapping, and emit VoterRegistered() event.
	 * @param   _voterAddress  .
	 */
	function addVoter( address _voterAddress) public onlyOwner {
		require( _workFlowStatus == WorkflowStatus.RegisteringVoters, "Workflow status is not RegisteringVoters");
		require( _voters[_voterAddress].isRegistered != true, "Voter is allready registred");

		_voters[_voterAddress] = Voter(
			true,	// is registred now !
			false,	// has not yet voted !
			0		// no proposal ID yet !
		);
		_nnVoters++;
		_votersList.push( _voterAddress);

		emit VoterRegistered( _voterAddress);
	}


	/**
	 * @notice  Blacklist (unregistre) a voter account by its address.
	 * @dev     Set isRegistered flag to false.
	 * @param   _voterAddress	voter address to blacklist
	 */
	 function blackList( address _voterAddress) public onlyOwner {
		require( _voters[_voterAddress].isRegistered == true, "Voter is NOT registred, no need to blacklist him/her");
		_voters[_voterAddress].isRegistered = false;
	}


	/**
	 * @notice  Whitelist (registre) a voter account by its address.
	 * @dev     Set isRegistered flag to false.
	 * @param   _voterAddress	voter adress to whitelist
	 */
	 function whiteList( address _voterAddress) public onlyOwner {
		require( _voters[_voterAddress].isRegistered == false, "Voter is already registred, no need to whitelist him/her");
		_voters[_voterAddress].isRegistered = true;
	}


	/**
	 * @notice  Allow for every registred voter to add a proposal.
	 * @dev     Just add new default 'Proposal' struct to an array and emit ProposalRegistered() event.
	 * @param   _description	proposal description
	 */
	function addProposal( string memory _description) public  {
		require( _workFlowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Workflow status is not ProposalsRegistrationStarted");
		require( _voters[msg.sender].isRegistered == true, "Voter not registred");

		_proposals.push( Proposal(
			_description,	// proposal desc.
			0				// not voted yet
		));

		emit ProposalRegistered( _proposals.length - 1);
	}


	/**
	 * @notice  Allow for a voter to vote (only one time) for a proposal.
	 * @dev     Record a vote, tag the voter as he/she has voted and emit an event Voted().
	 * @param   proposalId  ID of the proposal we want to vote for.
	 */
	function vote(uint proposalId) public  {
		require( _workFlowStatus == WorkflowStatus.VotingSessionStarted, "Workflow status is not VotingSessionStarted");
		require( _voters[msg.sender].isRegistered == true, "Voter not registred");
		require( _voters[msg.sender].hasVoted == false, "Voter has already voted !");
		require( proposalId < _proposals.length, "Bad proposal ID");

		_proposals[ proposalId].voteCount++;
		address addr                  = msg.sender;
		_voters[addr].hasVoted        = true;
		_voters[addr].votedProposalId = proposalId;

		emit Voted( addr, proposalId);
	}


	/**
	 * @notice  Allow to see all voters.
	 * @dev     Since the voter is allowed, return proposals data.
	 * @return  VoterFullData[].
	 */
	function seeVoters() public view returns ( VoterFullData[] memory) {
		require( _voters[msg.sender].isRegistered == true, "Voter is not allowed");

		VoterFullData[] memory votersList = new VoterFullData[](_nnVoters);
		address addr;
		for( uint i = 0; i < _nnVoters; i++	) {
			addr          = _votersList[i];
			votersList[i] = VoterFullData( _voters[addr], addr);
		}

		return votersList;
	}


	/**
	 * @notice  Allow to obtain proposal data (description & vote count).
	 * @dev     Since the voter is allowed, return proposals data.
	 * @return  Proposal[].
	 */
	function seeProposals() public view returns(Proposal[] memory) {
		require( _voters[msg.sender].isRegistered == true, "Voter is not allowed");

		return _proposals;
	}


	/**
	 * @notice  Allow to obtain proposal winner (description).
	 * @dev     Since the vote is tallied, just return _winningProposalDesc attribut.
	 * @return  string.
	 */
	function getWinner() public view returns( string memory) {
		require( _workFlowStatus == WorkflowStatus.VotesTallied, "Workflow status is not VotesTallied");
		require( _hasWinner == true, "No legitim winner yet !");

		return _winningProposalDesc;
	}

}
