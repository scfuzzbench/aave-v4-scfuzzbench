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
import "src/spoke/interfaces/ISpoke.sol";
import "src/spoke/interfaces/IAaveOracle.sol";
import "src/dependencies/openzeppelin/Ownable.sol";
import "src/dependencies/openzeppelin/IERC20Errors.sol";
import "src/dependencies/weth/WETH9.sol";
import "src/spoke/libraries/LiquidationLogic.sol";

abstract contract ISpokeTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iSpoke_addDynamicReserveConfig(uint256 reserveId, ISpoke.DynamicReserveConfig memory dynamicConfig) public asAdmin {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 0);

        reserveId = between(reserveId, 0, reserveCount - 1);        
        iSpoke.addDynamicReserveConfig(reserveId, dynamicConfig);
    }

    function iSpoke_addReserve(address hub, uint256 assetId, address priceSource, ISpoke.ReserveConfig memory config, ISpoke.DynamicReserveConfig memory dynamicConfig) private asActor {
        iSpoke.addReserve(hub, assetId, priceSource, config, dynamicConfig);
    }

    function iSpoke_borrow(uint256 reserveId, uint256 amount, address onBehalfOf) private asActor {
        iSpoke.borrow(reserveId, amount, onBehalfOf);
    }

    function iSpoke_borrow(uint256 reserveId, uint256 amount) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 0);

        reserveId = between(reserveId, 0, reserveCount - 1);
        amount = between(amount, 0, _max(reserveId));
        
        iSpoke.borrow(reserveId, amount, _getActor());
    }

    function iSpoke_liquidationCall(uint256 collateralReserveId, uint256 debtReserveId, address user, uint256 debtToCover, bool receiveShares) private asActor {
        iSpoke.liquidationCall(collateralReserveId, debtReserveId, user, debtToCover, receiveShares);
    }

    function iSpoke_liquidationCall(uint256 collateralReserveId, uint256 debtReserveId, uint256 userId, uint256 debtToCover, bool receiveShares) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 1);
        address[] memory actors = _getActors();
        require(actors.length > 0);

        collateralReserveId = between(collateralReserveId, 0, reserveCount - 1);
        debtReserveId = between(debtReserveId, 0, reserveCount - 1);
        debtToCover = between(debtToCover, 0, _max(debtReserveId));
        userId = between(userId, 0, actors.length - 1);
        address user = actors[userId];

        try iSpoke.liquidationCall(collateralReserveId, debtReserveId, user, debtToCover, receiveShares) {} catch (bytes memory err) {
            t(bytes4(err) == ISpoke.ReserveNotListed.selector
              || bytes4(err) == ISpoke.SelfLiquidation.selector
              || bytes4(err) == ISpoke.InvalidDebtToCover.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientAllowance.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientBalance.selector
              || bytes4(err) == WETH9.InsufficientAllowance.selector
              || bytes4(err) == WETH9.InsufficientBalance.selector
              || bytes4(err) == ISpoke.ReservePaused.selector
              || bytes4(err) == ISpoke.ReserveNotSupplied.selector
              || bytes4(err) == ISpoke.ReserveNotBorrowed.selector
              || bytes4(err) == ISpoke.CollateralCannotBeLiquidated.selector
              || bytes4(err) == ISpoke.HealthFactorNotBelowThreshold.selector
              || bytes4(err) == ISpoke.ReserveNotEnabledAsCollateral.selector
              || bytes4(err) == ISpoke.CannotReceiveShares.selector
              || bytes4(err) == ISpoke.MustNotLeaveDust.selector
              || bytes4(err) == IHub.InvalidAmount.selector
              || bytes4(err) == IHub.SpokeNotActive.selector
              || bytes4(err) == IHub.SpokePaused.selector
              || (bytes4(err) == IHub.InsufficientLiquidity.selector && !receiveShares)
              || bytes4(err) == IAaveOracle.InvalidPrice.selector
              , "iSpoke_liquidationCall: DoS");
            require(false);
        }
    }

    function iSpoke_multicall(bytes[] memory data) private asActor {
        iSpoke.multicall(data);
    }

    function iSpoke_permitReserve(uint256 reserveId, address onBehalfOf, uint256 value, uint256 deadline, uint8 permitV, bytes32 permitR, bytes32 permitS) private asActor {
        iSpoke.permitReserve(reserveId, onBehalfOf, value, deadline, permitV, permitR, permitS);
    }

    function iSpoke_renouncePositionManagerRole(address user) private asActor {
        iSpoke.renouncePositionManagerRole(user);
    }

    function iSpoke_repay(uint256 reserveId, uint256 amount, address onBehalfOf) private asActor {
        iSpoke.repay(reserveId, amount, onBehalfOf);
    }

    function iSpoke_repay(uint256 reserveId, uint256 amount) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 1);

        reserveId = between(reserveId, 0, reserveCount - 1);
        amount = between(amount, 0, _max(reserveId));

        uint256 value0;
        uint256 value1;
        try iSpoke.repay(reserveId, amount, _getActor()) returns (uint256 tempValue0, uint256 tempValue1) {
            value0 = tempValue0;
            value1 = tempValue1;
        } catch (bytes memory err) {
            t(bytes4(err) == ISpoke.Unauthorized.selector
              || bytes4(err) == ISpoke.ReserveNotListed.selector
              || bytes4(err) == ISpoke.ReservePaused.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientAllowance.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientBalance.selector
              || bytes4(err) == WETH9.InsufficientAllowance.selector
              || bytes4(err) == WETH9.InsufficientBalance.selector
              || bytes4(err) == IHub.InvalidAmount.selector
              || bytes4(err) == IHub.SpokeNotActive.selector
              || bytes4(err) == IHub.SpokePaused.selector
              || bytes4(err) == IHub.SurplusDrawnRestored.selector
              || bytes4(err) == IHub.SurplusPremiumRayRestored.selector
              || bytes4(err) == IAaveOracle.InvalidPrice.selector
              , "iSpoke_repay: DoS");
            require(false);
        }
    }

    function iSpoke_setAuthority(address ) private asActor {
        iSpoke.setAuthority(address(0));
    }

    function iSpoke_setUserPositionManager(address positionManager, bool approve) private asActor {
        iSpoke.setUserPositionManager(positionManager, approve);
    }

    function iSpoke_setUserPositionManagerWithSig(address positionManager, address user, bool approve, uint256 nonce, uint256 deadline, bytes memory signature) private asActor {
        iSpoke.setUserPositionManagerWithSig(positionManager, user, approve, nonce, deadline, signature);
    }

    function iSpoke_setUsingAsCollateral(uint256 reserveId, bool usingAsCollateral, address onBehalfOf) private asActor {
        iSpoke.setUsingAsCollateral(reserveId, usingAsCollateral, onBehalfOf);
    }

    function iSpoke_setUsingAsCollateral(uint256 reserveId, bool usingAsCollateral) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 1);

        reserveId = between(reserveId, 0, reserveCount - 1);
        iSpoke.setUsingAsCollateral(reserveId, usingAsCollateral, _getActor());
    }

    function iSpoke_supply(uint256 reserveId, uint256 amount, address onBehalfOf) private asActor {
        iSpoke.supply(reserveId, amount, onBehalfOf);
    }

    function iSpoke_supply(uint256 reserveId, uint256 amount) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 1);

        reserveId = between(reserveId, 0, reserveCount - 1);
        amount = between(amount, 0, _max(reserveId));

        uint256 value0;
        uint256 value1;
        try iSpoke.supply(reserveId, amount, _getActor()) returns (uint256 tempValue0, uint256 tempValue1) {
            value0 = tempValue0;
            value1 = tempValue1;
        } catch (bytes memory err) {
            t(bytes4(err) == ISpoke.ReserveNotListed.selector
              || bytes4(err) == ISpoke.ReservePaused.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientAllowance.selector
              || bytes4(err) == IERC20Errors.ERC20InsufficientBalance.selector
              || bytes4(err) == WETH9.InsufficientAllowance.selector
              || bytes4(err) == WETH9.InsufficientBalance.selector
              || bytes4(err) == ISpoke.ReserveFrozen.selector
              || bytes4(err) == IHub.InvalidShares.selector
              || bytes4(err) == IHub.InvalidAmount.selector
              || bytes4(err) == IHub.SpokeNotActive.selector
              || bytes4(err) == IHub.AddCapExceeded.selector
              || bytes4(err) == IHub.SpokePaused.selector
              , "iSpoke_supply: DoS");
            require(false);
        }
    }

    function iSpoke_updateDynamicReserveConfig(uint256 reserveId, uint24 dynamicConfigKey, ISpoke.DynamicReserveConfig memory dynamicConfig) public asAdmin {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 0);

        reserveId = between(reserveId, 0, reserveCount - 1);

        uint24 dynamicConfigKey = uint24(between(dynamicConfigKey, 0, uint256(iSpoke.getReserve(reserveId).dynamicConfigKey)));
        iSpoke.updateDynamicReserveConfig(reserveId, dynamicConfigKey, dynamicConfig);
    }

    function iSpoke_updateLiquidationConfig(ISpoke.LiquidationConfig memory config) public asAdmin {
        iSpoke.updateLiquidationConfig(config);
    }

    function iSpoke_updatePositionManager(address positionManager, bool active) private asActor {
        iSpoke.updatePositionManager(positionManager, active);
    }

    function iSpoke_updateReserveConfig(uint256 reserveId, ISpoke.ReserveConfig memory params) public asAdmin {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 0);

        reserveId = between(reserveId, 0, reserveCount - 1);
        iSpoke.updateReserveConfig(reserveId, params);
    }

    function iSpoke_updateReservePriceSource(uint256 reserveId, address priceSource) private asActor {
        iSpoke.updateReservePriceSource(reserveId, priceSource);
    }

    function iSpoke_updateUserDynamicConfig(address onBehalfOf) private asActor {
        iSpoke.updateUserDynamicConfig(onBehalfOf);
    }

    function iSpoke_updateUserDynamicConfig() public asActor {
        iSpoke.updateUserDynamicConfig(_getActor());
    }

    function iSpoke_updateUserRiskPremium(address onBehalfOf) private asActor {
        iSpoke.updateUserRiskPremium(onBehalfOf);
    }

    function iSpoke_updateUserRiskPremium() public asActor {
        iSpoke.updateUserRiskPremium(_getActor());
    }

    function iSpoke_useNonce(uint192 key) private asActor {
        iSpoke.useNonce(key);
    }

    function iSpoke_withdraw(uint256 reserveId, uint256 amount, address onBehalfOf) private asActor {
        iSpoke.withdraw(reserveId, amount, onBehalfOf);
    }

    function iSpoke_withdraw(uint256 reserveId, uint256 amount) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 1);

        reserveId = between(reserveId, 0, reserveCount - 1);
        amount = between(amount, 0, _max(reserveId));

        uint256 value0;
        uint256 value1;
        try iSpoke.withdraw(reserveId, amount, _getActor()) returns (uint256 tempValue0, uint256 tempValue1) {
            value0 = tempValue0;
            value1 = tempValue1;
        } catch (bytes memory err) {
            t(bytes4(err) == ISpoke.Unauthorized.selector
              || bytes4(err) == ISpoke.ReserveNotListed.selector
              || bytes4(err) == ISpoke.ReservePaused.selector
              || bytes4(err) == IHub.InvalidAddress.selector
              || bytes4(err) == IHub.InvalidAmount.selector
              || bytes4(err) == IHub.SpokeNotActive.selector
              || bytes4(err) == IHub.SpokePaused.selector
              || bytes4(err) == IHub.InsufficientLiquidity.selector
              || bytes4(err) == ISpoke.HealthFactorBelowThreshold.selector
              || bytes4(err) == Ownable.OwnableUnauthorizedAccount.selector
              , "iSpoke_withdraw: DoS");
            require(false);
        }
    }
}