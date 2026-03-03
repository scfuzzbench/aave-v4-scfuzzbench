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
    }

    function _isAssertion(string memory reason) internal pure returns (bool) {
        return
            bytes(reason).length >= 3 && bytes(reason)[0] == "!" && bytes(reason)[1] == "!" && bytes(reason)[2] == "!";
    }

    function gt(uint256 a, uint256 b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(a > b, reason);
        } else {
            super.gt(a, b, reason);
        }
    }

    function gte(uint256 a, uint256 b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(a >= b, reason);
        } else {
            super.gte(a, b, reason);
        }
    }

    function lt(uint256 a, uint256 b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(a < b, reason);
        } else {
            super.lt(a, b, reason);
        }
    }

    function lte(uint256 a, uint256 b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(a <= b, reason);
        } else {
            super.lte(a, b, reason);
        }
    }

    function eq(uint256 a, uint256 b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(a == b, reason);
        } else {
            super.eq(a, b, reason);
        }
    }

    function t(bool b, string memory reason) internal virtual override(FoundryAsserts, Asserts) {
        if (_isAssertion(reason)) {
            _recordAssertion(b, reason);
        } else {
            super.t(b, reason);
        }
    }

    function _recordAssertion(bool ok, string memory reason) internal {
        if (ok) {
            return;
        }

        assertionFailures[reason] = true;
    }

<<<<<<< HEAD
    function invariant_assertion_failure_iSpoke_withdraw_ASSERTION_WITHDRAW_DOS() public view {
=======
    function invariant_assertion_failure_iSpoke_withdraw_ASSERTION_WITHDRAW_DOS() public returns (bool) {
>>>>>>> bc9ca744 (test(recon): normalize assertion handler and wrapper naming)
        assertTrue(!assertionFailures[ASSERTION_WITHDRAW_DOS], ASSERTION_WITHDRAW_DOS);
        return true;
    }

<<<<<<< HEAD
    function invariant_assertion_failure_iSpoke_liquidationCall_ASSERTION_LIQUIDATION_CALL_DOS() public view {
=======
    function invariant_assertion_failure_iSpoke_liquidationCall_ASSERTION_LIQUIDATION_CALL_DOS() public returns (bool) {
>>>>>>> bc9ca744 (test(recon): normalize assertion handler and wrapper naming)
        assertTrue(!assertionFailures[ASSERTION_LIQUIDATION_CALL_DOS], ASSERTION_LIQUIDATION_CALL_DOS);
        return true;
    }

    function invariant_assertion_failure_iSpoke_repay_ASSERTION_REPAY_DOS() public returns (bool) {
        assertTrue(!assertionFailures[ASSERTION_REPAY_DOS], ASSERTION_REPAY_DOS);
        return true;
    }

    function invariant_assertion_failure_iSpoke_supply_ASSERTION_SUPPLY_DOS() public returns (bool) {
        assertTrue(!assertionFailures[ASSERTION_SUPPLY_DOS], ASSERTION_SUPPLY_DOS);
        return true;
    }

    function invariant_assertion_failure_iHub_mintFeeShares_ASSERTION_MINT_FEE_SHARES_PPS_CHANGE() public returns (bool) {
        assertTrue(!assertionFailures[ASSERTION_MINT_FEE_SHARES_PPS_CHANGE], ASSERTION_MINT_FEE_SHARES_PPS_CHANGE);
        return true;
    }

    function invariant_assertion_failure_assert_canary_ASSERTION_CANARY() public returns (bool) {
        assertTrue(!assertionFailures[ASSERTION_CANARY], ASSERTION_CANARY);
        return true;
    }

    function invariant_noop() public returns (bool) {
        return true;
    }
}
