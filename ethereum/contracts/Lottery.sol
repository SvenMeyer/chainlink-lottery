pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

import {randomness_interface} from "./interfaces/randomness_interface.sol";
import {governance_interface} from "./interfaces/governance_interface.sol";

contract Lottery is ChainlinkClient {

    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER }
    LOTTERY_STATE public lottery_state;
    uint256 public lotteryId;
    address payable[] public players;
    governance_interface public governance;

    // .01 ETH
    uint256 public MINIMUM          = 1000000000000000;

    // Alarm stuff
    address alarmOracleAddress; // CHAINLINK_ALARM_ORACLE = 0xc99B3D447826532722E41bc36e644ba3479E4365;
    bytes32 alarmJobID;         // CHAINLINK_ALARM_JOB_ID = "2ebb1c1a4b1e4229adac24ee0b5f784f";
    uint256 public alarmFee;    // ORACLE_PAYMENT = 100000000000000000;  // 0.1 LINK

    constructor(address _governance, address _link, address _alarmOracleAddress, bytes32 _alarmJobID, uint256 _alarmFee) public
    {
        governance = governance_interface(_governance);

        if (_link == address(0)) {
            setPublicChainlinkToken();
        }
        else {
            setChainlinkToken(_link);
        }

        alarmOracleAddress = _alarmOracleAddress;
        alarmJobID = _alarmJobID;
        alarmFee   = _alarmFee;

        lotteryId = 1;
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        assert(msg.value == MINIMUM);
        assert(lottery_state == LOTTERY_STATE.OPEN);
        players.push(msg.sender);
    }

    function start_new_lottery(uint256 duration) public {
        require(lottery_state == LOTTERY_STATE.CLOSED, "can't start a new lottery yet");
        lottery_state = LOTTERY_STATE.OPEN;
        Chainlink.Request memory req = buildChainlinkRequest(alarmJobID, address(this), this.fulfill_alarm.selector);
        // req.addUint("until", now + duration);    // Solidity >= 0.7.0 depricated
        req.addUint("until", block.timestamp + duration);
        sendChainlinkRequestTo(alarmOracleAddress, req, alarmFee);
    }

    function fulfill_alarm(bytes32 _requestId)
        public
        recordChainlinkFulfillment(_requestId)
        {
        require(lottery_state == LOTTERY_STATE.OPEN, "The lottery hasn't even started!");
        // add a require here so that only the oracle contract can
        // call the fulfill alarm method
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        lotteryId = lotteryId + 1;
        pickWinner();
    }


    function pickWinner() private {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't at that stage yet!");
        randomness_interface(governance.randomness()).getRandom(lotteryId, lotteryId);
        //this kicks off the request and returns through fulfill_random
    }

    function fulfill_random(uint256 randomness) external {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't at that stage yet!");
        require(randomness > 0, "random-not-found");
        // assert(msg.sender == governance.randomness());
        uint256 index = randomness % players.length;
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        // You could have this run forever
        // start_new_lottery();
        // or with a cron job from a chainlink node would allow you to
        // keep calling "start_new_lottery" as well
    }

    function get_players() public view returns (address payable[] memory) {
        return players;
    }

    function get_pot() public view returns(uint256){
        return address(this).balance;
    }
}
