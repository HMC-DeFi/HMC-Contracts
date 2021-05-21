// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "./lib/BEP20.sol";

/**
 * @title HMCLock
 * @dev Lock tokens for the given time.
 * You must first deposit your tokens in the contract before the lockup.
 * Only the owner of this contract will be able to withdraw at the end period.
 */
contract HMCLock {
    uint256 _date;
    uint256 _lockTime;
    address _owner;

    constructor() public {
        _owner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == _owner, "You must be the owner");
        _;
    }

    event received(address, uint256);
    event withdraw(address tokenContract, address to, uint256 amount);

    /**
     * @dev Start the Lock of the contract
     * @param date Date
     */
    function StartLock(uint256 date) external isOwner {
        _date = now;
        _lockTime = _date + date;
    }

    /**
     * @dev Send Tokens to the owner of this contract at the end lock period
     */
    function WithdrawTokens(address tokenContract) external isOwner {
        require(now >= _lockTime, "The contract is locked");
        BEP20 token = BEP20(tokenContract);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_owner, balance);
        emit withdraw(tokenContract, msg.sender, balance);
    }

    /**
     * @dev Payable contract - HMC Tokens
     */
    receive() external payable {
        emit received(msg.sender, msg.value);
    }

    /**
     * @dev Return Start lock up date
     * @return uint256 date
     */
    function StartDateLock() public view returns (uint256) {
        return _date;
    }

    /**
     * @dev Return Current date
     * @return uint256 date
     */
    function Date() public view returns (uint256) {
        return now;
    }

    /**
     * @dev Return the end of LockTime
     * @return uint256 LockTime
     */
    function LockEndTime() public view returns (uint256) {
        return _lockTime;
    }

    /**
     * @dev Return Owner address
     * @return address owner
     */
    function Owner() public view returns (address) {
        return _owner;
    }
}
