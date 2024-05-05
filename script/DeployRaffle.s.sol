// SPDX-License-Identifier

pragma solidity ^0.8.19;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {

    function run() external returns(Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane, // key hash
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.activeNetworkConfig();

        // if subscriptionId not provided, create and fund a new subscription
        if(subscriptionId == 0) {
            // Create new subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator);

            // Fund new subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, link);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane, // key hash
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        // Add newly created raffle to a list of consumers
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinator, subscriptionId, address(raffle));

        return (raffle, helperConfig);
    }
}