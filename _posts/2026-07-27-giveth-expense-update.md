---
layout: default
title: Giveth x TheDAO Fund Quadratic Funding Donation Expense Update
---

# {{ page.title }}

As a condition of participating in the [Ethereum Security](https://qf.giveth.io/qf/ethereum-security)
quadratic funding round, we agreed to provide an update on how we're spending
the funds. So here it is!

## Treasury Operations

After completing the round on the 14th May, we received ~7.23 ETH as
matching funds on the 4th of June (thank you to all the donors and TheDAO Fund again!).
The next day we [converted the majority of the donated ETH into USDC](https://etherscan.io/tx/0x48d9c1c98f4fd54cf20713bc942ab57186ae2a681de31e8073c459ce25c8c90f).
The price of ETH was falling at the time and we were somewhat unlucky to have
sold right at the bottom at a price of ~1,679 USDC/ETH.

After conversion, the total value of our treasury including direction donations was $15,768.73.

Comparing that with the $16,806.49 displayed on [Giveth](https://qf.giveth.io/project/plankevm)
(which we assume represents the sum of donations valued at the time of donation), we can
work backwards to calculate that our sale of ETH realized ~$1,006 in losses with a
further ~$31 of unrealized losses on our remaining ~0.239 ETH.

## Expenses

|Amount|Status|Purpose|
|--------|----|-------|
|$4,738|Paid|Contracting [Eduardo](https://x.com/hackerdocc) to work on [formalizing SIR](https://github.com/plankevm/sir-lean) in Lean4 (03.06 - 01.07) |
|$4,738|Committed|Continuing to contract Eduardo (01.07 - 29.07)|
|$2,250|Committed|Contracting Designer to rework logo & website.|


## Planned Expenditures

With the remaining funds, we plan to continue working with Eduardo on
the Lean4 formalization of SIR. We believe formalizing
the Plank and its components is the best approach to secure it and
ready it for use in production smart contract systems.

Not only will the formal verification work help us find and rule out bugs,
but the formal guarantees will allow us to use agents more liberally to
develop and optimize compiler code, accelerating development.

While formal verification is not perfect and we will likely need audits anyway,
the formal specification should allow us to opt for shorter, more thorough and, as a result, cheaper
audits that focus only on the specifications rather than the entire 80k-120k line Rust code base.

Big thanks again to everyone who donated, TheDAO Fund and Giveth.
