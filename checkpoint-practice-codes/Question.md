### Raffle.sol

Given the following Solidity code snippet, implement the `Raffle` contract with various functions to manage a raffle system. Use the hints provided to guide you through writing each line of code.

1. **Implement the `constructor` function**: This function initializes the raffle with an entrance fee, interval, VRF coordinator details, and other necessary parameters. Use the constructor to set up the initial state of the raffle.

2. **Implement the `enterRaffle` function**: Write a function that allows users to enter the raffle by sending the required entrance fee. Use this function to manage the raffle's participants and ensure that only those who meet the entrance fee requirement can participate.

3. **Implement the `pickWinner` function**: Write a function that requests a random number from the Chainlink VRF and sets the raffle state to `CALCULATING`. Use this function to initiate the process of selecting a winner once the raffle interval has passed.

4. **Implement the `fulfillRandomWords` function**: Write a function that is called by the Chainlink VRF when the random number is ready. This function should pick a winner based on the random number, reset the raffle state to `OPEN`, and transfer the contract's balance to the winner. Use this function to finalize the raffle and distribute the prize.

5. **Implement the `getEntranceFee` function**: Write a getter function that returns the entrance fee for the raffle. Use this function to provide transparency about the cost of entering the raffle.

**Hints**:
- Use the `VRFConsumerBaseV2` contract to interact with the Chainlink VRF. This is necessary for generating random numbers for the raffle.
- Ensure that the `enterRaffle` function checks for the correct entrance fee and raffle state. This is crucial for preventing unauthorized entries and ensuring that the raffle is only open when it should be.
- The `pickWinner` function should request a random number from the Chainlink VRF. This step is essential for the raffle's fairness and randomness.
- The `fulfillRandomWords` function should be marked as `internal` and `override` to correctly handle the callback from the Chainlink VRF. This is necessary for the contract to receive and process the random number.
- Use events to log when a player enters the raffle and when a winner is picked. This is important for tracking the raffle's activity and ensuring transparency.

## DeployRaffle.s.sol

### Challenge: Deploying a Raffle Contract in Solidity

In this challenge, you're tasked with creating a Solidity contract that deploys a raffle. The contract should be able to create a subscription if one doesn't already exist, fund the subscription, and then deploy a new raffle contract. Finally, it should add the raffle to a list of consumers.

#### Hints:

1. **Contract Structure**: Your contract should inherit from a `Script` contract. This is a common pattern in Solidity for contracts that perform actions rather than store data.

2. **Helper Configuration**: You'll need to interact with a `HelperConfig` contract to get the necessary configuration for the raffle, such as the entrance fee, interval, VRF coordinator address, gas lane, subscription ID, callback gas limit, and LINK token address.

3. **Subscription Management**: If a subscription ID is not provided, your contract should create a new subscription using a `CreateSubscription` contract and then fund it using a `FundSubscription` contract.

4. **Raffle Deployment**: Once the subscription is ready, deploy a new `Raffle` contract with the configuration obtained from the `HelperConfig`.

5. **Adding to Consumers**: After deploying the raffle, add it to a list of consumers using an `AddConsumer` contract.

6. **Return Values**: Your `run` function should return the newly created `Raffle` contract and the `HelperConfig` contract.

#### Task:

Create a Solidity contract named `DeployRaffle` that inherits from a `Script` contract. Implement the `run` function to perform the following steps:

- Retrieve the necessary configuration from a `HelperConfig` contract.
- If a subscription ID is not provided, create and fund a new subscription.
- Deploy a new `Raffle` contract with the retrieved configuration.
- Add the newly created raffle to a list of consumers.
- Return the `Raffle` contract and the `HelperConfig` contract.

**Note**: Ensure you handle the creation and funding of subscriptions correctly, and that you manage the deployment and addition of the raffle to consumers as described.

## HelperConfig.s.sol

### Challenge: Configuring a Helper for Deploying Raffles

In this challenge, you're tasked with creating a Solidity contract named `HelperConfig` that inherits from a `Script` contract. This contract should be responsible for providing network configuration for deploying raffles, including setting up mock contracts for testing purposes.

#### Hints:

1. **Network Configuration**: Define a struct `NetworkConfig` that holds various configuration parameters such as entrance fee, interval, VRF coordinator address, gas lane, subscription ID, callback gas limit, and LINK token address.

2. **Constructor Logic**: In the constructor, determine the network configuration based on the current blockchain ID. For a specific blockchain ID (e.g., 11155111), use a predefined configuration. Otherwise, create or retrieve a configuration suitable for a local Anvil chain.

3. **Predefined Configuration**: Implement a function `getSepoliaEthConfig` that returns a `NetworkConfig` with predefined values suitable for the Sepolia test network.

4. **Local Configuration**: Implement a function `getOrCreateAnvilEthConfig` that checks if a VRF coordinator address is already set. If not, it deploys mock contracts for the VRF coordinator and LINK token, and then returns a `NetworkConfig` with these mock contracts' addresses.

5. **Mock Deployment**: Use `vm.startBroadcast()` and `vm.stopBroadcast()` to indicate the start and end of the mock contract deployment process.

#### Task:

Create a Solidity contract named `HelperConfig` that inherits from a `Script` contract. Implement the following:

- Define a struct `NetworkConfig` with the necessary fields.
- In the constructor, set the `activeNetworkConfig` based on the current blockchain ID.
- Implement `getSepoliaEthConfig` to return a predefined `NetworkConfig` for the Sepolia test network.
- Implement `getOrCreateAnvilEthConfig` to deploy mock contracts for the VRF coordinator and LINK token if necessary, and return a `NetworkConfig` with these mock contracts' addresses.

**Note**: Ensure your contract correctly handles the deployment of mock contracts and the selection of network configurations based on the blockchain ID.

## RaffleTest.t.sol

### Question for a New Learner

Given the following Solidity code snippet, implement the `RaffleTest` contract with various functions to test the functionality of a raffle system.

1. **Implement the `setUp` function**: This function should initialize the test environment by deploying a new `DeployRaffle` contract, retrieving the `Raffle` and `HelperConfig` contracts, and setting up the necessary configuration parameters. Also, allocate an initial balance to the `PLAYER` address.

2. **Implement the `testRaffleInitializesInOpenState` function**: Write a test function to verify that the raffle is initialized in an `OPEN` state. Use the `assert` function to check the current state of the raffle.

3. **Implement the `testRaffleRevertsWhenYouDontPayEnough` function**: Write a test function to ensure that the raffle reverts if a player tries to enter without paying the required entrance fee. Use `vm.expectRevert` to expect a revert condition.

4. **Implement the `testRaffleRecordsPlayerWhenTheyEnter` function**: Write a test function to verify that the raffle records a player's address when they enter the raffle with the correct entrance fee. Use the `assert` function to check the recorded player's address.

5. **Implement the `testEmitsEventOnEntrance` function**: Write a test function to ensure that the raffle emits an event when a player enters. Use `vm.expectEmit` to expect the emission of the `RaffleEnter` event.

6. **Implement the `testCantEnterWhenRaffleIsCalculating` function**: Write a test function to verify that players cannot enter the raffle while it is in the process of calculating the winner. Use `vm.expectRevert` to expect a revert condition when attempting to enter during this time.

**Hints**:
- Use the `new` keyword to deploy the `DeployRaffle` contract and retrieve the `Raffle` and `HelperConfig` contracts.
- Use `vm.deal` to allocate an initial balance to the `PLAYER` address.
- Use `assert` to check the state of the raffle and the recorded player's address.
- Use `vm.expectRevert` to expect a revert condition when a player tries to enter without paying enough or when the raffle is not open.
- Use `vm.expectEmit` to expect the emission of the `RaffleEnter` event when a player enters the raffle.
- Use `vm.warp` and `vm.roll` to simulate the passage of time and the mining of a new block, respectively.

## Interactions.s.sol

### Question for a New Learner

Given the provided Solidity code snippet, implement the `CreateSubscription`, `FundSubscription`, and `AddConsumer` contracts with various functions to test the functionality of a VRF v2 subscription system.

1. **Implement the `createSubscriptionUsingConfig` function**: This function should create a new subscription using the `HelperConfig` contract to retrieve the necessary configuration parameters. Use the `console.log` function to log the chain ID and the subscription ID.

2. **Implement the `createSubscription` function**: Write a function to create a new subscription by calling the `createSubscription` function of the `VRFCoordinatorV2Mock` contract. Use `vm.startBroadcast` and `vm.stopBroadcast` to simulate the creation of the subscription.

3. **Implement the `fundSubscriptionUsingConfig` function**: This function should fund the subscription using the `HelperConfig` contract to retrieve the necessary configuration parameters. Use the `console.log` function to log the subscription ID, the VRF coordinator address, and the chain ID.

4. **Implement the `fundSubscription` function**: Write a function to fund the subscription by calling the `fundSubscription` function of the `VRFCoordinatorV2Mock` contract for local chains or the `transferAndCall` function of the `LinkToken` contract for other chains. Use `vm.startBroadcast` and `vm.stopBroadcast` to simulate the funding process.

5. **Implement the `addConsumerUsingConfig` function**: This function should add a consumer to the subscription using the `HelperConfig` contract to retrieve the necessary configuration parameters. Use the `console.log` function to log the consumer address, the VRF coordinator address, and the chain ID.

6. **Implement the `addConsumer` function**: Write a function to add a consumer to the subscription by calling the `addConsumer` function of the `VRFCoordinatorV2Mock` contract. Use `vm.startBroadcast` and `vm.stopBroadcast` to simulate the addition of the consumer.

**Hints**:
- Use the `new` keyword to create instances of the `HelperConfig` contract.
- Use `console.log` to log important information for debugging purposes.
- Use `vm.startBroadcast` and `vm.stopBroadcast` to simulate the execution of transactions.
- For local chains, directly call the `fundSubscription` function of the `VRFCoordinatorV2Mock` contract. For other chains, use the `transferAndCall` function of the `LinkToken` contract to fund the subscription.
- Ensure that the `run` functions in each contract call the appropriate setup functions to test the entire flow of creating, funding, and adding a consumer to a VRF v2 subscription.

