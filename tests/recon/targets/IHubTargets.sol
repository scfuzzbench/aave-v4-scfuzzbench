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

abstract contract IHubTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iHub_add(uint256 assetId, uint256 amount) public asActor {
        iHub.add(assetId, amount);
    }

    function iHub_addAsset(address underlying, uint8 decimals, address feeReceiver, address irStrategy, bytes memory irData) public asActor {
        iHub.addAsset(underlying, decimals, feeReceiver, irStrategy, irData);
    }

    function iHub_addSpoke(uint256 assetId, address spoke, IHub.SpokeConfig memory params) public asActor {
        iHub.addSpoke(assetId, spoke, params);
    }

    function iHub_draw(uint256 assetId, uint256 amount, address to) public asActor {
        iHub.draw(assetId, amount, to);
    }

    function iHub_eliminateDeficit(uint256 assetId, uint256 amount, address spoke) public asActor {
        iHub.eliminateDeficit(assetId, amount, spoke);
    }

    function iHub_mintFeeShares(uint256 assetId) public asActor {
        iHub.mintFeeShares(assetId);
    }

    function iHub_payFeeShares(uint256 assetId, uint256 shares) public asActor {
        iHub.payFeeShares(assetId, shares);
    }

    function iHub_reclaim(uint256 assetId, uint256 amount) public asActor {
        iHub.reclaim(assetId, amount);
    }

    function iHub_refreshPremium(uint256 assetId, IHubBase.PremiumDelta memory premiumDelta) public asActor {
        iHub.refreshPremium(assetId, premiumDelta);
    }

    function iHub_remove(uint256 assetId, uint256 amount, address to) public asActor {
        iHub.remove(assetId, amount, to);
    }

    function iHub_reportDeficit(uint256 assetId, uint256 drawnAmount, IHubBase.PremiumDelta memory premiumDelta) public asActor {
        iHub.reportDeficit(assetId, drawnAmount, premiumDelta);
    }

    function iHub_restore(uint256 assetId, uint256 drawnAmount, IHubBase.PremiumDelta memory premiumDelta) public asActor {
        iHub.restore(assetId, drawnAmount, premiumDelta);
    }

    function iHub_setAuthority(address ) public asActor {
        iHub.setAuthority(address(0));
    }

    function iHub_setInterestRateData(uint256 assetId, bytes memory irData) public asActor {
        iHub.setInterestRateData(assetId, irData);
    }

    function iHub_sweep(uint256 assetId, uint256 amount) public asActor {
        iHub.sweep(assetId, amount);
    }

    function iHub_transferShares(uint256 assetId, uint256 shares, address toSpoke) public asActor {
        iHub.transferShares(assetId, shares, toSpoke);
    }

    function iHub_updateAssetConfig(uint256 assetId, IHub.AssetConfig memory config, bytes memory irData) public asActor {
        iHub.updateAssetConfig(assetId, config, irData);
    }

    function iHub_updateSpokeConfig(uint256 assetId, address spoke, IHub.SpokeConfig memory config) public asActor {
        iHub.updateSpokeConfig(assetId, spoke, config);
    }
}