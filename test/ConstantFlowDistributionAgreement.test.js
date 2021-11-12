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
			flowRate: "1234000000000000000000",
			deposit: "5678000000000000000000",
			owedDeposit: "9012000000000000000000",
			totalUnitsPending: "3456000000000000000000",
			totalUnitsApproved: "7890000000000000000000"
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
})
