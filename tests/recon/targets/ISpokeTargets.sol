// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/spoke/interfaces/ISpoke.sol";

abstract contract ISpokeTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iSpoke_addDynamicReserveConfig(uint256 reserveId, ISpoke.DynamicReserveConfig memory dynamicConfig) public asActor {
        iSpoke.addDynamicReserveConfig(reserveId, dynamicConfig);
    }

    function iSpoke_addReserve(address hub, uint256 assetId, address priceSource, ISpoke.ReserveConfig memory config, ISpoke.DynamicReserveConfig memory dynamicConfig) public asActor {
        iSpoke.addReserve(hub, assetId, priceSource, config, dynamicConfig);
    }

    function iSpoke_borrow(uint256 reserveId, uint256 amount, address onBehalfOf) public asActor {
        iSpoke.borrow(reserveId, amount, onBehalfOf);
    }

    function iSpoke_liquidationCall(uint256 collateralReserveId, uint256 debtReserveId, address user, uint256 debtToCover, bool receiveShares) public asActor {
        iSpoke.liquidationCall(collateralReserveId, debtReserveId, user, debtToCover, receiveShares);
    }

    function iSpoke_multicall(bytes[] memory data) public asActor {
        iSpoke.multicall(data);
    }

    function iSpoke_permitReserve(uint256 reserveId, address onBehalfOf, uint256 value, uint256 deadline, uint8 permitV, bytes32 permitR, bytes32 permitS) public asActor {
        iSpoke.permitReserve(reserveId, onBehalfOf, value, deadline, permitV, permitR, permitS);
    }

    function iSpoke_renouncePositionManagerRole(address user) public asActor {
        iSpoke.renouncePositionManagerRole(user);
    }

    function iSpoke_repay(uint256 reserveId, uint256 amount, address onBehalfOf) public asActor {
        iSpoke.repay(reserveId, amount, onBehalfOf);
    }

    function iSpoke_setAuthority(address ) public asActor {
        iSpoke.setAuthority(address(0));
    }

    function iSpoke_setUserPositionManager(address positionManager, bool approve) public asActor {
        iSpoke.setUserPositionManager(positionManager, approve);
    }

    function iSpoke_setUserPositionManagerWithSig(address positionManager, address user, bool approve, uint256 nonce, uint256 deadline, bytes memory signature) public asActor {
        iSpoke.setUserPositionManagerWithSig(positionManager, user, approve, nonce, deadline, signature);
    }

    function iSpoke_setUsingAsCollateral(uint256 reserveId, bool usingAsCollateral, address onBehalfOf) public asActor {
        iSpoke.setUsingAsCollateral(reserveId, usingAsCollateral, onBehalfOf);
    }

    function iSpoke_supply(uint256 reserveId, uint256 amount, address onBehalfOf) public asActor {
        iSpoke.supply(reserveId, amount, onBehalfOf);
    }

    function iSpoke_updateDynamicReserveConfig(uint256 reserveId, uint24 dynamicConfigKey, ISpoke.DynamicReserveConfig memory dynamicConfig) public asActor {
        iSpoke.updateDynamicReserveConfig(reserveId, dynamicConfigKey, dynamicConfig);
    }

    function iSpoke_updateLiquidationConfig(ISpoke.LiquidationConfig memory config) public asActor {
        iSpoke.updateLiquidationConfig(config);
    }

    function iSpoke_updatePositionManager(address positionManager, bool active) public asActor {
        iSpoke.updatePositionManager(positionManager, active);
    }

    function iSpoke_updateReserveConfig(uint256 reserveId, ISpoke.ReserveConfig memory params) public asActor {
        iSpoke.updateReserveConfig(reserveId, params);
    }

    function iSpoke_updateReservePriceSource(uint256 reserveId, address priceSource) public asActor {
        iSpoke.updateReservePriceSource(reserveId, priceSource);
    }

    function iSpoke_updateUserDynamicConfig(address onBehalfOf) public asActor {
        iSpoke.updateUserDynamicConfig(onBehalfOf);
    }

    function iSpoke_updateUserRiskPremium(address onBehalfOf) public asActor {
        iSpoke.updateUserRiskPremium(onBehalfOf);
    }

    function iSpoke_useNonce(uint192 key) public asActor {
        iSpoke.useNonce(key);
    }

    function iSpoke_withdraw(uint256 reserveId, uint256 amount, address onBehalfOf) public asActor {
        iSpoke.withdraw(reserveId, amount, onBehalfOf);
    }
}