// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/*
  *@description Checkpoint at 4h 20mins of Patrick Collins Solidity Course
  *@description https://youtu.be/sas02qSFZ74?feature=shared&t=15565
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit

/* This are basically the libraries required that helps to generate random values*/
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";


contract Raffle is VRFConsumerBaseV2 {

    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers, 
        uint256 raffleState
    );

    /* Type declarations */
    enum RaffleState {
        OPEN,       // 0
        CALCULATING // 1
    }

    /** State Variables **/
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    address private s_recentWinner;
    uint256 private s_lastTimeStamp;
    RaffleState private s_raffleState;

    event RaffleEnter(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane, // key hash
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not enough value sent");
        // require(s_raffleState == RaffleState.OPEN, "Raffle is not open");
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if (s_raffleState != RaffleState.OPEN) { // can only enter the raffle if raffle is not open
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        // Emit an event when we update a dynamic array or mapping
        // Named events with the function name reversed
        emit RaffleEnter(msg.sender);
    }

    /** 
      *@dev This is the function that the Chainlink Automation nodes call
      * to see if it's time to perform an upkeep
      * The following should be true for this to return true:
      * 1. The time interval has passed between raffle runs
      * 2. The raffle is in the OPEN state
      * 3. The contract has ETH (aka, players)
      * 4. (Implicit) The subscription is funded with LINK
    */

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    // 1. Get a random number
    // 2. Use the random number to pick a player
    // 3. Be automatically called
    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if(!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        // Get a random winner
        // 1. Request the RNG from chainlink
        // 2. Get the random number
        i_vrfCoordinator.requestRandomWords( // COORDINATOR: address to chainlink VRF. Different from chain to chain
            i_gasLane, // gas lane
            i_subscriptionId, // id of subscription contract you have funded on chainlink
            REQUEST_CONFIRMATIONS, // number of block confirmations
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override { /* override is required as fulfillRandomWords is a virtual function -> any contract that inheirts from the contract containing the virtual function can provide its own implementation of the function */
        // s_players = 10
        // rng = 10
        // 12 % 10 = 2
        // 1231221234121242 % 10 = 2

        // Checks 
        // Effects (Our own contract)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit PickedWinner(winner);

        // Interactions (Other contrats)
        (bool success, ) = s_recentWinner.call{value:address(this).balance}("");
        if(!success) {
            revert Raffle__TransferFailed();
        }

    }

    /**  Getter Function **/

    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
}