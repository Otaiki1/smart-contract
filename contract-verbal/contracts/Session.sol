// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Sessions {
    using Counters for Counters.Counter;

    Counters.Counter private _sessionID;

    struct Session {
        address mentor;
        address student;
        bool isAccepted;
        uint256 timeStamp;
        string meetingLink;
        uint256 paymentFee;
    }

    event SessionScheduled(
        address indexed mentor,
        address indexed student,
        uint256 fee,
        string meetingLink,
        uint256 indexed id
    );
    event SessionCancelled(uint256 indexed sessionId);
    event SessionAccepted(uint256 indexed sessionId);

    Session[] public allSessions;
    mapping(address => Session[]) public addressToSessions;
    mapping(uint256 => Session) public uintToSession;

    modifier isTimeFrameAlreadyTaken(uint256 _timeStamp) {
        require(!isTimeFrameTaken(_timeStamp), "Timeframe is already taken");
        _;
    }

    function isTimeFrameTaken(uint256 _timeStamp) public view returns (bool) {
        for (uint256 i = 0; i < allSessions.length; i++) {
            if (allSessions[i].timeStamp == _timeStamp) {
                return true;
            }
        }
        return false;
    }

    function scheduleASession(
        address _mentor,
        uint256 _timestamp,
        string memory _meetingLink
    ) external isTimeFrameAlreadyTaken(_timestamp) {
        uint256 id = _sessionID.current();
        Session storage newSession = uintToSession[id];
        newSession.mentor = _mentor;
        newSession.student = msg.sender;
        newSession.meetingLink = _meetingLink;
        newSession.timeStamp = _timestamp;
        allSessions.push(newSession);
        addressToSessions[msg.sender].push(newSession);
        _sessionID.increment();

        emit SessionScheduled(_mentor, msg.sender, newSession.paymentFee, _meetingLink, id);
    }

    function cancelSession(uint256 _sessionId) external {
        Session storage session = uintToSession[_sessionId];
        require(session.student == msg.sender, "You are not the student of this session");
        session.isAccepted = false;
        emit SessionCancelled(_sessionId);
    }

    function acceptSession(uint256 _sessionId) external {
        Session storage session = uintToSession[_sessionId];
        require(session.mentor == msg.sender, "You are not the mentor of this session");
        session.isAccepted = true;
        emit SessionAccepted(_sessionId);
    }
}
