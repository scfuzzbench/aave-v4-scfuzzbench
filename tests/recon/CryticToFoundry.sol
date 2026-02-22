// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import {Asserts} from "@chimera/Asserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";


// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    mapping(string => bool) private assertionFailures;

    function setUp() public override {
        setup();

        targetContract(address(this));
        targetSender(address(0x10000));
        targetSender(address(0x20000));
        targetSender(address(0x30000));
        // Canary assertion failures are recorded when the fuzzer exercises canary checks.
    }

    function _isAssertion(string memory reason) internal pure returns (bool) {
        return bytes(reason).length >= 3 &&
            bytes(reason)[0] == '!' &&
            bytes(reason)[1] == '!' &&
            bytes(reason)[2] == '!';
    }

    function gt(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(a > b, reason);
        }
        else {
            super.gt(a, b, reason);
        }
    }

    function gte(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(a >= b, reason);
        }
        else {
            super.gte(a, b, reason);
        }
    }

    function lt(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(a < b, reason);
        }
        else {
            super.lt(a, b, reason);
        }
    }

    function lte(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(a <= b, reason);
        }
        else {
            super.lte(a, b, reason);
        }
    }

    function eq(uint256 a, uint256 b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(a == b, reason);
        }
        else {
            super.eq(a, b, reason);
        }
    }

    function t(bool b, string memory reason)
        internal
        virtual
        override(FoundryAsserts, Asserts)
    {
        if(_isAssertion(reason)) {
            _recordAssertion(b, reason);
        }
        else {
            super.t(b, reason);
        }
    }

    function _recordAssertion(bool ok, string memory reason) internal {
        if (ok) {
            return;
        }

        assertionFailures[reason] = true;
    }

    function invariant_assertion_failure_WITHDRAW_DOS() public view {
        assertTrue(!assertionFailures[ASSERTION_WITHDRAW_DOS], ASSERTION_WITHDRAW_DOS);
    }

    function invariant_assertion_failure_LIQUIDATION_CALL_DOS() public view {
        assertTrue(!assertionFailures[ASSERTION_LIQUIDATION_CALL_DOS], ASSERTION_LIQUIDATION_CALL_DOS);
    }

    function invariant_assertion_failure_REPAY_DOS() public view {
        assertTrue(!assertionFailures[ASSERTION_REPAY_DOS], ASSERTION_REPAY_DOS);
    }

    function invariant_assertion_failure_SUPPLY_DOS() public view {
        assertTrue(!assertionFailures[ASSERTION_SUPPLY_DOS], ASSERTION_SUPPLY_DOS);
    }

    function invariant_assertion_failure_MINT_FEE_SHARES_PPS_CHANGE() public view {
        assertTrue(!assertionFailures[ASSERTION_MINT_FEE_SHARES_PPS_CHANGE], ASSERTION_MINT_FEE_SHARES_PPS_CHANGE);
    }

    function invariant_assertion_failure_CANARY() public {
        invariant_canary_assertion_failure();
        assertTrue(!assertionFailures[ASSERTION_CANARY_ASSERTION_FAILURE], ASSERTION_CANARY_ASSERTION_FAILURE);
    }

    function invariant_noop() public view {

    }
}
