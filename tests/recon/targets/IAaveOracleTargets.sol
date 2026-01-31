// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/spoke/interfaces/IAaveOracle.sol";
import "src/dependencies/chainlink/AggregatorV3Interface.sol";

abstract contract IAaveOracleTargets is
    BaseTargetFunctions,
    Properties
{
    /// Price can change by up to 100x or 1/100x (avoids Low likelihood scenarios in Audit Contest)
    uint256 private constant MAX_PRICE_CHANGE_FACTOR = 100;
    mapping(uint256 reserveId => uint256 originalPrice) private _originalPrices;
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function iAaveOracle_setReserveSource(uint256 reserveId, address source) private asActor {
        iAaveOracle.setReserveSource(reserveId, source);
    }

    function iAaveOracle_setPrice(uint256 reserveId, uint256 price) public asActor {
        uint256 reserveCount = iSpoke.getReserveCount();
        require(reserveCount > 0);

        reserveId = between(reserveId, 0, reserveCount - 1);

        uint256 basePrice = _getBasePrice(reserveId);

        price = between(price, basePrice / MAX_PRICE_CHANGE_FACTOR, basePrice * MAX_PRICE_CHANGE_FACTOR);
        _mockReservePrice(iSpoke, reserveId, price);
        _after.operation = Operation.SetPrice;
    }

    function _getBasePrice(uint256 reserveId) private returns (uint256 basePrice) {
        basePrice = _originalPrices[reserveId];
        if (basePrice == 0) {
            (, int256 answer,,,) = AggregatorV3Interface(iAaveOracle.getReserveSource(reserveId)).latestRoundData();
            basePrice = uint256(answer);
            _originalPrices[reserveId] = basePrice;
        }
    }
}
