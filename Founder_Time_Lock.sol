// SPDX-License-Identifier: MIT

// Author: MemoryMix
// Twitter: https://twitter.com/_MemoryMix_
// For info memorymix@uerii.com

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private immutable _token;

    // beneficiary of tokens after they are released
    address private immutable _beneficiary1;
    address private immutable _beneficiary2;
    address private immutable _beneficiary3;
    address private immutable _beneficiary4;

    // timestamp when token release is enabled
    uint256 private immutable _releaseTime;

    /**
     * @dev Deploys a timelock instance that is able to hold the token specified, and will only release it to
     * `beneficiary_` when {release} is invoked after `releaseTime_`. The release time is specified as a Unix timestamp
     * (in seconds).
     */
    constructor(
        IERC20 token_,
        address beneficiary1_,
        address beneficiary2_,
        address beneficiary3_,
        address beneficiary4_,
        uint256 releaseTime_
    ) {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
         _beneficiary1 = beneficiary1_;
        _beneficiary2 = beneficiary2_;
        _beneficiary3 = beneficiary3_;
        _beneficiary4 = beneficiary4_;
        _releaseTime = releaseTime_;
    }

    /**
     * @dev Returns the token being held.
     */
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    /**
     * @dev Returns the beneficiary that will receive the tokens.
     */
    function beneficiary1() public view virtual returns (address) {
        return _beneficiary1;
    }

    function beneficiary2() public view virtual returns (address) {
        return _beneficiary2;
    }

    function beneficiary3() public view virtual returns (address) {
        return _beneficiary3;
    }

    function beneficiary4() public view virtual returns (address) {
        return _beneficiary4;
    }

    /**
     * @dev Returns the time when the tokens are released in seconds since Unix epoch (i.e. Unix timestamp).
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    /**
     * @dev Transfers tokens held by the timelock to the beneficiary. Will only succeed if invoked after the release
     * time.
     */
    function release() public virtual {
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        // 64M x 250 = 16 Trillion

        uint256 trasferstep = 64000000 * 1000000000 * 1000000000;

        // second in 30 days 2.592.000 
        uint256 periodstep = 86400 * 30;

        // 12 feb 2045
        uint256 finaltime = 2370514913;

        uint256 timediff = finaltime - block.timestamp;

        uint256 slotdiff = timediff / periodstep;

        // start 250 .. 249 .. 248 .. every 30 days 

        uint256 availablestep = amount / trasferstep;

        require(availablestep > slotdiff, "TokenTimelock: slot not yet available");

        uint256 amountsingle = trasferstep / 4;

        token().safeTransfer(beneficiary1(), amountsingle);
        token().safeTransfer(beneficiary2(), amountsingle);
        token().safeTransfer(beneficiary3(), amountsingle);
        token().safeTransfer(beneficiary4(), amountsingle);
    }
}
