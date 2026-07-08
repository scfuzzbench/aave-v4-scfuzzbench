// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";
import {ISpoke} from "src/spoke/interfaces/ISpoke.sol";
import {LiquidationLogic} from "src/spoke/libraries/LiquidationLogic.sol";


// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    enum Operation {
        None,
        SetPrice
    }

    struct Vars {
        bool isAnyUserLiquidatable;
        Operation operation;
    }

    Vars internal _before;
    Vars internal _after;

    // Operation performed by the handler currently executing. Handlers set this in their
    // body (between __before and __after), and __snapshot copies it into the Vars — writing
    // _after.operation directly from a handler body would be wiped by __after's snapshot.
    Operation internal _currentOperation;

    mapping(uint256 assetId => uint256 maxDrawnIndexSeen) internal ghost_maxDrawnIndexSeen;
    mapping(uint256 assetId => uint256 maxSupplySharePriceAssetsSeen) internal ghost_maxSupplySharePriceAssetsSeen;
    mapping(uint256 assetId => uint256 maxSupplySharePriceSharesSeen) internal ghost_maxSupplySharePriceSharesSeen;

    /// === MODIFIERS === ///
    /// Prank admin and actor
    
    modifier asAdmin {
        vm.startPrank(ADMIN);
        __before();
        _;
        __after();
        vm.stopPrank();
    }

    modifier asActor {
        vm.startPrank(address(_getActor()));
        __before();
        _;
        __after();
        vm.stopPrank();
    }

    function __before() internal {
        _currentOperation = Operation.None;
        __snapshot(_before);
    }

    function __after() internal {
        __snapshot(_after);
    }

    function __snapshot(Vars storage vars) internal {
        vars.isAnyUserLiquidatable = false;
        vars.operation = _currentOperation;

        address[] memory actors = _getActors();
        for(uint256 i = 0; i < actors.length; i++) {
            address actor = actors[i];
            ISpoke.UserAccountData memory actorAccountData = iSpoke.getUserAccountData(actor);
            vars.isAnyUserLiquidatable = vars.isAnyUserLiquidatable || (actorAccountData.healthFactor < LiquidationLogic.HEALTH_FACTOR_LIQUIDATION_THRESHOLD);
        }
    }

    function _updateMonotonicGhosts(uint256 assetId) internal {
        uint256 currentDrawnIndex = iHub.getAssetDrawnIndex(assetId);
        if (currentDrawnIndex > ghost_maxDrawnIndexSeen[assetId]) {
            ghost_maxDrawnIndexSeen[assetId] = currentDrawnIndex;
        }

        uint256 addedShares = iHub.getAddedShares(assetId);
        if (addedShares > 0) {
            uint256 addedAssets = iHub.getAddedAssets(assetId);
            uint256 maxAssets = ghost_maxSupplySharePriceAssetsSeen[assetId];
            uint256 maxShares = ghost_maxSupplySharePriceSharesSeen[assetId];
            if (maxShares == 0 || maxAssets * addedShares <= addedAssets * maxShares) {
                ghost_maxSupplySharePriceAssetsSeen[assetId] = addedAssets;
                ghost_maxSupplySharePriceSharesSeen[assetId] = addedShares;
            }
        }
    }
}