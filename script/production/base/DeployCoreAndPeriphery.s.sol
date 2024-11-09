// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ScriptUtils} from "../../utils/ScriptUtils.s.sol";
import {Integrations} from "../../01_Integrations.s.sol";
import {PeripheryFactories} from "../../02_PeripheryFactories.s.sol";
import {EVaultImplementation} from "../../05_EVaultImplementation.s.sol";
import {EVaultFactory} from "../../06_EVaultFactory.s.sol";
import {Lenses} from "../../08_Lenses.s.sol";
import {EVKPerspectives} from "../../09_Perspectives.s.sol";
import {Swap} from "../../10_Swap.s.sol";
import {FeeFlow} from "../../11_FeeFlow.s.sol";
import {FactoryGovernorDeployer} from "../../12_FactoryGovernor.s.sol";
import {TermsOfUseSignerDeployer} from "../../13_TermsOfUseSigner.s.sol";
import {Base} from "evk/EVault/shared/Base.sol";
import {ProtocolConfig} from "evk/ProtocolConfig/ProtocolConfig.sol";

contract DeployCoreAndPeriphery is ScriptUtils {
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant EULER_DAO = 0x1e13B0847808045854Ddd908F2d770Dc902Dcfb8;
    address internal constant PERMIT2_ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address internal constant UNISWAP_ROUTER_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant UNISWAP_ROUTER_V3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    uint256 internal constant FEE_FLOW_INIT_PRICE = 1e18;
    address internal constant FEE_FLOW_PAYMENT_TOKEN = WETH;
    address internal constant FEE_FLOW_PAYMENT_RECEIVER = EULER_DAO;
    uint256 internal constant FEE_FLOW_EPOCH_PERIOD = 14 days;
    uint256 internal constant FEE_FLOW_PRICE_MULTIPLIER = 2e18;
    uint256 internal constant FEE_FLOW_MIN_INIT_PRICE = 1e6;

    function run()
        public
        returns (
            CoreAddresses memory coreAddresses,
            PeripheryAddresses memory peripheryAddresses,
            LensAddresses memory lensAddresses
        )
    {
        // deply integrations
        {
            Integrations deployer = new Integrations();
            (
                coreAddresses.evc,
                coreAddresses.protocolConfig,
                coreAddresses.sequenceRegistry,
                coreAddresses.balanceTracker,
                coreAddresses.permit2
            ) = deployer.deploy(PERMIT2_ADDRESS);
        }
        // deploy periphery factories
        {
            PeripheryFactories deployer = new PeripheryFactories();
            (
                peripheryAddresses.oracleRouterFactory,
                peripheryAddresses.oracleAdapterRegistry,
                peripheryAddresses.externalVaultRegistry,
                peripheryAddresses.kinkIRMFactory,
                peripheryAddresses.irmRegistry
            ) = deployer.deploy(coreAddresses.evc);
        }
        // deploy EVault implementation
        {
            EVaultImplementation deployer = new EVaultImplementation();
            Base.Integrations memory integrations = Base.Integrations({
                evc: coreAddresses.evc,
                protocolConfig: coreAddresses.protocolConfig,
                sequenceRegistry: coreAddresses.sequenceRegistry,
                balanceTracker: coreAddresses.balanceTracker,
                permit2: coreAddresses.permit2
            });
            (, coreAddresses.eVaultImplementation) = deployer.deploy(integrations);
        }
        // deploy EVault factory
        {
            EVaultFactory deployer = new EVaultFactory();
            coreAddresses.eVaultFactory = deployer.deploy(coreAddresses.eVaultImplementation);
        }
        // deploy factory governor
        {
            FactoryGovernorDeployer deployer = new FactoryGovernorDeployer();
            coreAddresses.eVaultFactoryGovernor = deployer.deploy();
        }
        // deploy swapper
        {
            Swap deployer = new Swap();
            (peripheryAddresses.swapper, peripheryAddresses.swapVerifier) =
                deployer.deploy(UNISWAP_ROUTER_V2, UNISWAP_ROUTER_V3);
        }
        // deploy fee flow
        {
            FeeFlow deployer = new FeeFlow();
            peripheryAddresses.feeFlowController = deployer.deploy(
                coreAddresses.evc,
                FEE_FLOW_INIT_PRICE,
                FEE_FLOW_PAYMENT_TOKEN,
                FEE_FLOW_PAYMENT_RECEIVER,
                FEE_FLOW_EPOCH_PERIOD,
                FEE_FLOW_PRICE_MULTIPLIER,
                FEE_FLOW_MIN_INIT_PRICE
            );
        }
        // additional fee flow configuration
        {
            startBroadcast();
            ProtocolConfig(coreAddresses.protocolConfig).setFeeReceiver(peripheryAddresses.feeFlowController);
            stopBroadcast();
        }
        // deploy perspectives
        {
            EVKPerspectives deployer = new EVKPerspectives();
            address[] memory perspectives = deployer.deploy(
                coreAddresses.eVaultFactory,
                peripheryAddresses.oracleRouterFactory,
                peripheryAddresses.oracleAdapterRegistry,
                peripheryAddresses.externalVaultRegistry,
                peripheryAddresses.kinkIRMFactory,
                peripheryAddresses.irmRegistry
            );

            peripheryAddresses.evkFactoryPerspective = perspectives[0];
            peripheryAddresses.governedPerspective = perspectives[1];
            peripheryAddresses.escrowedCollateralPerspective = perspectives[2];
            peripheryAddresses.eulerUngoverned0xPerspective = perspectives[3];
            peripheryAddresses.eulerUngovernedNzxPerspective = perspectives[4];
        }
        // deploy terms of use signer
        {
            TermsOfUseSignerDeployer deployer = new TermsOfUseSignerDeployer();
            peripheryAddresses.termsOfUseSigner = deployer.deploy(coreAddresses.evc);
        }
        // deploy lenses
        {
            Lenses deployer = new Lenses();
            address[] memory lenses =
                deployer.deploy(peripheryAddresses.oracleAdapterRegistry, peripheryAddresses.kinkIRMFactory);

            lensAddresses.accountLens = lenses[0];
            lensAddresses.oracleLens = lenses[1];
            lensAddresses.irmLens = lenses[2];
            lensAddresses.utilsLens = lenses[3];
            lensAddresses.vaultLens = lenses[4];
            lensAddresses.eulerEarnVaultLens = lenses[5];
        }

        // save results
        vm.writeJson(serializeCoreAddresses(coreAddresses), getInputConfigFilePath("CoreAddresses.json"));
        vm.writeJson(serializePeripheryAddresses(peripheryAddresses), getInputConfigFilePath("PeripheryAddresses.json"));
        vm.writeJson(serializeLensAddresses(lensAddresses), getInputConfigFilePath("LensAddresses.json"));

        return (coreAddresses, peripheryAddresses, lensAddresses);
    }
}