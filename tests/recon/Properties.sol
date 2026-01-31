// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {
    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v0)
    /// @dev Uses definition assumed by the auditors
    function invariant_totalBorrowedLessThanSupplied_v0() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.getAddedShares(i);

            lte(totalBorrowed, totalSupplied, "Total borrowed exceeds total supplied");
            if (totalBorrowed > totalSupplied) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v1)
    /// @dev Uses definition provided by the protocol team
    function invariant_totalBorrowedLessThanSupplied_v1() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.previewRemoveByShares(i, iHub.getAddedShares(i)) + iHub.getAssetAccruedFees(i);


            lte(totalBorrowed, totalSupplied, "Total borrowed exceeds total supplied");
            if (totalBorrowed > totalSupplied) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 1: Total borrowed assets <= total supplied assets (v2)
    /// @dev Uses definition provided by the protocol team with auditors fix
    function invariant_totalBorrowedLessThanSupplied_v2() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 totalBorrowed = iHub.getAssetTotalOwed(i);
            uint256 totalSupplied = iHub.getAddedAssets(i) + iHub.getAssetAccruedFees(i);

            lte(totalBorrowed, totalSupplied, "Total borrowed exceeds total supplied");
            if (totalBorrowed > totalSupplied) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 2: Total borrowed shares == sum of Spoke debt shares
    function invariant_totalBorrowedSharesMatchesSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 hubDrawnShares = iHub.getAssetDrawnShares(i);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeDrawnShares = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeDrawnShares += iHub.getSpokeDrawnShares(i, spoke);
            }

            eq(hubDrawnShares, sumSpokeDrawnShares, "Hub drawn shares != sum of spoke drawn shares");
            if (hubDrawnShares != sumSpokeDrawnShares) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 3: Hub added assets >= sum of Spoke added assets (converted from shares)
    function invariant_hubAddedAssetsGreaterThanSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 addedShares = iHub.getAddedShares(i);
            uint256 hubAddedAssets = iHub.previewRemoveByShares(i, addedShares);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeAddedAssets = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeAddedAssets += iHub.getSpokeAddedAssets(i, spoke);
            }

            gte(hubAddedAssets, sumSpokeAddedAssets, "Hub added assets < sum of spoke added assets");
            if (hubAddedAssets < sumSpokeAddedAssets) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 4: Hub added shares == sum of Spoke added shares
    function invariant_hubAddedSharesMatchesSpokeSum() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 hubAddedShares = iHub.getAddedShares(i);
            uint256 spokesCount = iHub.getSpokeCount(i);

            uint256 sumSpokeAddedShares = 0;
            for (uint256 j = 0; j < spokesCount; j++) {
                address spoke = iHub.getSpokeAddress(i, j);
                sumSpokeAddedShares += iHub.getSpokeAddedShares(i, spoke);
            }

            eq(hubAddedShares, sumSpokeAddedShares, "Hub added shares != sum of spoke added shares");
            if (hubAddedShares != sumSpokeAddedShares) {
                return false;
            }
        }
        return true;
    }

    /// @notice Invariant 5: Supply share price and drawn index cannot decrease
    function invariant_supplySharePriceAndDrawnIndexMonotonic() public returns (bool) {
        uint256 assetCount = iHub.getAssetCount();

        for (uint256 i = 0; i < assetCount; i++) {
            uint256 currentDrawnIndex = iHub.getAssetDrawnIndex(i);
            uint256 maxDrawnIndexSeen = ghost_maxDrawnIndexSeen[i];

            if (maxDrawnIndexSeen > 0) {
                gte(currentDrawnIndex, maxDrawnIndexSeen, "Drawn index decreased");
                if (currentDrawnIndex < maxDrawnIndexSeen) {
                    return false;
                }
            }

            uint256 addedShares = iHub.getAddedShares(i);
            if (addedShares > 0) {
                uint256 addedAssets = iHub.getAddedAssets(i);
                uint256 maxAssets = ghost_maxSupplySharePriceAssetsSeen[i];
                uint256 maxShares = ghost_maxSupplySharePriceSharesSeen[i];

                if (maxShares > 0) {
                    gte(addedAssets * maxShares, maxAssets * addedShares, "Supply share price decreased");
                    if (addedAssets * maxShares < maxAssets * addedShares) {
                        return false;
                    }
                }
            }

            _updateMonotonicGhosts(i);
        }
        return true;
    }

    function invariant_shouldNotBecomeLiquidatable() public returns (bool) {
        if (_after.operation == Operation.SetPrice) {
            return true;
        }

        if (!_before.isAnyUserLiquidatable && _after.isAnyUserLiquidatable) {
            t(false, "Users should not become liquidatable except by price change");
            return false;
        }
        return true;
    }
}
