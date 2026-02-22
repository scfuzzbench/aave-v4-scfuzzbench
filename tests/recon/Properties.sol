// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

/// @notice Invariants are written to support both Echidna property mode (bool) and optimization mode (int256).
/// @dev Default is property mode; to switch, run:
///      `sed -i '' -e 's/OPTIMIZATION_MODE = false/OPTIMIZATION_MODE = true/' -e 's/public returns (bool)/public returns (int256 maxViolation)/g' -e 's/return maxViolation <= 0;/return maxViolation;/g' tests/recon/Properties.sol`
///      This keeps the same invariant logic but changes the return type and value so fuzzers can optimize on a
///      signed percentage target where <= 0 is success and > 0 is a violation, while skipping assertions.
abstract contract Properties is BeforeAfter, Asserts {
    int256 internal constant PERCENT = int256(1e18);
    bool internal constant OPTIMIZATION_MODE = false;

    /// @dev Avoids Low likelihood scenarios in Audit Contest
    uint256 internal constant MIN_TOTAL_SUPPLIED = 1e6;

    string constant ASSERTION_LIQUIDATION_CALL_DOS = "!!! iSpoke_liquidationCall DoS";
    string constant ASSERTION_REPAY_DOS = "!!! iSpoke_repay DoS";
    string constant ASSERTION_SUPPLY_DOS = "!!! iSpoke_supply DoS";
    string constant ASSERTION_WITHDRAW_DOS = "!!! iSpoke_withdraw DoS";
    string constant ASSERTION_MINT_FEE_SHARES_PPS_CHANGE = "!!! iHub_mintFeeShares PPS change";
    string constant ASSERTION_CANARY = "!!! canary assertion";

    /// @dev Avoids invalidated issues by only implementing pre-vetted list of Audit Contest invariants 
    /// @dev Reference https://audits.sherlock.xyz/contests/1209
    string constant INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V0 = "Invariant 1: Total borrowed assets <= total supplied assets (v0)";
    string constant INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V1 = "Invariant 1: Total borrowed assets <= total supplied assets (v1)";
    string constant INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V2 = "Invariant 1: Total borrowed assets <= total supplied assets (v2)";
    string constant INVARIANT_2_TOTAL_BORROWED_SHARES_MATCHES_SPOKE_SUM = "Invariant 2: Total borrowed shares == sum of Spoke debt shares";
    string constant INVARIANT_3_HUB_ADDED_ASSETS_GREATER_THAN_SPOKE_SUM = "Invariant 3: Hub added assets >= sum of Spoke added assets (converted from shares)";
    string constant INVARIANT_4_HUB_ADDED_SHARES_MATCHES_SPOKE_SUM = "Invariant 4: Hub added shares == sum of Spoke added shares";
    string constant INVARIANT_5_SUPPLY_SHARE_PRICE_AND_DRAWN_INDEX_MONOTONIC = "Invariant 5: Supply share price and drawn index cannot decrease";

    /// @dev Add extra 'Holy grail' property
    string constant INVARIANT_HOLY_GRAIL_SHOULD_NOT_BECOME_LIQUIDATABLE = "Holy grail: Users should not become liquidatable except by price change";
    string constant INVARIANT_CANARY_GLOBAL_INVARIANT_FAILURE = "Canary invariant";

    function _relativeDiff(int256 diff, uint256 denom) internal pure returns (int256) {
        if (denom == 0) {
            if (diff == 0) {
                return 0;
            }
            return diff > 0 ? type(int256).max : type(int256).min;
        }
        return (diff * PERCENT) / int256(denom);
    }

    function _abs(int256 value) internal pure returns (int256) {
        return value < 0 ? -value : value;
    }

    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v0)
    /// @dev Uses definition assumed by the auditors
    function invariant_totalBorrowedLessThanSupplied_v0() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.getAddedShares(i);

            int256 diff = totalBorrowed >= totalSupplied
                ? int256(totalBorrowed - totalSupplied)
                : -int256(totalSupplied - totalBorrowed);
            int256 relativeDiff = _relativeDiff(diff, totalSupplied);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V0);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v1)
    /// @dev Uses definition provided by the protocol team
    function invariant_totalBorrowedLessThanSupplied_v1() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.previewRemoveByShares(i, iHub.getAddedShares(i)) + iHub.getAssetAccruedFees(i);

            if (totalSupplied <= MIN_TOTAL_SUPPLIED) {
                continue;
            }

            int256 diff = totalBorrowed >= totalSupplied
                ? int256(totalBorrowed - totalSupplied)
                : -int256(totalSupplied - totalBorrowed);
            int256 relativeDiff = _relativeDiff(diff, totalSupplied);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V1);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v2)
    /// @dev Uses definition provided by the protocol team with auditors fix
    function invariant_totalBorrowedLessThanSupplied_v2() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.getAddedAssets(i) + iHub.getAssetAccruedFees(i);

            if (totalSupplied <= MIN_TOTAL_SUPPLIED) {
                continue;
            }

            int256 diff = totalBorrowed >= totalSupplied
                ? int256(totalBorrowed - totalSupplied)
                : -int256(totalSupplied - totalBorrowed);
            int256 relativeDiff = _relativeDiff(diff, totalSupplied);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_1_TOTAL_BORROWED_LESS_THAN_SUPPLIED_V2);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 2: Total borrowed shares == sum of Spoke debt shares
    function invariant_totalBorrowedSharesMatchesSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 hubDrawnShares = iHub.getAssetDrawnShares(i);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeDrawnShares = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeDrawnShares += iHub.getSpokeDrawnShares(i, spoke);
            }

            int256 diff = hubDrawnShares >= sumSpokeDrawnShares
                ? int256(hubDrawnShares - sumSpokeDrawnShares)
                : -int256(sumSpokeDrawnShares - hubDrawnShares);
            int256 relativeDiff = _relativeDiff(_abs(diff), sumSpokeDrawnShares);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_2_TOTAL_BORROWED_SHARES_MATCHES_SPOKE_SUM);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 3: Hub added assets >= sum of Spoke added assets (converted from shares)
    function invariant_hubAddedAssetsGreaterThanSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 addedShares = iHub.getAddedShares(i);
            uint256 hubAddedAssets = iHub.previewRemoveByShares(i, addedShares);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeAddedAssets = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeAddedAssets += iHub.getSpokeAddedAssets(i, spoke);
            }

            int256 diff = sumSpokeAddedAssets >= hubAddedAssets
                ? int256(sumSpokeAddedAssets - hubAddedAssets)
                : -int256(hubAddedAssets - sumSpokeAddedAssets);
            int256 relativeDiff = _relativeDiff(diff, sumSpokeAddedAssets);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_3_HUB_ADDED_ASSETS_GREATER_THAN_SPOKE_SUM);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 4: Hub added shares == sum of Spoke added shares
    function invariant_hubAddedSharesMatchesSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 hubAddedShares = iHub.getAddedShares(i);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeAddedShares = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeAddedShares += iHub.getSpokeAddedShares(i, spoke);
            }

            int256 diff = hubAddedShares >= sumSpokeAddedShares
                ? int256(hubAddedShares - sumSpokeAddedShares)
                : -int256(sumSpokeAddedShares - hubAddedShares);
            int256 relativeDiff = _relativeDiff(_abs(diff), sumSpokeAddedShares);
            if (relativeDiff > maxViolation) {
                maxViolation = relativeDiff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_4_HUB_ADDED_SHARES_MATCHES_SPOKE_SUM);
        }
        return maxViolation <= 0;
    }

    /// @notice Invariant 5: Supply share price and drawn index cannot decrease
    function invariant_supplySharePriceAndDrawnIndexMonotonic() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();
        int256 maxViolation = type(int256).min;

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 currentDrawnIndex = iHub.getAssetDrawnIndex(i);
            uint256 maxDrawnIndexSeen = ghost_maxDrawnIndexSeen[i];

            if (maxDrawnIndexSeen > 0) {
                int256 diff = currentDrawnIndex >= maxDrawnIndexSeen
                    ? -int256(currentDrawnIndex - maxDrawnIndexSeen)
                    : int256(maxDrawnIndexSeen - currentDrawnIndex);
                int256 relativeDiff = _relativeDiff(diff, maxDrawnIndexSeen);
                if (relativeDiff > maxViolation) {
                    maxViolation = relativeDiff;
                }
            }

            uint256 addedShares = iHub.getAddedShares(i);
            if (addedShares > 0) {
                uint256 addedAssets = iHub.getAddedAssets(i);
                uint256 maxAssets = ghost_maxSupplySharePriceAssetsSeen[i];
                uint256 maxShares = ghost_maxSupplySharePriceSharesSeen[i];

                if (maxShares > 0) {
                    uint256 lhs = addedAssets * maxShares;
                    uint256 rhs = maxAssets * addedShares;
                    int256 diff = lhs >= rhs
                        ? -int256(lhs - rhs)
                        : int256(rhs - lhs);
                    int256 relativeDiff = _relativeDiff(diff, rhs);
                    if (relativeDiff > maxViolation) {
                        maxViolation = relativeDiff;
                    }
                }
            }

            _updateMonotonicGhosts(i);
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_5_SUPPLY_SHARE_PRICE_AND_DRAWN_INDEX_MONOTONIC);
        }
        return maxViolation <= 0;
    }

    /// @dev Reference https://www.certora.com/blog/the-holy-grail
    function invariant_shouldNotBecomeLiquidatable() public returns (bool) {
        int256 maxViolation = type(int256).min;
        if (_after.operation != Operation.SetPrice) {
            int256 diff = (_before.isAnyUserLiquidatable || !_after.isAnyUserLiquidatable) ? int256(0) : PERCENT;
            if (diff > maxViolation) {
                maxViolation = diff;
            }
        }
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_HOLY_GRAIL_SHOULD_NOT_BECOME_LIQUIDATABLE);
        }
        return maxViolation <= 0;
    }

    /// @dev Canary assertion helper. A failing input is expected to be discovered during fuzzing.
    function assert_canary(uint256 entropy) public {
        t(entropy > 0, ASSERTION_CANARY);
    }

    /// @dev Canary global invariant expected to fail immediately.
    function invariant_canary() public returns (bool) {
        int256 maxViolation = PERCENT;
        if (!OPTIMIZATION_MODE) {
            t(maxViolation <= 0, INVARIANT_CANARY_GLOBAL_INVARIANT_FAILURE);
        }
        return maxViolation <= 0;
    }
}
