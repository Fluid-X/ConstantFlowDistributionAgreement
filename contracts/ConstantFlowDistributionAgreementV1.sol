// SPDX-License-Identifier: AGPLv3
pragma solidity 0.7.6;

// import {IConstantFlowDistributionAgreementV1, ISuperfluidToken} from "./interfaces/IConstantFlowDistributionAgreementV1.sol";
// import {ISuperfluid, ISuperfluidGovernance, ISuperApp, SuperAppDefinitions} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
// import {AgreementBase} from "@superfluid-finance/ethereum-contracts/contracts/agreements/AgreementBase.sol";
// import {UInt128SafeMath} from "@superfluid-finance/ethereum-contracts/contracts/utils/UInt128SafeMath.sol";
// import {SignedSafeMath} from "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
// import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
// import {AgreementLibrary} from "@superfluid-finance/ethereum-contracts/contracts/agreements/AgreementLibrary.sol";
// import {SlotsBitmapLibrary} from "@superfluid-finance/ethereum-contracts/contracts/agreements/SlotsBitmapLibrary.sol";

contract ConstantFlowDistributionAgreementV1 {
	// is AgreementBase, IConstantFlowDistributionAgreementV1
	// struct packing
	struct FlowIndexData {
		uint256 deposit; // stored as int96, lower 32 bits clipped to 0
		uint256 owedDeposit; // stored as int96, lower 32 bits clipped to 0
		uint128 totalUnitsPending;
		uint128 totalUnitsApproved;
		uint256 timestamp; // stored as uint32
		int96 flowRate;
	}

	// struct packing
	struct FlowSubscriptionData {
		uint32 subId;
		int96 flowRate;
		uint128 units;
		uint32 indexId;
		address publisher;
		uint256 timestamp; // stored as uint32
	}

	function encodeFlowIndexDataTest(
		uint256 timestamp,
		int96 flowRate,
		uint256 deposit,
		uint256 owedDeposit,
		uint128 totalUnitsPending,
		uint128 totalUnitsApproved
	) external pure returns (bytes32[] memory data) {
		data = _encodeFlowIndexData(
			FlowIndexData({
				timestamp: timestamp,
				flowRate: flowRate,
				deposit: deposit,
				owedDeposit: owedDeposit,
				totalUnitsPending: totalUnitsPending,
				totalUnitsApproved: totalUnitsApproved
			})
		);
	}

    function decodeFlowIndexDataTest(
        uint256
    ) external pure returns ()

	function encodeFlowSubscriptionDataTest(
		uint32 subId,
		int96 flowRate,
		uint128 units,
		uint32 indexId,
		address publisher,
		uint256 timestamp
	) external pure returns (bytes32[] memory data) {
		return
			_encodeFlowSubscriptionData(
				FlowSubscriptionData({
					subId: subId,
					publisher: publisher,
					indexId: indexId,
					timestamp: timestamp,
					flowRate: flowRate,
					units: units
				})
			);
	}

	// DATA PACKING
	// WORD 1: | timestamp | flowRate | deposit | owedDeposit |
	//         | 32b       | 96b      | 64b     | 64b         |
	// WORD 2: | totalUnitsPending | totalUnitsApproved |
	//         | 128b              | 128b               |

	function _encodeFlowIndexData(FlowIndexData memory fidata)
		private
		pure
		returns (bytes32[] memory data)
	{
		data = new bytes32[](2);
		data[0] = bytes32(
			((uint256(fidata.timestamp)) << 224) |
				((uint256(uint96(fidata.flowRate)) << 128)) |
				((uint256(fidata.deposit) >> 32) << 64) |
				(uint256(fidata.owedDeposit) >> 32)
		);
		data[1] = bytes32(
			(uint256(fidata.totalUnitsPending) << 128) |
				(uint256(fidata.totalUnitsApproved))
		);
	}

	function _decodeFlowIndexData(uint256 word)
		internal
		pure
		returns (bool exist, FlowIndexData memory fidata)
	{
		exist = word > 0;
		if (exist) {
			fidata.timestamp = uint32(word >> 224);
			fidata.flowRate = int96((word >> 128) & uint256(type(uint96).max));
			fidata.deposit = ((word >> 64) & uint256(type(uint64).max)) << 32; // recover clipped bits
			fidata.owedDeposit = (word & uint256(type(uint64).max)) << 32; // recover clipped bits
		}
	}

	// DATA PACKING:
	// WORD 1: | publisher | RESERVED | indexId | subId |
	//         | 160b      | 32b      | 32b     | 32b   |
	// WORD 2: | timestamp | flowRate | units |
	//         | 32b       | 96b      | 128b  |
	function _encodeFlowSubscriptionData(FlowSubscriptionData memory fsdata)
		private
		pure
		returns (bytes32[] memory data)
	{
		data = new bytes32[](2);
		data[0] = bytes32(
			(uint256(fsdata.publisher) << (12 * 8)) |
				(uint256(fsdata.indexId) << 32) |
				uint256(fsdata.subId)
		);
		data[1] = bytes32(
			(uint256(fsdata.timestamp) << 224) |
				(uint256((uint96(fsdata.flowRate)) << 128)) |
				uint256(fsdata.units)
		);
	}

	function _decodeFlowSubscriptionData(uint256[2] memory words)
		internal
		pure
		returns (bool exist, FlowSubscriptionData memory fsdata)
	{
		exist = words[0] > 0;
		uint256 a = words[0];
		uint256 b = words[1];
		if (exist) {
			fsdata.publisher = address(uint160(a >> (12 * 8)));
			fsdata.indexId = uint32((a >> 32) & type(uint32).max);
			fsdata.subId = uint32(a & type(uint32).max);
			fsdata.timestamp = uint32(b);
		}
	}
}
