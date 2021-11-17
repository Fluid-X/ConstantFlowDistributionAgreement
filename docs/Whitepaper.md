# Constant Flow Distribution Agreement

A Superfluid primitive proposal for facilitating a one-to-many token stream.

## Abstract

At the time of writing, Superfluid has implemented two 'agreements'. The
Constant Flow Agreement (CFA) facilitates streaming tokens at a per-second rate,
with balances updated every block. The Instant Distribution Agreement (IDA)
facilitates token distributions in a highly scalable way by dividing the total
number of tokens sent by the number of units a given subscriber holds.

The IDA is highly scalable, but has proven to only be gas efficient if the
distributor intends to make recurring distributions. The process of calling
recurring distributions can not easily be handled on chain, as the distribute
method must be called either by an off chain actor or by a hook in another
contract.

The Constant Flow Distribution Agreement (CFDA) implements the best of both the
CFA and IDA, combining the autonomous nature of token streaming with the
scalability of an index-based distribution. Many IDA use cases would be further
improved by the autonomy of a CFDA token stream.

In short, the CFDA would use the IDA index architecture to split a CFA stream
among an arbitrary number of subscribers, facilitating a "one-to-many" stream.

## 1 - Technical Overview

### 1.1 - Unit Issuance

The CFDA agreement would facilitate the issuing, transferring, and removing of
units, just as the IDA does. Issuing and transferring units should at no time
have an impact on the sender's flow rate. As the supply of units changes, so
does the flowRates of subscribers. This allows the CFDA to follow CFA solvency
rules, discussed in the solvency section.

The only potential problem with this is it limits the maximum flow rate for a
given CFDA flow. The `flowRate` value for a CFAv1 flow is a signed 96 bit
integer, meaning the maximum flow rate per second would be around 39 billion per
second, which should be no issue for most tokens, but tokens with large supplies
may find the flow rate per second limiting.

```python
# rounding down, as Solidity does

max_flow_rate = (2 ** 96) / 2
# 3_961_4081_257_132_168_796_771_975_168


# adjusted for 18 super token decimals

max_flow_rate_adj = (2 ** 96) / 2 * 1e-18
# 39_614_081_257
```

### 1.2 - Real Time Balance

The Superfluid Token implements `realtimeBalanceOf()` which takes an account
address and an unsigned 256 bit integer timestamp as parameters. The function
then iterates over the active agreements, retrieved from the Superfluid host.
Each agreement implements their own `realtimeBalanceOf()` function, which takes
a SuperfluidToken, the account address, and the unsigned 256 bit
integer timestamp as parameters.

#### 1.2.1 - CFAv1 Real Time Balance

The CFAv1's real time balance function retrieves relevant flow data from the
SuperfluidToken, given an account address. The dynamic balance is a signed 256
bit integer calculated as follows:

```python
# state.time = timestamp at last flow update
dynamic_balance = (time - last_update_time) * flow_rate
```

#### 1.2.2 - IDAv1 Real Time Balance

The IDAv1's real time balance function iterates subscription ids associated with
an account. With each iteration, the subscription and respective index are
loaded, and the difference between the index's current value and the index's
last value (subscriptionData.indexValue) are multiplied by the number of units
the account holds in the subscription.

```python
# abstraction
dynamic_balance = 0

for subscription in token_account_subscriptions:

    # index_value and last_index_value loaded with subscription id
    dynamic_balance += (index_value - last_index_value) * subscription_owned_units
```

#### 1.2.3 - CFDAv1 Real Time Balance

Being an effective hybrid of the CFAv1 and IDAv1, the CFDAv1 would calculate
real time balances by loading subscription ids associated with an account, then
iterating over each subscription and respective index. Each iteration adds the
difference between the previously updated index value and a 'real time' index
value, calculated by the amount of time that has passed since the last flow rate
update.

```python
dynamic_balance = 0

# iterate subscriptions like IDA
for subscription in token_account_approved_subscriptions:

    # calculate real time index value based on sender flow rate
    real_time_index = (time - last_time_update) * index_flow_rate

    # add to total
    dynamic_balance = (real_time_index - last_index_value) * owned_units

```
This would effectively mean the flow rate for a given subscriber would be
calculated as follows.

```python
subscriber_flow_rate = sender_flow_rate * (owned_units / subscription_units)
```

### 1.3 - Solvency

Since the CFDAv1 would have a static sender flow rate, the solvency rules would
follow the same rules as the CFAv1. A sending account, on stream start, makes a
deposit as required by the protocol. The account stream is divided among
subscribers that *have* approved the subscription. Any non-approved subscribers
would be able to claim the funds streamed at any time after the stream has
started.

If a sending account becomes critical, that is their account balance reaches
zero, the stream is available to sentinels to be liquidated. Since streaming the
token from the sender is the same as the CFA, minimal modifications (if any)
would need to be made to the sentinel software.

### 1.4 - CFDA Process Example

- `Sender` creates an index
- `Sender` issues units of the index to an arbitrary number of `subscribers`
- `Subscribers` may begin approving the subscription
- `Sender` creates a flow
- `Subscribers` that have approved the subscription receive a proportional flow
- `Subscribers` that have not approved the subscription may claim the amount
    owed to them
- `Subscribers` that approve while a stream is open simultaneously claim the
    amount owed to them at the given `block.timestamp`, and begin receiving the
    proportional flow from that time on
- `Sender` updates the flow
- `Subscribers'` in flow rates adjust
- `Sender` issues new shares
- `Subscribers'` in flow rates adjust
- `Sender` closes the flow
- `Subscribers'` in flow rates set to zero
- `Subscribers` that did not approve the subscription can claim the proportional
    amount streamed to them

## 2 - Use Cases

### 2.1 - IDA Autonomy

The IDA has proven to be a highly scalable mechanism for distributing tokens to
an arbitrarily large number of addresses. The gas efficiency of the IDA,
however, proves to be favorable only when a recurring payment is made. Recurring
payments are difficult to automate on-chain, as there is no time-reactive
functionality in the Ethereum Virtual Machine. IDA indexes can be autonomously
distributed via a super app hook, an ERC777 hook, or off chain infrastructure.

In an effort to minimize off-chain infrastructure, the CFDA would offer the
scalability of an IDA with the autonomy of the CFA.

### 2.2 - Ricochet Exchange

The current Ricochet Exchange architecture relies on calling IDA distribute,
with the amount distributed determined by a Tellor oracle. This means the end
user must stream token0 per-second, but only receive token1 per-interval. The
interval is determined by Keepers, or off chain bots that agnostically trigger
a function with the IDA distribution logic built in.

A Ricochet Exchange with a CFDA would still rely on the Tellor oracle and off-
chain infrastructure, but instead of calling distributions, a single flow rate
adjustment would update the flow rates of the token1 being streamed back to the
subscribers streaming token0. This would make for a seem-less and more user-
friendly experience.

### 2.3 - CFDA Rewards Token

Much like the IDA Rewards Token built by Miao in the Superfluid examples
directory, the CFDA Rewards Token would create a synthetic ERC20 token where the
balances of an account would entitle the respective account a portion of the
sender's flow rate, opening many use cases for recurring token holder rewards.

### 2.4 - FluidX

The FluidX super token native AMM (in development) already offers functionality
unique to super tokens, optimizing for user experience, but a CFDA would also
facilitate an autonomous take-profit mechanism for liquidity providers. By
streaming Super LP tokens into the pair contract, the pair contract could then
issue shares in a CFDA stream. By using a CFDA, the flow rate of either token
could change to match the given constant product on every swap. Since streaming
two tokens out of the pair proportionally maintains the constant product, the
flow rate itself would not need to be purely dynamic, but rather only update
when a swap is executed.

### 2.5 - Simulated Dynamic Flow Rates

A project that seeks to simulate dynamic flow rates could run off-chain
infrastructure to periodically adjust the net flow rate based on a given
formula. This gives the user the impression of a dynamic flow rate while
offering a gas efficient solution for the project team to use.

## Conclusion

The Constant Flow Distribution Agreement offers unique functionality that
combines the scalability of the IDA with the autonomy of the CFA, and while it
would require more on-chain computation, it would cause no unusual account
solvency issues while offering enhancements to existing and in-progress
protocols in the Superfluid ecosystem.
