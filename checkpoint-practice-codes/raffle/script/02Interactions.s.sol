// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64, address) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , , , , ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2);
    }

    function createSubscription(
        address vrfCoordinatorV2
    ) public returns (uint64, address) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinatorV2).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return (subId, vrfCoordinatorV2);
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Sript {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinatorV2,
            ,
            ,
            uint64 subscriptionId,
            ,
            address link
         ) = helperConfig.activeNetworkConfig();
         fundSubscription(vrfCoordinator, subId, link);
    }

    function fundSubscription(address vrfCoordinator, uint64 subId, address link) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == 31337) { // local chain
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadCast();
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinator, 
                FUND_AMOUNT, 
                abi.encode(subId)
            );
            vm.stopBroadCast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {

    function addConsumer(
        address raffle,
        address vrfCoordinator,
        uint64 subId
    ) public {
        console.log("Adding consumer contract: ", raffle);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, raffle);
        vm.stopBroadCast();
    }

    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinatorV2,
            ,
            ,
            uint64 subscriptionId,
            ,
         ) = helperConfig.activeNetworkConfig();
         addConsumer(raffle, vrfCoordinator, subId);
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle", 
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}