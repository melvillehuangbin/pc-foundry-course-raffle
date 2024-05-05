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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2 {

    error Raffle__NotEntered();
    error Raffle__RaffleNotOpened();
    error Raffle__WinnerNotPicked();
    error Raffle__TransferFailed();

    
    uint16 private constant MINIMUM_REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // set immutable on state variables that you only want to be read only and assignable only once, typically in the constructor
    uint256 private immutable i_entranceFee;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subId;
    uint32 private immutable i_callBackGasLimit;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address payable private s_recentWinner;
    RaffleState private s_raffleState;

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    event RaffleEnter(address indexed player);
    event PickedWinner(address indexed winner);

    constructor (
        uint256 entranceFee,
        uint256 interval,
        bytes32 gasLane,
        uint64 subId,
        uint32 callBackGasLimit,
        address vrfCoordinator
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_gasLane = gasLane;
        i_subId = subId;
        i_callBackGasLimit = callBackGasLimit;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEntered();
        }

        // dont allow user to enter if raffle is not open
        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpened();
        }

        // keep track of all players who entered raffle
        s_players.push(payable(msg.sender));

        // emit a Raffle enter event
        emit RaffleEnter(msg.sender);
    }

    // 1. Get a random number
    // 2. Use the random number to pick a player
    // 3. Be automatically called

    function pickWinner() external {

        // check that enough time has pass before picking winner
        if(block.timestamp - s_lastTimeStamp < i_interval) {
            revert Raffle__WinnerNotPicked();
        }
        // set raffle state to CALCULATING
        s_raffleState = RaffleState.CALCULATING;

        // request random number from chainlink VRF
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            MINIMUM_REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {

        // pick winner base on random number
        uint256 winnerIndex = randomWords[0] % s_players.length; // get a random index base on randomWords modulo by player length
        address payable winner = s_players[winnerIndex]; // set winner using winnerIndex. This winner should be able to receive ETH (his winnings)
        s_recentWinner = winner; // set recent winner to the latest winner
        s_raffleState = RaffleState.OPEN; // set raffle state to open after theres a new winner
        s_players = new address payable[](0); // reset player list
        s_lastTimeStamp = block.timestamp; // set time stamp to latest timestamp
        emit PickedWinner(winner); // emit winner


        // sender winnings to winner and check if transaction is succesful
        (bool success, ) = s_recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransferFailed();
        }
    }

    /** Getter Function **/
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

}