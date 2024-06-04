// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

struct AccountInfo {
    EVCAccountInfo evcAccountInfo;
    VaultAccountInfo vaultAccountInfo;
    AccountRewardInfo accountRewardInfo;
}

struct AccountMultipleVaultsInfo {
    EVCAccountInfo evcAccountInfo;
    VaultAccountInfo[] vaultAccountInfo;
    AccountRewardInfo[] accountRewardInfo;
}

struct EVCAccountInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address evc;
    address account;
    bytes19 addressPrefix;
    address owner;
    bool isLockdownMode;
    bool isPermitDisabledMode;
    uint256 lastAccountStatusCheckTimestamp;
    address[] enabledControllers;
    address[] enabledCollaterals;
}

struct VaultAccountInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address account;
    address vault;
    address asset;
    uint256 assetsAccount;
    uint256 shares;
    uint256 assets;
    uint256 borrowed;
    uint256 assetAllowanceVault;
    uint256 assetAllowanceVaultPermit2;
    uint256 assetAllowanceExpirationVaultPermit2;
    uint256 assetAllowancePermit2;
    bool balanceForwarderEnabled;
    bool isController;
    bool isCollateral;
    AccountLiquidityInfo liquidityInfo;
}

struct AccountLiquidityInfo {
    int256 timeToLiquidation;
    uint256 liabilityValue;
    uint256 collateralValueBorrowing;
    uint256 collateralValueLiquidation;
    CollateralLiquidityInfo[] collateralLiquidityBorrowingInfo;
    CollateralLiquidityInfo[] collateralLiquidityLiquidationInfo;
}

struct CollateralLiquidityInfo {
    address collateral;
    uint256 collateralValue;
}

struct VaultInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address vault;
    string vaultName;
    string vaultSymbol;
    uint256 vaultDecimals;
    address asset;
    string assetName;
    string assetSymbol;
    uint256 assetDecimals;
    address unitOfAccount;
    string unitOfAccountName;
    string unitOfAccountSymbol;
    uint256 unitOfAccountDecimals;
    uint256 totalShares;
    uint256 totalCash;
    uint256 totalBorrowed;
    uint256 totalAssets;
    uint256 accumulatedFeesShares;
    uint256 accumulatedFeesAssets;
    address governorFeeReceiver;
    address protocolFeeReceiver;
    uint256 protocolFeeShare;
    uint256 interestFee;
    uint256 hookedOperations;
    uint256 supplyCap;
    uint256 borrowCap;
    uint256 maxLiquidationDiscount;
    uint256 liquidationCoolOffTime;
    address dToken;
    address oracle;
    address interestRateModel;
    address hookTarget;
    address evc;
    address protocolConfig;
    address balanceTracker;
    address permit2;
    address creator;
    address governorAdmin;
    VaultInterestRateModelInfo irmInfo;
    LTVInfo[] collateralLTVInfo;
    AssetPriceInfo liabilityPriceInfo;
    AssetPriceInfo[] collateralPriceInfo;
}

struct LTVInfo {
    address collateral;
    uint256 borrowLTV;
    uint256 liquidationLTV;
    uint256 initialLiquidationLTV;
    uint256 targetTimestamp;
    uint256 rampDuration;
}

struct AssetPriceInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address asset;
    address unitOfAccount;
    uint256 amountIn;
    uint256 amountOutMid;
    uint256 amountOutBid;
    uint256 amountOutAsk;
    OracleInfo oracleInfo;
}

struct OracleInfo {
    address router;
    address adapter;
    string name;
    bytes details;
}

struct VaultInterestRateModelInfo {
    address vault;
    address interestRateModel;
    APYInfo[] apyInfo;
}

struct APYInfo {
    uint256 cash;
    uint256 borrows;
    uint256 borrowInterestRateSPY;
    uint256 borrowInterestRateAPY;
    uint256 supplyInterestRateSPY;
    uint256 supplyInterestRateAPY;
}

struct AccountRewardInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address account;
    address vault;
    address balanceTracker;
    bool balanceForwarderEnabled;
    uint256 balance;
    EnabledRewardInfo[] enabledRewardsInfo;
}

struct EnabledRewardInfo {
    address reward;
    uint256 earnedReward;
    uint256 earnedRewardRecentForfeited;
}

struct VaultRewardInfo {
    uint256 timestamp;
    uint256 blockNumber;
    address vault;
    address reward;
    address balanceTracker;
    uint256 epochDuration;
    uint256 currentEpoch;
    uint256 totalRewardEligible;
    uint256 totalRewardRegistered;
    uint256 totalRewardClaimed;
    RewardAmountInfo[] epochInfoPrevious;
    RewardAmountInfo[] epochInfoUpcoming;
}

struct RewardAmountInfo {
    uint256 epoch;
    uint256 epochStart;
    uint256 epochEnd;
    uint256 rewardAmount;
}

struct OracleDetailedInfo {
    string name;
    bytes oracleInfo;
}

struct EulerRouterInfo {
    address governor;
    address fallbackOracle;
    address[] resolvedOracles;
    OracleDetailedInfo fallbackOracleInfo;
    OracleDetailedInfo[] resolvedOraclesInfo;
}

struct ChainlinkOracleInfo {
    address base;
    address quote;
    address feed;
    uint256 maxStaleness;
}

struct ChronicleOracleInfo {
    address base;
    address quote;
    address feed;
    uint256 maxStaleness;
}

struct LidoOracleInfo {
    address base;
    address quote;
}

struct PythOracleInfo {
    address pyth;
    address base;
    address quote;
    bytes32 feedId;
    uint256 maxStaleness;
    uint256 maxConfWidth;
}

struct RedstoneCoreOracleInfo {
    address base;
    address quote;
    bytes32 feedId;
    uint8 feedDecimals;
    uint256 maxStaleness;
    uint208 cachePrice;
    uint48 cachePriceTimestamp;
}

struct UniswapV3OracleInfo {
    address tokenA;
    address tokenB;
    address pool;
    uint24 fee;
    uint32 twapWindow;
}

struct CrossAdapterInfo {
    address base;
    address cross;
    address quote;
    address oracleBaseCross;
    address oracleCrossQuote;
    OracleDetailedInfo oracleBaseCrossInfo;
    OracleDetailedInfo oracleCrossQuoteInfo;
}
