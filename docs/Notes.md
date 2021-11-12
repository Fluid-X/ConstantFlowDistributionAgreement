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

