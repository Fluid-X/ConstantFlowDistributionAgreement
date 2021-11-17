const { web3tx } = require("@decentral.ee/web3-helpers")
const ConstantFlowDistributionAgreementV1 = artifacts.require(
	"ConstantFlowDistributionAgreementV1"
)

contract("ConstantFlowDistributionAgreementV1", accounts => {
	let CFDAv1

	beforeEach(async () => {
		CFDAv1 = await web3tx(
			ConstantFlowDistributionAgreementV1.new,
			"CFDAv1"
		)()
	})

	it("encode FlowIndexData", async () => {
		const flowIndexData = {
			timestamp: 1618876800,
			flowRate: "1000000000000000000",
			deposit: "14400000000000000000000",
			owedDeposit: "0",
			totalUnitsPending: "1000",
			totalUnitsApproved: "1000"
		}

		const encodedFlowIndexData = await CFDAv1.encodeFlowIndexDataTest.call(
			flowIndexData.timestamp,
			flowIndexData.flowRate,
			flowIndexData.deposit,
			flowIndexData.owedDeposit,
			flowIndexData.totalUnitsPending,
			flowIndexData.totalUnitsApproved
		)

		console.log({ encodedFlowIndexData })
	})

	it("encode FlowSubscriptionData", async () => {
		const flowSubscriptionData = {
			subscriptionId: 15,
			flowRate: "1000000000000000000",
			units: 10,
			indexId: 24,
			publisher: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
			timestamp: 1618876800
		}

		const encodeFlowSubscriptionData =
			await CFDAv1.encodeFlowSubscriptionDataTest.call(
				flowSubscriptionData.subscriptionId,
				flowSubscriptionData.flowRate,
				flowSubscriptionData.units,
				flowSubscriptionData.indexId,
				flowSubscriptionData.publisher,
				flowSubscriptionData.timestamp
			)

		console.log({ encodeFlowSubscriptionData })
	})
})
