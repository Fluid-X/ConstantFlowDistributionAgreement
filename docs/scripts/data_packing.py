
def encode(timestamp, flow_rate, deposit, owed_deposit):
    return (timestamp << 224) | (flow_rate << 128) | (deposit >> 32 << 64) | (owed_deposit >> 32)

def decode(word):
    timestamp = word >> 224
    flow_rate = (word >> 128) & (2**96 - 1)
    deposit = ((word >> 64) & (2**64 - 1)) << 32
    owed_deposit = (word & (2**64 - 1)) << 32
    return (timestamp, flow_rate, deposit, owed_deposit)

def main():
    timestamp = 1618876800
    flow_rate = 1234000000000000000000
    deposit = 5678000000000000000000
    owed_deposit = 9012000000000000000000

    word = encode(timestamp, flow_rate, deposit, owed_deposit)

    (recovered_timestamp, recovered_flow_rate, recovered_deposit, recovered_owed_deposit) = decode(word)

    print('DATA PACKING')
    print('timestamp:\t{}\t\t-> {}'.format(timestamp, recovered_timestamp))
    print('flow_rate:\t{}\t-> {}'.format(flow_rate, recovered_flow_rate))
    print('deposit:\t{}\t-> {}'.format(deposit, recovered_deposit))
    print('owed_deposit:\t{}\t-> {}'.format(owed_deposit, recovered_owed_deposit))
    print('\nfull encoded word:\t{}'.format(hex(word)))


main()
