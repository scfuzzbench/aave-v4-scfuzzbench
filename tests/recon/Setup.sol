// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils as ReconUtils} from "@recon/Utils.sol";

// Your deps
import "src/spoke/interfaces/IAaveOracle.sol";
import "src/hub/interfaces/IHub.sol";
import "src/spoke/interfaces/ISpoke.sol";

import "tests/Base.t.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, ReconUtils, Base {
    mapping(address underlying => uint256 maxAmount) internal _maxByUnderlying;

    IAaveOracle iAaveOracle;
    IHub iHub;
    ISpoke iSpoke;
    
    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        deployFixtures();
        initEnvironment();

        iAaveOracle = oracle1;
        iHub = hub1;
        iSpoke = spoke1;

        _addAsset(address(tokenList.weth));
        _maxByUnderlying[address(tokenList.weth)] = 10e3 * 10 ** tokenList.weth.decimals();
        _addAsset(address(tokenList.usdx));
        _maxByUnderlying[address(tokenList.usdx)] = 100e3 * 10 ** tokenList.usdx.decimals();
        _addAsset(address(tokenList.dai));
        _maxByUnderlying[address(tokenList.dai)] = 100e3 * 10 ** tokenList.dai.decimals();
        _addAsset(address(tokenList.wbtc));
        _maxByUnderlying[address(tokenList.wbtc)] = 10e3 * 10 ** tokenList.wbtc.decimals();
        _addAsset(address(tokenList.usdy));
        _maxByUnderlying[address(tokenList.usdy)] = 100e3 * 10 ** tokenList.usdy.decimals();
        _addAsset(address(tokenList.usdz));
        _maxByUnderlying[address(tokenList.usdz)] = 100e3 * 10 ** tokenList.usdz.decimals();

        _switchAsset(0);

        _addActor(alice);
        _addActor(bob);
        _addActor(LIQUIDATOR);

        _switchActor(0);
    }

    /// === HELPERS === ///
    /// Get the max amount for a given reserve based on its underlying token decimals (avoids Low likelihood scenarios in Audit Contest)
    function _max(uint256 reserveId) internal view returns (uint256) {
        ISpoke.Reserve memory reserve = iSpoke.getReserve(reserveId);
        address underlying = reserve.underlying;
        uint256 maxAmount = _maxByUnderlying[underlying];
        require(maxAmount > 0, "Max not set for underlying");
        return maxAmount;
    }
}
