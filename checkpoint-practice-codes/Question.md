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


Given the following Solidity code snippet, implement the `DeployRaffle` contract with various functions to manage a raffle deployment system.

1. **Implement the `run` function**: This function should create a new instance of the `HelperConfig` contract, retrieve the necessary configuration parameters (entrance fee, interval, VRF coordinator, gas lane, subscription ID, and callback gas limit) using the `activeNetworkConfig` function, and then deploy a new `Raffle` contract with these parameters. Ensure that the deployment process is broadcasted and stopped correctly.

**Hints**:
- Use the `new` keyword to create a new instance of the `HelperConfig` contract.
- Retrieve the configuration parameters from the `HelperConfig` contract using the `activeNetworkConfig` function.
- Deploy a new `Raffle` contract with the retrieved configuration parameters.
- Use `vm.startBroadcast()` and `vm.stopBroadcast()` to manage the broadcasting of the deployment process.
- Return the newly created `Raffle` contract instance from the `run` function.

**Reference**: [Source 0](https://dev.to/daltonic/raffle-draws-on-the-ethereum-blockchain-a-beginners-guide-29o2)

## HelperConfig.s.sol

Given the following Solidity code snippet, implement the `HelperConfig` contract with various functions to manage network configuration for a raffle system.

1. **Implement the `constructor` function**: This function should initialize the `activeNetworkConfig` based on the current blockchain ID. Use conditional logic to determine whether to use Sepolia or Anvil configuration.

2. **Implement the `getSepoliaEthConfig` function**: Write a function that returns a `NetworkConfig` struct with predefined values suitable for the Sepolia network. Ensure that the function is marked as `pure` since it does not modify the state.

3. **Implement the `getOrCreateAnvilEthConfig` function**: Write a function that checks if the `vrfCoordinator` address is already set. If not, it should deploy a mock VRF coordinator contract using the `VRFCoordinatorV2Mock` contract and return a `NetworkConfig` struct with the mock coordinator's address and other necessary parameters. Ensure that the deployment process is broadcasted and stopped correctly.

**Hints**:
- Use the `block.chainid` to determine the current network and initialize the `activeNetworkConfig` accordingly.
- The `getSepoliaEthConfig` function should return a `NetworkConfig` struct with hardcoded values for the Sepolia network.
- The `getOrCreateAnvilEthConfig` function should check if the `vrfCoordinator` address is already set. If not, deploy a mock VRF coordinator contract and update the `activeNetworkConfig` with the new mock coordinator's address.
- Use `vm.startBroadcast()` and `vm.stopBroadcast()` to manage the broadcasting of the deployment process.
- Ensure that the `getOrCreateAnvilEthConfig` function returns a `NetworkConfig` struct with the updated configuration.

**Reference**: [Source 0](https://docs.chain.link/docs/vrf-best-practices/)
