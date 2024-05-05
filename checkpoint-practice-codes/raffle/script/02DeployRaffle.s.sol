// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
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

        if(subscriptionId == 0) { // if we do not have a subscription, create one and fund it
            // Create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator
            );

            // Fund it
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator, 
                subscriptionId, 
                link
            );
        }

        vm.startBroadcast(); //brand new raffle
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane, // key hash
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadCast();

        AddConsumer addConsumer = new AddConsumer(); //add raffle to list of consumers
        addConsumer.addConsumer(
            address(raffle), 
            vrfCoordinator, 
            subscriptionId
        );
        return (raffle, helperConfig);
    }
}