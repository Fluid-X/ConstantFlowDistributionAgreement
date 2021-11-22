# Notes

General notes

## CFAv1 Precision Loss

When implemented in Python3, the data packing seems to lose precision on the
deposit and owedDeposit variables. Whether this is the case in Solidity or not..
:shrug:

To try this, from project root, run:
```
python3 docs/scripts/data_packing.py
```

Result:

| Name | Before Encoding | After Decoding |
| --- | --- | --- |
| timestamp | 1618876800 | 1618876800 |
| flow_rate | 1234000000000000000000 | 1234000000000000000000 |
| deposit | 5678000000000000000000 | 5677999999997114843136 |
| owed_deposit | 9012000000000000000000 | 9011999999997109075968 |

# CFDA Storage Slots

Initial:
```c
// INDEX DATA

struct FlowIndexData_Word_1 {
    uint32 timestamp;
    int96 flowRate;
    int64 deposit;
    int64 owedDeposit;
}

struct FlowIndexData_Word_2 {
    uint128 totalUnitsPending;
    uint128 totalUnitsApproved;
}

// SUBSCRIPTION DATA

struct FlowSubscriptionData_Word_1 {
    address publisher;
    uint32 RESERVED;
    uint32 indexId;
    uint32 subId;
}

struct FlowSubscriptionData_Word_2 {
    uint32 timestamp;
    int96 flowRate;
    uint128 units;
}
```

21.11.2021:
```c
// PUBLISHER DATA
struct IndexData_Word_1 {
    uint128 deposit;

}

struct IndexData_Word_2 {
    uint128 totalUnitsPending;
    uint128 totalUnitsApproved;
}

// SUBSCRIBER DATA
struct SubscriberData_Word_1 {
    address publisher;
    uin32 RESERVED;
    uint32 indexId;
    uint32 subId;
}

// FLOW DATA
// KEY = KECCAK256("AgreementData", agreementClass, fId)
// SSTORE(KEY, FlowData)
struct FlowData {
    uint32 timestamp;
    int96 flowRate;
    uint128 sum;
}
```
