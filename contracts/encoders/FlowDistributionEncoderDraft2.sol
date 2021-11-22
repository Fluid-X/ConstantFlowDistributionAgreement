// SPDX-License-Identifier: AGPLv3
pragma solidity 0.7.6;

import {ISuperfluidToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluidToken.sol";

contract FlowDistributionEncoderDraft2 {
	// ----- ----- -----
	// STRUCTS
	// ----- ----- -----

	// DATA LOADED FOR INDEX AND SUBSCRIBER
	// STORED AT keccak256(token,publisher,indexId)
	struct FlowData {
		uint32 timestamp;
		int96 flowRate;
		uint128 sum;
	}

	// DATA LOADED FOR INDEX
	// STORED AT add(keccak256(token,publisher,indexId),1)
	struct IndexData {
		uint128 totalUnits;
		uint128 deposit;
	}

	// DATA LOADED FOR SUBSCRIBER
	// STORED AT keccak256()
	struct SubscriberData {
		uint32 indexId;
		uint32 subId;
		address publisher;
	}

	// ----- ----- -----
	// DATA GETTERS
	// ----- ----- -----

	function _getIndexData(ISuperfluidToken token, bytes32 pId)
		internal
		view
		returns (
			bool exist,
			IndexData memory idata,
			FlowData memory fdata
		)
	{
		bytes32[] memory adata = token.getAgreementData(address(this), pId, 2);
		exist = adata[0] > 0;
		if (exist) {
            // flow data is at zero slot. also used in _getSubscriberData
            fdata = _decodeFlowData(uint256(adata[0]));
            idata = _decodeIndexData(uint256(adata[1]));
        }
	}

    function _getSubscriberData(ISuperfluidToken token, bytes32 sId)
        internal
        view
        returns (
            bool exist,
            SubscriberData memory sdata,
            FlowData memory fdata
        )
    {
        bytes32[] memory subdata = token.getAgreementData(address(this), sId, 1);
        exist = subdata[0] > 0;
        if (exist) {
            sdata = _decodeSubscriberData(uint256(subdata[0]));
            bytes32 pId = _getPublisherId(sdata.publisher, sdata.indexId);
            bytes32[] memory adata = token.getAgreementData(address(this), pId, 1);
            fdata = _decodeFlowData(uint256(adata[0]));
        }
    }

	// ----- ----- -----
	// ID GENERATORS
	// ----- ----- -----

	function _getPublisherId(address publisher, uint32 indexId)
		internal
		pure
		returns (bytes32 pId)
	{
		return keccak256(abi.encodePacked("publisher", publisher, indexId));
	}

	function _getSubscriptionId(address subscriber, bytes32 pId)
		internal
		pure
		returns (bytes32 subscriptionId)
	{
		return keccak256(abi.encodePacked("subscription", subscriber, pId));
	}

	// ----- ----- -----
	// ENCODERS
	// ----- ----- -----

	function _encodeFlowData(FlowData memory fdata)
		internal
		pure
		returns (bytes32[] memory data)
	{
		data = new bytes32[](1);
		data[0] = bytes32(
			(uint256(fdata.timestamp) << 224) |
				(uint256(uint96(fdata.flowRate)) << 128) |
				uint256(fdata.sum)
		);
	}

	function _encodeIndexdata(IndexData memory idata)
		internal
		pure
		returns (bytes32[] memory data)
	{
		data = new bytes32[](1);
		data[0] = bytes32(
			(uint256(idata.deposit) << 128) | uint256(idata.totalUnits)
		);
	}

	function _encodeSubscriberData(SubscriberData memory sdata)
		internal
		pure
		returns (bytes32[] memory data)
	{
		data = new bytes32[](1);
		data[0] = bytes32(
			(uint256(sdata.publisher) << (12 * 8)) |
				(uint256(sdata.indexId) << 32) |
				uint256(sdata.subId)
		);
	}

	// ----- ----- -----
	// DECODERS
	// ----- ----- -----

	function _decodeFlowData(uint256 word)
		internal
		pure
		returns (FlowData memory fdata)
	{
		fdata.timestamp = uint32(word >> 224);
		fdata.flowRate = int96((word >> 128) & uint256(type(int96).max));
		fdata.sum = uint128(word & uint256(type(uint128).max));
	}

	function _decodeIndexData(uint256 word)
		internal
		pure
		returns (IndexData memory idata)
	{
        idata.totalUnits = uint128(word >> 128);
        idata.deposit = uint128(word & type(uint128).max);
    }

    function _decodeSubscriberData(uint256 word)
        internal
        pure
        returns (SubscriberData memory sdata)
    {
        sdata.publisher = address(uint160(word >> (12 * 8)));
        sdata.indexId = uint32((word >> 32) & type(uint32).max);
        sdata.subId = uint32(word & type(uint32).max);
    }
}
