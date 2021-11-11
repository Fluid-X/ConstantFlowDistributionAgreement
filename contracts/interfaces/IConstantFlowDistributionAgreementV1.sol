// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.7.0;

import {ISuperAgreement} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperAgreement.sol";
import {ISuperfluidToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluidToken.sol";

abstract contract IConstantFlowDistributionAgreementV1 is ISuperAgreement {
    event IndexCreated(
        ISuperfluidToken indexed token,
        address indexed publisher,
        uint32 indexId,
        bytes userData
    );

    // NOTE this likely won't be needed. will update
    // event IndexUpdated(
    //     ISuperfluidToken indexed token,
    //     address indexed publisher,
    //     uint32 indexed indexId,
    //     uint128 oldIndexValue,
    //     uint128 newIndexvalue,
    //     uint128 totalUnitsPending,
    //     uint128 totalUnitsApproved,
    //     bytes userData
    // );

    event FlowUpdated(
        ISuperfluidToken indexed token,
        address indexed publisher,
        uint32 indexed indexId,
        int96 publisherFlowRate,
        int256 totalPublisherFlowRate,
        bytes userData
    );

    event IndexSubscribed(
        ISuperfluidToken indexed token,
        address indexed publisher,
        uint32 indexed indexId,
        address subscriber,
        bytes userData
    );

    event SubscriptionApproved(
        ISuperfluidToken indexed token,
        address indexed subscriber,
        address publisher,
        uint32 indexId,
        bytes userData
    );

    event IndexUnsubscribed(
        ISuperfluidToken indexed token,
        address indexed publisher,
        address indexed indexId,
        address subscriber,
        bytes userData
    );

    event SubscriptionRevoked(
        ISuperfluidToken indexed token,
        address indexed subscriber,
        address publisher,
        uint32 indexId,
        bytes userData
    );

    event IndexUnitsUpdated(
        ISuperfluidToken indexed token,
        address indexed publisher,
        uint32 indexed indexId,
        address subscriber,
        uint128 units,
        bytes userData
    );

    event SubscriptionUnitsUpdated(
        ISuperfluidToken indexed token,
        address indexed subscriber,
        address publisher,
        uint32 indexId,
        uint128 units,
        bytes userData
    );

    /// @dev ISuperAgreement.agreementType implementation
    function agreementType() external pure override returns (bytes32) {
        return
            keccak256(
                "org.superfluid-finance.agreements.ConstantFlowDistributionAgreement.v1"
            );
    }

    // ----- ----- -----
    // Index Operations
    // ----- ----- -----

    /// @dev Create a new index for the publisher
    /// @param token Super token address
    /// @param indexId Id of the index
    function createIndex(
        ISuperfluidToken token,
        uint32 indexId,
        bytes calldata ctx
    ) external virtual returns (bytes memory newCtx);

    /// @dev Query index data
    /// @param token Super token address
    /// @param publisher Publisher of index
    /// @param indexId Id of the index
    // /// @param timestamp Time for real time index value calculation
    /// @return exist Does index exist
    /// @return realTimeIndexValue Value of index at given timestamp
    /// @return totalUnitsApproved Units approved for the index
    /// @return totalUnitsPending Units pending approval for the index
    function getIndex(
        ISuperfluidToken token,
        address publisher,
        uint32 indexId
    )
        external
        view
        virtual
        returns (
            // uint256 timestamp
            bool exist,
            uint128 realTimeIndexValue,
            uint128 totalUnitsApproved,
            uint128 totalUnitsPending
        );

    function calculateDistributionFlowRate(
        ISuperfluidToken token,
        address publisher,
        uint32 indexId,
        uint256 amount
    )
        external
        view
        virtual
        returns (uint256 actualAmount, uint128 newIndexValue);

    // TODO the rest of the owl
}
