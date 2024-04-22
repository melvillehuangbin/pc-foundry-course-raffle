// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64, address) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , , , ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2, deployerKey);
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

    function run() external returns (uint64, address) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Sript {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , , uint64 subscriptionId, ) = helperConfig.activeNetworkConfig();
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}