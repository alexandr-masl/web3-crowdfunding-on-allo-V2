// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import "hardhat/console.sol";
// External Libraries
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// Intefaces
import {IAllo} from "./interfaces/IAllo.sol";
import {IRegistry} from "./interfaces/IRegistry.sol";
// Core Contracts
import {BaseStrategy} from "./BaseStrategy.sol";
// Internal Libraries
import {Metadata} from "./libraries/Metadata.sol";
import {IHats} from "./interfaces/Hats/IHats.sol";



// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⢿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⡟⠘⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣾⠻⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠀⠀⠸⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠀⠀⢀⣠⣴⣴⣶⣶⣶⣦⣦⣀⡀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⡿⠃⠀⠙⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠁⠀⠀⠀⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠘⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⠀⠀⠈⢿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⣰⣿⣿⣿⡿⠋⠁⠀⠀⠈⠘⠹⣿⣿⣿⣿⣆⠀⠀⠀
// ⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡀⠀⠀
// ⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣟⠀⡀⢀⠀⡀⢀⠀⡀⢈⢿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀
// ⠀⠀⣠⣿⣿⣿⣿⣿⣿⡿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⡿⢿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣷⡀⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠸⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠂⠀⠀
// ⠀⠀⠙⠛⠿⠻⠻⠛⠉⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣧⠀⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⢻⣿⣿⣿⣷⣀⢀⠀⠀⠀⡀⣰⣾⣿⣿⣿⠏⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣧⠀⠀⢸⣿⣿⣿⣗⠀⠀⠀⢸⣿⣿⣿⡯⠀⠀⠀⠀⠹⢿⣿⣿⣿⣿⣾⣾⣷⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠙⠋⠛⠙⠋⠛⠙⠋⠛⠙⠋⠃⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠻⠟⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠟⠿⠟⠿⠆⠀⠸⠿⠿⠟⠯⠀⠀⠀⠸⠿⠿⠿⠏⠀⠀⠀⠀⠀⠈⠉⠻⠻⡿⣿⢿⡿⡿⠿⠛⠁⠀⠀⠀⠀⠀⠀
//                    allo.gitcoin.co

/// @title Executor Supplier Voting Strategy.
/// @notice Strategy used to allocate & distribute funds to recipients with milestone payouts. The milestones
///         are set by the recipient and the pool manager can accept or reject the milestone. The pool manager
///         can also reject the recipient.
contract ExecutorSupplierVotingStrategy is BaseStrategy, ReentrancyGuard {

    /// ================================
    /// ========== Storage =============
    /// ================================

    /// @notice Struct to hold details of an recipient
    enum StrategyState {
        None,
        Active,
        Executed,
        Rejected
    }

    /// @notice Struct to hold details of an recipient
    struct Recipient {
        bool useRegistryAnchor;
        address recipientAddress;
        uint256 grantAmount;
        Metadata metadata;
        Status recipientStatus;
        Status milestonesReviewStatus;
    }

    /// @notice Struct to hold milestone details
    struct Milestone {
        uint256 amountPercentage;
        Metadata metadata;
        Status milestoneStatus;
        string description;
    }

    /// @notice Struct to hold the initialization parameters for the strategy.
    struct InitializeData {
        uint256 supplierHat;          // ID of the Supplier Hat.
        uint256 executorHat;          // ID of the Executor Hat.
        SupplierPower[] projectSuppliers; // Array of SupplierPower, representing the power of each supplier.
        address hatsContractAddress;  // Address of the Hats contract.
        uint8 thresholdPercentage;
    }

    /// @notice Struct to represent the offered milestones along with their voting status.
    struct OfferedMilestones {
        Milestone[] milestones;       // Array of Milestones that are offered.
        uint256 votesFor;             // Total number of votes in favor of the offered milestones.
        uint256 votesAgainst;         // Total number of votes against the offered milestones.
        mapping(address => uint256) suppliersVotes; // Mapping of supplier addresses to their vote counts.
    }

    /// @notice Struct to represent a submitted milestone and its voting status.
    struct SubmiteddMilestone {
        uint256 votesFor;             // Total number of votes in favor of the submitted milestone.
        uint256 votesAgainst;         // Total number of votes against the submitted milestone.
        mapping(address => uint256) suppliersVotes; // Mapping of supplier addresses to their vote counts.
    }

    /// @notice Struct to represent the voting status for rejecting a project.
    struct RejectProject {
        uint256 votesFor;             // Total number of votes in favor of rejecting the project.
        uint256 votesAgainst;         // Total number of votes against rejecting the project.
        mapping(address => uint256) suppliersVotes; // Mapping of supplier addresses to their vote counts.
    }

    /// @notice Struct to represent the power of a supplier.
    struct SupplierPower {
        address supplierId;           // Address of the supplier.
        uint256 supplierPowerr;       // Power value associated with the supplier.
    }

    /// ===============================
    /// ========== Errors =============
    /// ===============================

    /// @notice Thrown when an invalid milestone is encountered.
    error INVALID_MILESTONE();

    /// @notice Thrown when the percentage for milestones is invalid.
    error INVALID_MILESTONES_PERCENTAGE();

    /// @notice Thrown when trying to accept a milestone that is already accepted.
    error MILESTONE_ALREADY_ACCEPTED();

    /// @notice Thrown when attempting to set milestones that have already been set.
    error MILESTONES_ALREADY_SET();

    /// @notice Error thrown when an operation is attempted on a milestone with an inappropriate status.
    error INVALID_MILESTONE_STATUS();

    /// @notice Thrown when a supplier has already reviewed the milestones.
    error ALREADY_REVIEWED();

    /// @notice Thrown when the allocation amount exceeds the available amount in the pool.
    error ALLOCATION_EXCEEDS_POOL_AMOUNT();

    /// @notice Thrown when an operation is attempted with an invalid status.
    error INVALID_STATUS();

    /// @notice Thrown when an action requires the executor hat but the executor is not wearing it.
    error EXECUTOR_HAT_WEARING_REQUIRED();

    /// @notice Thrown when an action requires the supplier hat but the supplier is not wearing it.
    error SUPPLIER_HAT_WEARING_REQUIRED();

    /// @notice Thrown when strategy is not yet finished.
    error STRATEGY_IS_STILL_ACIVE();


    /// ===============================
    /// ========== Events =============
    /// ===============================

    /// @notice Emitted when the status of a recipient is changed.
    event RecipientStatusChanged(address recipientId, Status status);

    /// @notice Emitted when a milestone is submitted by a recipient.
    event MilestoneSubmitted(address recipientId, uint256 milestoneId, Metadata metadata);

    /// @notice Emitted when a submitted milestone is reviewed.
    event SubmittedvMilestoneReviewed(address recipientId, uint256 milestoneId, Status status);

    /// @notice Emitted when the status of a milestone is changed.
    event MilestoneStatusChanged(address recipientId, uint256 milestoneId, Status status);

    /// @notice Emitted when a project rejection is declined.
    event ProjectRejectDeclined();

    /// @notice Emitted when a project is rejected.
    event ProjectRejected();

    /// @notice Emitted when milestones are set for a recipient.
    event MilestonesSet(address recipientId, uint256 milestonesLength);

    /// @notice Emitted when milestones for a recipient are reviewed.
    event MilestonesReviewed(address recipientId, Status status);

    /// @notice Emitted when milestones are offered to a recipient.
    event MilestonesOffered(address recipientId, uint256 milestonesLength);

    /// @notice Emitted when offered milestones are accepted for a recipient.
    event OfferedMilestonesAccepted(address recipientId);

    /// @notice Emitted when offered milestones are rejected for a recipient.
    event OfferedMilestonesRejected(address recipientId);

    /// @notice Emitted when tokens of thanks was Sent.
    event TokenOfThanksSent(address supplier, uint256 amount);


    /// ================================
    /// ========== Storage =============
    /// ================================

    /// @notice Holds the current state of the strategy.
    StrategyState public state;

    /// @notice Stores the ID of the Supplier Hat.
    uint256 public supplierHat;

    /// @notice Stores the ID of the Executor Hat.
    uint256 public executorHat;

    /// @notice Total supply of tokens or resources managed by the strategy.
    uint256 public totalSupply;

    /// @notice Percentage threshold for decision-making or other strategy-related actions.
    uint256 public thresholdPercentage;

    /// @notice Interface to interact with the 'Registry' contract.
    IRegistry private _registry;

    /// @notice Total amount allocated for grants to recipients.
    uint256 public allocatedGrantAmount;

    /// @notice Address of the Hats main contract.
    IHats public hatsContract;

    /// @notice List of recipient addresses that have been accepted and can submit milestones.
    address[] private _acceptedRecipientIds;

    /// @notice Temporary storage for supplier addresses.
    address[] private _suppliersStore;

    /// @notice Mapping of recipient addresses to their detailed information.
    /// @dev Maps 'recipientId' to 'Recipient' struct.
    mapping(address => Recipient) private _recipients;

    /// @notice Mapping of supplier addresses to their power value.
    mapping(address => uint256) private _suplierPower;

    /// @notice Mapping of recipient addresses to their offered milestones.
    mapping(address => OfferedMilestones) offeredMilestones;

    /// @notice Struct holding information about project rejection voting.
    RejectProject projectReject;

    /// @notice Mapping of recipient addresses to their array of milestones.
    /// @dev Maps 'recipientId' to an array of 'Milestone' structs.
    mapping(address => Milestone[]) public milestones;

    /// @notice Mapping of recipient addresses to the ID of their next upcoming milestone.
    /// @dev Maps 'recipientId' to 'nextMilestone' ID.
    mapping(address => uint256) public upcomingMilestone;

    /// @notice Mapping of milestone IDs to their submitted milestone details.
    mapping(uint256 => SubmiteddMilestone) public submittedvMilestones;


    /// ===============================
    /// ======== Constructor ==========
    /// ===============================

    /// @notice Constructor for the Executor Supplier Voting Strategy.
    /// @param _allo The 'Allo' contract
    /// @param _name The name of the strategy
    constructor(address _allo, string memory _name) BaseStrategy(_allo, _name) {}

    /// ===============================
    /// ========= Initialize ==========
    /// ===============================

    /// @notice Initialize the strategy
    /// @param _poolId ID of the pool
    /// @param _data The data to be decoded
    /// @custom:data (uint256 supplierHat, uint256 executorHat)
    function initialize(uint256 _poolId, bytes memory _data) external virtual override {
        (InitializeData memory initData) = abi.decode(_data, (InitializeData));
        _ExecutorSupplierVotingStrategy_init(_poolId, initData);
        emit Initialized(_poolId, _data);
    }

    /// @notice This initializes the BaseStrategy
    /// @dev You only need to pass the 'poolId' to initialize the BaseStrategy and the rest is specific to the strategy
    /// @param _poolId ID of the pool - required to initialize the BaseStrategy
    /// @param _initData The init params for the strategy (uint256 supplierHat, uint256 executorHat, SupplierPower[] supliersPower, address hatsContractAddress;)
    function _ExecutorSupplierVotingStrategy_init(uint256 _poolId, InitializeData memory _initData) internal {
        // Initialize the BaseStrategy
        __BaseStrategy_init(_poolId);

        // Set the strategy specific variables
        supplierHat = _initData.supplierHat;
        executorHat = _initData.executorHat;
        thresholdPercentage = _initData.thresholdPercentage;
        hatsContract = IHats(_initData.hatsContractAddress);

        SupplierPower[] memory supliersPower =  _initData.projectSuppliers;

        uint256 totalInvestment = 0;
        for (uint i = 0; i < supliersPower.length; i++) {
            totalInvestment += supliersPower[i].supplierPowerr;
        }

        for (uint i = 0; i < supliersPower.length; i++) {
            _suppliersStore.push(supliersPower[i].supplierId);

            // Normalize supplier power to a percentage
            _suplierPower[supliersPower[i].supplierId] = (supliersPower[i].supplierPowerr * 1e18) / totalInvestment;
            totalSupply += _suplierPower[supliersPower[i].supplierId];
        }


        _registry = allo.getRegistry();

        // Set the pool to active - this is required for the strategy to work and distribute funds
        _setPoolActive(true);

        state = StrategyState.Active;
    }

    /// ===============================
    /// ============ Views ============
    /// ===============================

    /// @notice Get the recipient
    /// @param _recipientId ID of the recipient
    /// @return Recipient Returns the recipient
    function getRecipient(address _recipientId) external view returns (Recipient memory) {
        return _getRecipient(_recipientId);
    }

    /// @notice Get the status of the milestone of an recipient.
    /// @dev This is used to check the status of the milestone of an recipient and is strategy specific
    /// @param _recipientId ID of the recipient
    /// @param _milestoneId ID of the milestone
    /// @return Status Returns the status of the milestone using the 'Status' enum
    function getMilestoneStatus(address _recipientId, uint256 _milestoneId) external view returns (Status) {
        return milestones[_recipientId][_milestoneId].milestoneStatus;
    }

    /// @notice Get the milestones.
    /// @param _recipientId ID of the recipient
    /// @return Milestone[] Returns the milestones for a 'recipientId'
    function getMilestones(address _recipientId) external view returns (Milestone[] memory) {
        return milestones[_recipientId];
    }

    /// @notice Retrieves the number of votes in favor of the offered milestones for a specific recipient.
    /// @param _recipientId ID of the recipient
    /// @return uint256 Number of votes for the offered milestones
    function getOfferedMilestonesVotesFor(address _recipientId) external view returns (uint256) {
        return offeredMilestones[_recipientId].votesFor;
    }

    /// @notice Retrieves the number of votes against the offered milestones for a specific recipient.
    /// @param _recipientId ID of the recipient
    /// @return uint256 Number of votes against the offered milestones
    function getOfferedMilestonesVotesAgainst(address _recipientId) external view returns (uint256) {
        return offeredMilestones[_recipientId].votesAgainst;
    }

    /// @notice Retrieves the vote of a specific supplier on the offered milestones for a recipient.
    /// @param _recipientId ID of the recipient
    /// @param _supplier Address of the supplier
    /// @return uint256 Vote count of the supplier on the offered milestones
    function getSupplierOfferedMilestonesVote(address _recipientId, address _supplier) external view returns (uint256) {
        return offeredMilestones[_recipientId].suppliersVotes[_supplier];
    }

    /// @notice Retrieves the number of votes in favor of a specific submitted milestone.
    /// @param _milestoneId ID of the milestone
    /// @return uint256 Number of votes for the submitted milestone
    function getSubmittedMilestonesVotesFor(uint256 _milestoneId) external view returns (uint256) {
        return submittedvMilestones[_milestoneId].votesFor;
    }

    /// @notice Retrieves the number of votes against a specific submitted milestone.
    /// @param _milestoneId ID of the milestone
    /// @return uint256 Number of votes against the submitted milestone
    function getSubmittedMilestonesVotesAgainst(uint256 _milestoneId) external view returns (uint256) {
        return submittedvMilestones[_milestoneId].votesAgainst;
    }

    /// @notice Retrieves the vote of a specific supplier on a submitted milestone.
    /// @param _milestoneId ID of the milestone
    /// @param _supplier Address of the supplier
    /// @return uint256 Vote count of the supplier on the submitted milestone
    function getSupplierSubmittedMilestonesVote(uint256 _milestoneId, address _supplier) external view returns (uint256) {
        return submittedvMilestones[_milestoneId].suppliersVotes[_supplier];
    }

    /// @notice Retrieves the ID of the next upcoming milestone for a specific recipient.
    /// @param _recipientId ID of the recipient
    /// @return uint256 ID of the upcoming milestone
    function getUpcomingMilestone(address _recipientId) external view returns (uint256) {
        return upcomingMilestone[_recipientId];
    }

    /// @notice Retrieves the total number of votes in favor of rejecting the project.
    /// @return uint256 Total number of votes for rejecting the project
    function getRejectProjectVotesFor() external view returns (uint256) {
        return projectReject.votesFor;
    }

    /// @notice Retrieves the total number of votes against rejecting the project.
    /// @return uint256 Total number of votes against rejecting the project
    function getRejectProjectVotesAgainst() external view returns (uint256) {
        return projectReject.votesAgainst;
    }

   /// @notice Retrieves the number of votes cast by the calling supplier regarding the rejection of the project.
    /// @dev This function returns the vote count specific to the supplier who calls it, identified by msg.sender.
    /// @return uint256 The number of votes cast by the calling supplier on the project rejection proposal.
    function getRejectProjectSupplierVotes() external view returns (uint256) {
        return projectReject.suppliersVotes[msg.sender];
    }

    /// @notice Retrieves the offered milestones for a specific recipient.
    /// @param _recipientId The ID of the recipient whose milestones are being requested.
    /// @return Milestone[] An array of milestones offered to the recipient.
    function getOffeeredMilestones(address _recipientId) external view returns (Milestone[] memory) {
        return offeredMilestones[_recipientId].milestones;
    }

    /// ===============================
    /// ======= External/Custom =======
    /// ===============================

    /// @notice Offers milestones to a specific recipient.
    /// @param _recipientId The ID of the recipient to whom the milestones are being offered.
    /// @param _milestones An array of milestones to be offered.
    /// @dev Requires the sender to be wearing the executor hat and to be either the recipient or a member of the recipient's profile.
    /// Emits a MilestonesOffered event upon successful offering of milestones.
    function offerMilestones(address _recipientId, Milestone[] memory _milestones) external {
        if (!hatsContract.isWearerOfHat(msg.sender, executorHat)) {
            revert EXECUTOR_HAT_WEARING_REQUIRED();
        }

        bool isRecipientCreator = (msg.sender == _recipientId) || _isProfileMember(_recipientId, msg.sender);
        if (!isRecipientCreator) {
            revert UNAUTHORIZED();
        }

        Recipient storage recipient = _recipients[_recipientId];

        // Check if the recipient is accepted, otherwise revert
        if (recipient.recipientStatus != Status.Accepted) {
            revert RECIPIENT_NOT_ACCEPTED();
        }

        // Check if the milestones have already been reviewed and set, and if so, revert
        if (recipient.milestonesReviewStatus == Status.Accepted) {
            revert MILESTONES_ALREADY_SET();
        }

        _resetOfferedMilestones(_recipientId);

        for (uint i = 0; i < _milestones.length; i++) {
            offeredMilestones[_recipientId].milestones.push(_milestones[i]);
        }

        emit MilestonesOffered(_recipientId, _milestones.length);
    }

    /// @notice Reviews the offered milestones for a specific recipient and sets their status.
    /// @param _recipientId The ID of the recipient whose milestones are being reviewed.
    /// @param _status The new status to be set for the offered milestones.
    /// @dev Requires the sender to be the pool manager and wearing the supplier hat.
    /// Emits a MilestonesReviewed event and, depending on the outcome, either OfferedMilestonesAccepted or OfferedMilestonesRejected.
    function reviewOfferedtMilestones(address _recipientId, Status _status) external onlyPoolManager(msg.sender) {
        if (!hatsContract.isWearerOfHat(msg.sender, supplierHat)) {
            revert SUPPLIER_HAT_WEARING_REQUIRED();
        }

        if (offeredMilestones[_recipientId].suppliersVotes[msg.sender] > 0) {
            revert ALREADY_REVIEWED();
        }

        Recipient storage recipient = _recipients[_recipientId];

        if (recipient.milestonesReviewStatus == Status.Accepted) {
            revert MILESTONES_ALREADY_SET();
        }

        uint256 managerVotingPower = _suplierPower[msg.sender];
        uint256 threshold = totalSupply * thresholdPercentage / 100;

        offeredMilestones[_recipientId].suppliersVotes[msg.sender] = managerVotingPower;

        if (_status == Status.Accepted) {
            offeredMilestones[_recipientId].votesFor += managerVotingPower;

            if (offeredMilestones[_recipientId].votesFor > threshold) {
                _recipients[_recipientId].milestonesReviewStatus = _status;
                _setMilestones(_recipientId, offeredMilestones[_recipientId].milestones);
                emit OfferedMilestonesAccepted(_recipientId);
            }
        } else if (_status == Status.Rejected) {
            offeredMilestones[_recipientId].votesAgainst += managerVotingPower;

            if (offeredMilestones[_recipientId].votesAgainst > threshold) {
                _recipients[_recipientId].milestonesReviewStatus = _status;
                _resetOfferedMilestones(_recipientId);
                emit OfferedMilestonesRejected(_recipientId);
            }
        }

        emit MilestonesReviewed(_recipientId, _status);
    }

    /// @notice Submits a milestone for a specific recipient.
    /// @dev Requires that the sender is wearing the executor hat and is the same as `_recipientId`.
    ///      The recipient must be in an 'Accepted' status, and the milestone must be the upcoming one and not already accepted.
    ///      Emits a `MilestoneSubmitted` event upon successful submission.
    /// @param _recipientId ID of the recipient submitting the milestone.
    /// @param _milestoneId ID of the milestone being submitted.
    /// @param _metadata Metadata providing proof of work or other relevant information for the milestone.
    function submitMilestone(address _recipientId, uint256 _milestoneId, Metadata calldata _metadata) external {
        if (!hatsContract.isWearerOfHat(msg.sender, executorHat)) {
            revert EXECUTOR_HAT_WEARING_REQUIRED();
        }
        
        // Ensure that the sender is the recipient of the milestone
        if (_recipientId != msg.sender) {
            revert UNAUTHORIZED();
        }

        Recipient memory recipient = _recipients[_recipientId];

        // Ensure that the recipient is in an 'Accepted' status
        if (recipient.recipientStatus != Status.Accepted) {
            revert RECIPIENT_NOT_ACCEPTED();
        }

        Milestone[] storage recipientMilestones = milestones[_recipientId];

        // Check if the milestone ID is valid
        if (_milestoneId >= recipientMilestones.length) {
            revert INVALID_MILESTONE();
        }

        Milestone storage milestone = recipientMilestones[_milestoneId];

        // Ensure that the milestone has not already been accepted
        if (milestone.milestoneStatus == Status.Accepted) {
            revert MILESTONE_ALREADY_ACCEPTED();
        }

        for (uint i = 0; i < _suppliersStore.length; i++) {
            submittedvMilestones[_milestoneId].suppliersVotes[_suppliersStore[i]] = 0;
        }
        delete submittedvMilestones[_milestoneId];

        // Update the milestone metadata and status
        milestone.metadata = _metadata;
        milestone.milestoneStatus = Status.Pending;

        // Emit an event to indicate successful milestone submission
        emit MilestoneSubmitted(_recipientId, _milestoneId, _metadata);
    }


    /// @notice Reviews a submitted milestone for a specific recipient and updates its status.
    /// @dev Requires the sender to be the pool manager and wearing the supplier hat.
    ///      The recipient must be in an 'Accepted' status, and the milestone must be in a 'Pending' status.
    ///      The function updates the milestone status based on the majority vote and distributes rewards if accepted.
    ///      Emits a `MilestoneStatusChanged` event if the status changes and a `SubmittedvMilestoneReviewed` event regardless of the outcome.
    /// @param _recipientId ID of the recipient whose milestone is being reviewed.
    /// @param _milestoneId ID of the milestone being reviewed.
    /// @param _status New status to be set for the milestone (Accepted or Rejected).
    function reviewSubmitedMilestone(address _recipientId, uint256 _milestoneId, Status _status) external onlyPoolManager(msg.sender) {
        if (!hatsContract.isWearerOfHat(msg.sender, supplierHat)) {
            revert SUPPLIER_HAT_WEARING_REQUIRED();
        }

        if (submittedvMilestones[_milestoneId].suppliersVotes[msg.sender] > 0) {
            revert ALREADY_REVIEWED();
        }

        Recipient memory recipient = _recipients[_recipientId];

        if (recipient.recipientStatus != Status.Accepted) {
            revert RECIPIENT_NOT_ACCEPTED();
        }

        Milestone[] storage recipientMilestones = milestones[_recipientId];

        if (_milestoneId >= recipientMilestones.length) {
            revert INVALID_MILESTONE();
        }

        Milestone storage milestone = recipientMilestones[_milestoneId];

        if (milestone.milestoneStatus != Status.Pending) {
            revert INVALID_MILESTONE_STATUS();
        }

        uint256 managerVotingPower = _suplierPower[msg.sender];
        uint256 threshold = totalSupply * thresholdPercentage / 100;

        submittedvMilestones[_milestoneId].suppliersVotes[msg.sender] = managerVotingPower;

        if (_status == Status.Accepted) {
            submittedvMilestones[_milestoneId].votesFor += managerVotingPower;

            if (submittedvMilestones[_milestoneId].votesFor > threshold) { 
                milestone.milestoneStatus = _status;
                address[] memory recipientIds = new address[](1);
                recipientIds[0] = _recipientId;
                allo.distribute(poolId, recipientIds, "");
                emit MilestoneStatusChanged(_recipientId, _milestoneId, _status);
            }
        } else if (_status == Status.Rejected) {
            submittedvMilestones[_milestoneId].votesAgainst += managerVotingPower;

            if (submittedvMilestones[_milestoneId].votesAgainst > threshold) { 
                milestone.milestoneStatus = _status;
                for (uint i = 0; i < _suppliersStore.length; i++) {
                    submittedvMilestones[_milestoneId].suppliersVotes[_suppliersStore[i]] = 0;
                }
                delete submittedvMilestones[_milestoneId];
                emit MilestoneStatusChanged(_recipientId, _milestoneId, _status);
            }
        }

        emit SubmittedvMilestoneReviewed(_recipientId, _milestoneId, _status);
    }


    /// @notice Reviews and potentially rejects the project based on the supplied status.
    /// @dev Requires the sender to be the pool manager and wearing the supplier hat.
    ///      The function updates the project's status based on the majority vote.
    ///      If the project is rejected, it deactivates the pool and returns funds to suppliers.
    ///      Emits a `ProjectRejected` event if the project is rejected, or a `ProjectRejectDeclined` event if the rejection is declined.
    /// @param _status The proposed status for the project (either Accepted or Rejected).
    function rejectProject(Status _status) external onlyPoolManager(msg.sender) { 
        if (!hatsContract.isWearerOfHat(msg.sender, supplierHat)) {
            revert SUPPLIER_HAT_WEARING_REQUIRED();
        }

        if (_status != Status.Accepted && _status != Status.Rejected) {
            revert INVALID_STATUS();
        }

        if (projectReject.suppliersVotes[msg.sender] > 0) {
            revert ALREADY_REVIEWED();
        }

        uint256 managerVotingPower = _suplierPower[msg.sender];
        uint256 threshold = totalSupply * thresholdPercentage / 100;
        projectReject.suppliersVotes[msg.sender] = managerVotingPower;

        if (_status == Status.Accepted) {
            projectReject.votesFor += managerVotingPower;

            if (projectReject.votesFor > threshold) { 
 
                _distributeFundsBackToSuppliers();

                state = StrategyState.Rejected;
                _setPoolActive(false);

                emit ProjectRejected();
            }
        } else if (_status == Status.Rejected) {
            projectReject.votesAgainst += managerVotingPower;

            if (projectReject.votesAgainst > threshold) { 
                for (uint i = 0; i < _suppliersStore.length; i++) {
                    projectReject.suppliersVotes[_suppliersStore[i]] = 0;
                }
                delete projectReject;
                emit ProjectRejectDeclined();
            }
        }
    }

    /// @notice Distributes a 'thank you' token amount to suppliers based on their contribution percentage.
    /// @dev This function should only be called after the strategy is executed or rejected.
    ///      It calculates the distribution amount for each supplier based on their power percentage.
    ///      The function ensures that the total distributed amount matches the `_amount` sent with the transaction.
    ///      Emits a `TokenOfThanksSent` event for each supplier receiving the token.
    ///      Requires the transaction to be non-reentrant to prevent potential security vulnerabilities.
    /// @param _amount The total amount of tokens to be distributed to the suppliers.
    function sendTokenOfThanksToSuppliers(uint256 _amount) external payable nonReentrant { 
        if (_amount == 0 || _amount != msg.value) revert NOT_ENOUGH_FUNDS();

        if (state != StrategyState.Executed && state != StrategyState.Rejected) revert STRATEGY_IS_STILL_ACIVE();

        for (uint i = 0; i < _suppliersStore.length; i++) {
            uint256 percentage = _suplierPower[_suppliersStore[i]];
            uint256 amount = _amount * percentage / 1e18;
            _transferAmount(NATIVE, _suppliersStore[i], amount);

            emit TokenOfThanksSent(_suppliersStore[i], amount);
        }
    }



    /// ====================================
    /// ============ Internal ==============
    /// ====================================

    /// @notice Retrieves the status of a specific recipient.
    /// @dev Utilizes the global 'Status' defined at the protocol level.
    ///      This function is an internal view that overrides a base contract implementation.
    /// @param _recipientId The address ID of the recipient.
    /// @return Status The current status of the recipient.
    function _getRecipientStatus(address _recipientId) internal view override returns (Status) {
        return _getRecipient(_recipientId).recipientStatus;
    }

    /// @notice Distributes funds back to suppliers based on their contribution percentage.
    /// @dev Iterates through all suppliers and transfers their share of the pool amount back to them.
    ///      This function is private and is called when a project is rejected.
    function _distributeFundsBackToSuppliers() private { 
        for (uint i = 0; i < _suppliersStore.length; i++) {
            uint256 percentage = _suplierPower[_suppliersStore[i]];
            uint256 amount = poolAmount * percentage / 1e18;
            IAllo.Pool memory pool = allo.getPool(poolId);

            _transferAmount(pool.token, _suppliersStore[i], amount);
        }
    }

    /// @notice Verifies if a given address is an eligible allocator for the pool.
    /// @dev Checks if the allocator is a pool manager authorized to allocate funds.
    ///      This function is internal and overrides a base contract implementation.
    /// @param _allocator The address of the allocator to be verified.
    /// @return bool Returns 'true' if the allocator is a pool manager, otherwise 'false'.
    function _isValidAllocator(address _allocator) internal view override returns (bool) {
        return allo.isPoolManager(poolId, _allocator);
    }

    /// @notice Resets the offered milestones for a specific recipient.
    /// @dev Clears the votes and deletes the offered milestones for the recipient.
    ///      This function is internal and is used when milestones need to be reset.
    /// @param _recipientId The address ID of the recipient whose milestones are to be reset.
    function _resetOfferedMilestones(address _recipientId) internal {
        for (uint i = 0; i < _suppliersStore.length; i++) {
            offeredMilestones[_recipientId].suppliersVotes[_suppliersStore[i]] = 0;
        }
        delete offeredMilestones[_recipientId];
    }


    /// @notice Register a recipient to the pool.
    /// @dev Emits a 'Registered()' event
    /// @param _data The data to be decoded
    /// @custom:data (address recipientAddress, address registryAnchor, uint256 grantAmount, Metadata metadata)
    /// @param _sender The sender of the transaction
    /// @return recipientId The id of the recipient
    function _registerRecipient(bytes memory _data, address _sender)
        internal
        override
        onlyActivePool
        returns (address recipientId)
    {
        address recipientAddress;
        address registryAnchor;
        bool isUsingRegistryAnchor;
        uint256 grantAmount;
        Metadata memory metadata;

        /// @custom:data (address recipientAddress, address registryAnchor, uint256 grantAmount, Metadata metadata)

        (recipientAddress, registryAnchor, grantAmount, metadata) =
            abi.decode(_data, (address, address, uint256, Metadata));

        // Check if the registry anchor is valid so we know whether to use it or not
        isUsingRegistryAnchor = registryAnchor != address(0);

        // Ternerary to set the recipient id based on whether or not we are using the 'registryAnchor' or 'recipientAddress'
        recipientId = isUsingRegistryAnchor ? registryAnchor : recipientAddress;
        if (isUsingRegistryAnchor && !_isProfileMember(recipientId, _sender)) {
            revert UNAUTHORIZED();
        }

        // Check if the recipient is not already accepted, otherwise revert
        if (_recipients[recipientId].recipientStatus == Status.Accepted) {
            revert RECIPIENT_ALREADY_ACCEPTED();
        }

        // Create the recipient instance
        Recipient memory recipient = Recipient({
            recipientAddress: recipientAddress,
            useRegistryAnchor: isUsingRegistryAnchor,
            grantAmount: grantAmount,
            metadata: metadata,
            recipientStatus: Status.Accepted,
            milestonesReviewStatus: Status.Pending
        });

        // Add the recipient to the accepted recipient ids mapping
        _recipients[recipientId] = recipient;

        // Emit event for the registration
        emit Registered(recipientId, _data, _sender);
    }

    /// @notice Allocate amount to recipent for Executor Supplier Voting Strategy.
    /// @dev '_sender' must be a pool manager to allocate. Emits 'RecipientStatusChanged() and 'Allocated()' events.
    /// @param _data The data to be decoded
    /// @custom:data (address recipientId, Status recipientStatus, uint256 grantAmount)
    /// @param _sender The sender of the allocation
    function _allocate(bytes memory _data, address _sender)
        internal
        virtual
        override
        nonReentrant
    {
        require(_sender == address(this), "UNAUTHORIZED allocate");
        
        // Decode the '_data'.
        (address recipientId, Status recipientStatus, uint256 grantAmount) =
            abi.decode(_data, (address, Status, uint256));

        Recipient storage recipient = _recipients[recipientId];

        if (upcomingMilestone[recipientId] != 0) {
            revert MILESTONES_ALREADY_SET();
        }

        if (recipient.recipientStatus != Status.Accepted && recipientStatus == Status.Accepted) {
            IAllo.Pool memory pool = allo.getPool(poolId);
            allocatedGrantAmount += grantAmount;

            // Check if the allocated grant amount exceeds the pool amount and reverts if it does
            if (allocatedGrantAmount > poolAmount) {
                revert ALLOCATION_EXCEEDS_POOL_AMOUNT();
            }

            recipient.grantAmount = grantAmount;
            recipient.recipientStatus = Status.Accepted;

            // Emit event for the acceptance
            emit RecipientStatusChanged(recipientId, Status.Accepted);

            // Emit event for the allocation
            emit Allocated(recipientId, recipient.grantAmount, pool.token, _sender);
        } else if (
            recipient.recipientStatus != Status.Rejected // no need to reject twice
                && recipientStatus == Status.Rejected
        ) {
            recipient.recipientStatus = Status.Rejected;

            // Emit event for the rejection
            emit RecipientStatusChanged(recipientId, Status.Rejected);
        }
    }

    /// @notice Distribute the upcoming milestone to recipients.
    /// @dev '_sender' must be this strategy to distribute.
    /// @param _recipientIds The recipient ids of the distribution
    /// @param _sender The sender of the distribution
    function _distribute(address[] memory _recipientIds, bytes memory, address _sender)
        internal
        virtual
        override
    {
        require(_sender == address(this), "UNAUTHORIZED distribute");

        uint256 recipientLength = _recipientIds.length;
        for (uint256 i; i < recipientLength;) {
            _distributeUpcomingMilestone(_recipientIds[i], _sender);
            unchecked {
                i++;
            }
        }
    }

    /// @notice Distribute the upcoming milestone.
    /// @dev Emits 'MilestoneStatusChanged() and 'Distributed()' events.
    /// @param _recipientId The recipient of the distribution
    /// @param _sender The sender of the distribution
    function _distributeUpcomingMilestone(address _recipientId, address _sender) private {
        uint256 milestoneToBeDistributed = upcomingMilestone[_recipientId];
        Milestone[] storage recipientMilestones = milestones[_recipientId];

        Recipient memory recipient = _recipients[_recipientId];
        Milestone storage milestone = recipientMilestones[milestoneToBeDistributed];

        // check if milestone is not rejected or already paid out
        if (milestoneToBeDistributed > recipientMilestones.length) {
            revert INVALID_MILESTONE();
        }

        if (milestone.milestoneStatus != Status.Accepted) {
            revert INVALID_MILESTONE_STATUS();
        }

        // Calculate the amount to be distributed for the milestone
        uint256 amount = recipient.grantAmount * milestone.amountPercentage / 1e18;

        // Get the pool, subtract the amount and transfer to the recipient
        IAllo.Pool memory pool = allo.getPool(poolId);

        poolAmount -= amount;
        _transferAmount(pool.token, recipient.recipientAddress, amount);

        // Increment the upcoming milestone
        upcomingMilestone[_recipientId]++;

        if (upcomingMilestone[_recipientId] >= recipientMilestones.length) {
            state = StrategyState.Executed;
            _setPoolActive(false);
        }

        // Emit events for the distribution
        emit Distributed(_recipientId, recipient.recipientAddress, amount, _sender);
    }

    /// @notice Check if sender is a profile owner or member.
    /// @param _anchor Anchor of the profile
    /// @param _sender The sender of the transaction
    /// @return 'true' if the sender is the owner or member of the profile, otherwise 'false'
    function _isProfileMember(address _anchor, address _sender) internal view returns (bool) {
        IRegistry.Profile memory profile = _registry.getProfileByAnchor(_anchor);
        return _registry.isOwnerOrMemberOfProfile(profile.id, _sender);
    }

    /// @notice Get the recipient.
    /// @param _recipientId ID of the recipient
    /// @return recipient Returns the recipient information
    function _getRecipient(address _recipientId) internal view returns (Recipient memory recipient) {
        recipient = _recipients[_recipientId];
    }

    /// @notice Get the payout summary for the accepted recipient.
    /// @return Returns the payout summary for the accepted recipient

    
    function _getPayout(address _recipientId, bytes memory) internal view override returns (PayoutSummary memory) {
        Recipient memory recipient = _getRecipient(_recipientId);
        return PayoutSummary(recipient.recipientAddress, recipient.grantAmount);
    }

    /// @notice Set the milestones for the recipient.
    /// @param _recipientId ID of the recipient
    /// @param _milestones The milestones to be set
    function _setMilestones(address _recipientId, Milestone[] memory _milestones) internal {
        uint256 totalAmountPercentage;

        // Clear out the milestones and reset the index to 0
        if (milestones[_recipientId].length > 0) {
            delete milestones[_recipientId];
        }

        uint256 milestonesLength = _milestones.length;

        // Loop through the milestones and set them
        for (uint256 i; i < milestonesLength;) {
            Milestone memory milestone = _milestones[i];

            // Reverts if the milestone status is 'None'
            if (milestone.milestoneStatus != Status.None) {
                revert INVALID_MILESTONE_STATUS();
            }

            // TODO: I see we check on line 649, but it seems we need to check when added it is NOT greater than 100%?
            // Add the milestone percentage amount to the total percentage amount
            totalAmountPercentage += milestone.amountPercentage;

            // Add the milestone to the recipient's milestones
            milestones[_recipientId].push(milestone);

            unchecked {
                i++;
            }
        }

        if (totalAmountPercentage != 1e18) {
            revert INVALID_MILESTONES_PERCENTAGE();
        }

        bytes memory encodedAllocateParams = abi.encode(
            _recipientId,
            Status.Accepted,
            totalSupply
        );

        allo.allocate(poolId, encodedAllocateParams);

        emit MilestonesSet(_recipientId, milestonesLength);
    }

    /// @notice This contract should be able to receive native token
    receive() external payable {}
}
