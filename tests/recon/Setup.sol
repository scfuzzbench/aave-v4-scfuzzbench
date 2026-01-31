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
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor
    
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }
}
