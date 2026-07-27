---
layout: default
title: Giveth x TheDAO Fund Quadratic Funding Donation Expense Update
---

# {{ page.title }}

As a condition of participating in the [Ethereum Security](https://qf.giveth.io/qf/ethereum-security)
quadratic funding round we agreed to provide an update on how we were spending
and planned to spent received funds. So here it is!

## Treasury Operations

After completion of the round on the 14th May, we finally received ~7.23 ETH as
matching on the evening of the 4th June (thank you to all the donors and TheDAO Fund again!)
The next day on the 5th of June we decided to [convert the majority of the donated into ETH into USDC](https://etherscan.io/tx/0x48d9c1c98f4fd54cf20713bc942ab57186ae2a681de31e8073c459ce25c8c90f).
The price of ETH was falling at the time and we were somewhat unlucky to have
sold right at the bottom at a price of ~1,679 USDC/ETH.

At that price, including donations we received on non-mainnet chains (Gnosis,
Optimism, Base, Arbitrum) the total value of our treasury was $15,768.73

Comparing this with the $16,806.49 displayed on [giveth](https://qf.giveth.io/project/plankevm)
(which we assume represents the sum of donations valued at the time of donation). We can
work backwards to calculate that our sale of ETH realized ~$1,006 in losses with a
further ~$31 of unrealized losses on our remaining ~0.239 ETH.

## Expenses

|Amount|Status|Purpose|
|--------|----|-------|
|$4,738|Paid|Contracting [Eduardo](https://x.com/hackerdocc) to work on [formalizing SIR](https://github.com/plankevm/sir-lean) in Lean4 (03.06 - 01.07) |
|$4,738|Committed|Continuing to contract Eduardo (01.07 - 29.07)|
|$2,250|Committed|Contracting Designer to rework logo & website.|


## Planned Expenditures

With the remaining funds we primarily intend to continue working with Eduardo on
the Lean4 formalization of SIR as long as we can afford him. We believe formalizing
the IR, its compiler and eventually the entire Plank compiler E2E is the best
approach to securing the compiler and ensuring it becomes ready for use in
production smart contract systems.

Not only will the formal verification work help us find and rule out bugs in the
compiler it'll accelerate development of the compiler as whole by allowing us to use agents more
liberally to develop and optimize compiler code, relying on the formal
guarantees to ensure the things being constructed are robust and secure.

While formal verification is not perfect and we will likely need audits anyway,
the formal specification should allow us to opt for shorter and more thorough (and as a result cheaper)
audits that focus only on the specifications rather than the entire 80k-120k line Rust code base.

Big thanks again to everyone who donated, TheDAO Fund and Giveth.
