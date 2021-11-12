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

	event FlowUpdated(
		ISuperfluidToken indexed token,
		address indexed publisher,
		uint32 indexed indexId,
		int96 publisherFlowRate,
		int256 totalPublisherFlowRate,
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
	// INDEX OPERATIONS
	// ----- ----- -----

	/// @dev Create a new index for the publisher
	/// @param token Super token address
	/// @param indexId Index Id
	function createIndex(
		ISuperfluidToken token,
		uint32 indexId,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

	/// @dev Query index data
	/// @param token Super token address
	/// @param publisher Publisher of index
	/// @param indexId Index Id
	/// @return exist Does index exist
    /// @return timestamp Timestamp of last flow rate update
    /// @return flowRate Flow rate
    /// @return deposit Flow deposit amount
    /// @return owedDeposit Flow deposit amount owed
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
			bool exist,
			uint256 timestamp,
            int96 flowRate,
            uint256 deposit,
            uint256 owedDeposit,
			uint128 realTimeIndexValue,
			uint128 totalUnitsApproved,
			uint128 totalUnitsPending
		);

    /// @dev Calculate actual flow rate
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
    /// @param amount Amound of tokens desired to be streamed
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

    // ----- ----- -----
    // SUBSCRIPTION OPERATIONS
    // ----- ----- -----

    /// @dev Approves subscription of an index
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
	function approveSubscription(
		ISuperfluidToken token,
		address publisher,
		uint32 indexId,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

    /// @dev Revoke subscription of an index
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
	function revokeSubscription(
		ISuperfluidToken token,
		address publisher,
		uint32 indexId,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

    /// @dev Update number of units of a subscription
    /// creates subscription if does not exist
    /// @param token Super token address.
    /// @param indexId Index Id
    /// @param subscriber Index subscriber
    /// @param units Number of subscription units to issue
	function updateSubscription(
		ISuperfluidToken token,
		uint32 indexId,
		address subscriber,
		uint128 units,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

    /// @dev Get subscription data
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
    /// @param subscriber Index subscriber
    /// @return exist Does subscription exist
    /// @return approved Is subscription approved
    /// @return units Units of subscription
    /// @return pendingDistribution Amount of tokens awaiting subscription approval
	function getSubscription(
		ISuperfluidToken token,
		address publisher,
		uint32 indexId,
		address subscriber
	)
		external
		view
		virtual
		returns (
			bool exist,
			bool approved,
			uint128 units,
			uint256 pendingDistribution
		);

    /// @dev Get subscription data by agreement ID
    /// @param token Super token address
    /// @param agreementId Agreement Id
    /// @return publisher Index publisher
    /// @return indexId Index Id
    /// @return approved Is subscription approved
    /// @return units Units of subscription
    /// @return pendingDistribution Amount of tokens awaiting subscription approval
	function getSubscriptionByID(ISuperfluidToken token, bytes32 agreementId)
		external
		view
		virtual
		returns (
			address publisher,
			uint32 indexId,
			bool approved,
			uint128 units,
			uint256 pendingDistribution
		);

    /// @dev List subscriptions of an address
    /// @param token Super token address
    /// @param subscriber Subscriber address
    /// @return publishers Subscription index publishers
    /// @return indexIds Index Ids of subscriptions
    /// @return unitsList Units of subscriptions
	function listSubscriptions(ISuperfluidToken token, address subscriber)
		external
		view
		virtual
		returns (
			address[] memory publishers,
			uint32[] memory indexIds,
			uint128 unitsList
		);

    /// @dev Delete subscription of an address
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
    /// @param subscriber Subscriber address
	function deleteSubscription(
		ISuperfluidToken token,
		address publisher,
		uint32 indexId,
		address subscriber,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

    /// @dev Claim pending distributions
    /// @param token Super token address
    /// @param publisher Index publisher
    /// @param indexId Index Id
    /// @param subscriber Subscriber address
	function claim(
		ISuperfluidToken token,
		address publisher,
		uint32 indexId,
		address subscriber,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

	// ----- ----- -----
	// FLOW OPERATIONS
	// ----- ----- -----

    /// @dev Get max flow rate permitted given a deposit amount
    /// @param token Super token address
    /// @param deposit Deposit amount
	function getMaximumFlowRateFromDeposit(
		ISuperfluidToken token,
		uint256 deposit
	) external view virtual returns (int96 flowRate);

    /// @dev Get deposit required for a given flow rate
    /// @param token Super token address
    /// @param flowRate Desired flow rate
	function getDepositRequiredForFlowRate(
		ISuperfluidToken token,
		int96 flowRate
	) external view virtual returns (uint256 deposit);

    /// @dev Create a flow from a publisher to subscribers
    /// @param token Super token address
    /// @param indexId Index Id
    /// @param flowRate Publisher flow rate
	function createFlow(
		ISuperfluidToken token,
        uint32 indexId,
		int96 flowRate,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);

    /// @dev Update flow rate from a publisher to subscribers
    /// @param token Super token address
    /// @param indexId Index id
    /// @param flowRate Updated flow rate
	function updateFlow(
		ISuperfluidToken token,
        uint32 indexId,
		int96 flowRate,
		bytes calldata ctx
	) external virtual returns (bytes memory newCtx);
    
    /// @dev Get flow info for an account and token
    /// @param token Super token address
    /// @param account Account address
    /// @return timestamp Last updated timestamp
    /// @return flowRate Per second flow rate
    /// @return deposit Account deposit
    /// @return owedDeposit Account deposit owed
    function getAccountFlowInfo(
        ISuperfluidToken token,
        address account
    )
        external
        view
        virtual
        returns (
            uint256 timestamp,
            int96 flowRate,
            uint256 deposit,
            uint256 owedDeposit
        );

    /// @dev Get net flow rate of a token given an account
    /// @param token Super token address
    /// @param account Account address
    function getNetFlow(
        ISuperfluidToken token,
        address account
    )
        external
        view
        virtual
        returns (int96 flowRate);

    /// @dev Delete flow from a publisher
    /// @param token Super token address
    /// @param publisher Index publisher, Flow sender
    /// @param indexId Index id
    /// NOTE: Publisher may stop stream, Sentinel may stop stream IF INSOLVENT
    /// Subscribers may NOT stop stream, as they can just revoke subscription
    function deleteFlow(
        ISuperfluidToken token,
        address publisher,
        address indexId,
        bytes calldata ctx
    ) external virtual returns (bytes memory newCtx);
}
