// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import {Asserts} from "@chimera/Asserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";


// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    bool private assertionFailure = false;

    function setUp() public override {
        setup();
        assertionFailure = false;

        targetContract(address(this));
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }

    function gt(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(a > b, reason);
    }

    function gte(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(a >= b, reason);
    }

    function lt(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(a < b, reason);
    }

    function lte(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(a <= b, reason);
    }

    function eq(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(a == b, reason);
    }

    function t(bool b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        _recordAssertion(b, reason);
    }

    function between(uint256 value, uint256 low, uint256 high)
        internal
        virtual
        override(FoundryAsserts, Asserts)
        returns (uint256)
    {
        if (value < low || value > high) {
            uint256 ans = low + (value % (high - low + 1));
            return ans;
        }
        return value;
    }

    function between(int256 value, int256 low, int256 high)
        internal
        virtual
        override(FoundryAsserts, Asserts)
        returns (int256)
    {
        if (value < low || value > high) {
            int256 range = high - low + 1;
            int256 clamped = (value - low) % (range);
            if (clamped < 0) clamped += range;
            int256 ans = low + clamped;
            return ans;
        }
        return value;
    }

    function invariant_assertionFailure() public returns (bool) {
        if (assertionFailure) {
            // Mark test failure without reverting so the invariant runner detects it.
            fail();
            return false;
        }
        return true;
    }

    function _recordAssertion(bool ok, string memory reason) internal {
        if (ok) {
            return;
        }

        assertionFailure = true;

        if (bytes(reason).length != 0) {
            emit log(reason);
        }

    }
}
