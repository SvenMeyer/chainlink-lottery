pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

import {lottery_interface}    from "./interfaces/lottery_interface.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";

contract RandomNumberConsumer is VRFConsumerBase {

    bytes32 internal keyHash;
    uint256 internal fee;
    mapping (uint => uint) public randomNumber;
    mapping (bytes32 => uint) public requestIds;
    governance_interface public governance;
    uint256 public most_recent_random;

    /**
      * @notice Constructor inherits VRFConsumerBase
      * @notice https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/VRFConsumerBase.sol
      * @dev    constuctor(<other arguments>, address _vrfCoordinator, address _link)
      * @dev        VRFConsumerBase(_vrfCoordinator, _link) public {
      * @dev        <initialization with other arguments goes here>
      * @dev    }
    */
    constructor(address _governance, bytes32 _keyHash, uint256 _fee, address _vrfCoordinator, address _link)
    VRFConsumerBase(_vrfCoordinator, _link) public {
        keyHash = _keyHash;
        fee     = _fee;
        governance = governance_interface(_governance);
    }

    /**
     * Requests randomness from a user-provided seed
     */
    function getRandom(uint256 userProvidedSeed, uint256 lotteryId) public {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        bytes32 _requestId = requestRandomness(keyHash, fee, userProvidedSeed);
        requestIds[_requestId] = lotteryId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        require(msg.sender == vrfCoordinator, "Fulillment only permitted by Coordinator");
        most_recent_random = randomness;
        uint lotteryId = requestIds[requestId];
        randomNumber[lotteryId] = randomness;
        lottery_interface(governance.lottery()).fulfill_random(randomness);
    }
}
