# Set Up

1. run `forge init`
2. come up with a blue pring of what we are trying to do
    - create a `README`

# Solidity Code Layout

1. Follow solidity layout best practices

# Custom Errors

1. More gas efficient way to send errors [Link](https://soliditylang.org/blog/2021/04/21/custom-errors/)
2. replace this with `require` as they are more cost efficient
3. name error with prefix of the `ContractName` (i.e. ContractName_XX)

# Events
1. need `payable()` method to make sure address can receive ETH
2. emit Event whenever we make a storage as a rule of thumb
    1. Makes migration easier
    2. Makes front end "Indexing" easier
3. They are basically pieces of information that you use to tell that something happened in your smart contract
    - For example, A contract with an event can tell another contract to "listen" to the event emitted which means something happened and that can be use as a condition to do something in the other contract
    - wide range of use cases
    - Events are stored in the logging data sructure of an EVM and not stored in "storage" similar to state variables
4. we can emit `indexed` or non `indexed` parameters
    - we can have up to 3 indexed parameters in an event
    - `indexed` parameters = topics
    - `indexed` parameters are easier to search for and queried than non `indexed` parameters

# Checks, Effects, Interactions

- **IMPORTANT** design pattern
- Checks - do your checks first 
- Effects - Your own contract
- Interactions - With other contracts

# Summary of RafflV2.sol
1. We have a raffle contract that is going to use Chainlink `VRFConsumerBaseV2` abstract contract to get a random number
2. `enterRaffle()` function
    - makes sure people buy their tickets into the raffle
    - adds players into array
3. after enough time has past and enough people have entered the raffle, `checkUpkeep()` gets called
4. once enough players join and time has past `performUpkeep()` will be called
    - this will kick off a request to the chainlink VRF
    - after a couple of blocks, 
5. reset all players once `fulfillRandomWords()` is called
    - function will pick a winner and send ETH to the winner

# Tests

1. Write some deploy scripts
2. Write our tests
    1. Work on a local chain
    2. Forked Testnet
    3. Forked Mainnet