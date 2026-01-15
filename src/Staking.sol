// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    uint256 public totalStaked;
    // rate per second
    uint256 public rewardRate;
    //Last timestamp when rewards were updated
    uint256 public lastUpdateTime;
    //Accumulated rewards per staked token (scaled)
    uint256 public rewardPerTokenStored;

    //User-specific staking info
    struct UserInfo {
        uint256 stakedAmount;
        uint256 rewardDebt; // rewards already accounted for
        uint256 lastUpdateTime; // last time this user was updated
    }

    mapping(address => UserInfo) public userInfo;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);

    error ZeroAmount();
    error InsufficientBalance();
    error NotEnoughRewards();

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    /// @notice Update reward rate (owner only)
    function setRewardRate(uint256 _rewardRate) external {
        // In production: add onlyOwner modifier
        rewardRate = _rewardRate;
        _updateReward(address(0)); // update global state
        emit RewardRateUpdated(_rewardRate);
    }

    /// @notice Stake tokens to earn rewards
    function stake(uint256 _amount) external {
        if (_amount == 0) revert ZeroAmount();

        _updateReward(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), _amount);

        userInfo[msg.sender].stakedAmount += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    /// @notice Unstake tokens and claim rewards
    function unstake(uint256 _amount) external {
        if (_amount == 0) revert ZeroAmount();
        if (userInfo[msg.sender].stakedAmount < _amount)
            revert InsufficientBalance();

        _updateReward(msg.sender);

        userInfo[msg.sender].stakedAmount -= _amount;
        totalStaked -= _amount;

        stakingToken.transfer(msg.sender, _amount);

        _claimRewards(msg.sender);

        emit Unstaked(msg.sender, _amount);
    }

    /// @notice Claim accumulated rewards without unstaking
    function claimRewards() external {
        _updateReward(msg.sender);
        _claimRewards(msg.sender);
    }

    /// @notice View pending rewards for a user
    function pendingRewards(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        if (totalStaked == 0) return 0;

        uint256 rewardPerToken = rewardPerTokenStored +
            ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
            totalStaked;

        uint256 newReward = (user.stakedAmount *
            (rewardPerToken - user.rewardDebt)) / 1e18;
        return newReward;
    }

    // Internal: Update global reward state
    function _updateReward(address _account) internal {
        if (totalStaked == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }

        rewardPerTokenStored +=
            ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
            totalStaked;
        lastUpdateTime = block.timestamp;

        if (_account != address(0)) {
            UserInfo storage user = userInfo[_account];
            user.rewardDebt = (user.stakedAmount * rewardPerTokenStored) / 1e18;
        }
    }

    // Internal: Send pending rewards to user
    function _claimRewards(address _user) internal {
        UserInfo storage user = userInfo[_user];
        uint256 pending = (user.stakedAmount * rewardPerTokenStored) /
            1e18 -
            user.rewardDebt;

        if (pending > 0) {
            user.rewardDebt = (user.stakedAmount * rewardPerTokenStored) / 1e18;
            rewardsToken.transfer(_user, pending);
            emit RewardPaid(_user, pending);
        }
    }

    // View total rewards distributed so far (for info)
    function totalRewardsDistributed() external view returns (uint256) {
        return rewardRate * (block.timestamp - lastUpdateTime);
    }
}

// Minimal ERC-20 interface (for clarity)
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
