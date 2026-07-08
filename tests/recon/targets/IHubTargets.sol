// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/hub/interfaces/IHub.sol";
import "src/hub/interfaces/IAssetInterestRateStrategy.sol";

abstract contract IHubTargets is BaseTargetFunctions, Properties {
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iHub_add(uint256 assetId, uint256 amount) private asActor {
        iHub.add(assetId, amount);
    }

    function iHub_addAsset(
        address underlying,
        uint8 decimals,
        address feeReceiver,
        address irStrategy,
        bytes memory irData
    ) private asActor {
        iHub.addAsset(underlying, decimals, feeReceiver, irStrategy, irData);
    }

    function iHub_addSpoke(uint256 assetId, address spoke, IHub.SpokeConfig memory params) private asActor {
        iHub.addSpoke(assetId, spoke, params);
    }

    function iHub_draw(uint256 assetId, uint256 amount, address to) private asActor {
        iHub.draw(assetId, amount, to);
    }

    function iHub_eliminateDeficit(uint256 assetId, uint256 amount, address spoke) private asActor {
        iHub.eliminateDeficit(assetId, amount, spoke);
    }

    function iHub_mintFeeShares_ASSERTION_MINT_FEE_SHARES_PPS_CHANGE(uint256 assetId) public asAdmin {
        uint256 assetCount = iHub.getAssetCount();
        require(assetCount > 0);

        assetId = between(assetId, 0, assetCount - 1);
        uint256 oldPPS = _pps(assetId);
        iHub.mintFeeShares(assetId);
        uint256 newPPS = _pps(assetId);

        uint256 diff = oldPPS > newPPS ? oldPPS - newPPS : newPPS - oldPPS;
        uint256 relativeDiff = (diff * 1e18) / oldPPS;

        lte(relativeDiff, 1, ASSERTION_MINT_FEE_SHARES_PPS_CHANGE);
    }

    function _pps(uint256 assetId) private view returns (uint256) {
        return iHub.getAddedAssets(assetId) * 1e18 / iHub.getAddedShares(assetId);
    }

    function iHub_payFeeShares(uint256 assetId, uint256 shares) private asActor {
        iHub.payFeeShares(assetId, shares);
    }

    function iHub_reclaim(uint256 assetId, uint256 amount) private asActor {
        iHub.reclaim(assetId, amount);
    }

    function iHub_refreshPremium(uint256 assetId, IHubBase.PremiumDelta memory premiumDelta) private asActor {
        iHub.refreshPremium(assetId, premiumDelta);
    }

    function iHub_remove(uint256 assetId, uint256 amount, address to) private asActor {
        iHub.remove(assetId, amount, to);
    }

    function iHub_reportDeficit(uint256 assetId, uint256 drawnAmount, IHubBase.PremiumDelta memory premiumDelta)
        private
        asActor
    {
        iHub.reportDeficit(assetId, drawnAmount, premiumDelta);
    }

    function iHub_restore(uint256 assetId, uint256 drawnAmount, IHubBase.PremiumDelta memory premiumDelta)
        private
        asActor
    {
        iHub.restore(assetId, drawnAmount, premiumDelta);
    }

    function iHub_setAuthority(address) private asActor {
        iHub.setAuthority(address(0));
    }

    function iHub_setInterestRateData(uint256 assetId, bytes memory irData) private asActor {
        iHub.setInterestRateData(assetId, irData);
    }

    function iHub_setInterestRateData(uint256 assetId, IAssetInterestRateStrategy.InterestRateData memory irData)
        public
        asAdmin
    {
        uint256 assetCount = iHub.getAssetCount();
        require(assetCount > 0);

        assetId = between(assetId, 0, assetCount - 1);
        iHub.setInterestRateData(assetId, abi.encode(irData));
    }

    function iHub_sweep(uint256 assetId, uint256 amount) private asActor {
        iHub.sweep(assetId, amount);
    }

    function iHub_transferShares(uint256 assetId, uint256 shares, address toSpoke) private asActor {
        iHub.transferShares(assetId, shares, toSpoke);
    }

    function iHub_updateAssetConfig(uint256 assetId, IHub.AssetConfig memory config, bytes memory irData)
        private
        asActor
    {
        iHub.updateAssetConfig(assetId, config, irData);
    }

    function iHub_updateAssetConfig(
        uint256 assetId,
        IHub.AssetConfig memory config,
        IAssetInterestRateStrategy.InterestRateData memory irData
    ) public asAdmin {
        uint256 assetCount = iHub.getAssetCount();
        require(assetCount > 0);

        assetId = between(assetId, 0, assetCount - 1);

        iHub.updateAssetConfig(assetId, config, abi.encode(irData));
    }

    function iHub_updateSpokeConfig(uint256 assetId, address spoke, IHub.SpokeConfig memory config) private asActor {
        iHub.updateSpokeConfig(assetId, spoke, config);
    }

    function iHub_updateSpokeConfig(uint256 assetId, uint256 spokeId, IHub.SpokeConfig memory config) public asAdmin {
        uint256 assetCount = iHub.getAssetCount();
        require(assetCount > 0);

        assetId = between(assetId, 0, assetCount - 1);

        uint256 spokeCount = iHub.getSpokeCount(assetId);
        require(spokeCount > 0);

        spokeId = between(spokeId, 0, spokeCount - 1);

        address spoke = iHub.getSpokeAddress(assetId, spokeId);
        iHub.updateSpokeConfig(assetId, spoke, config);
    }
}
