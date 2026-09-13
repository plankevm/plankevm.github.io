---
layout: default
title: "(TBD) auto rounding title"
math: true
---

# {{ page.title }}


When developing smart contracts one often needs to translate a continuous
equation over real numbers into smart contract code.

$$\Delta X = \Delta L \cdot (\frac{1}{\sqrt P} - \frac{1}{\sqrt {p(i_u)}} )$$

**Example Equation.** Tokens for a given change in liquidity [^uniswap-v3]
{: .equation-caption}

This is where many ugly implementation details rear their head, and as a result
where a lot development cost, bugs and exploits originate. There are various
problems such as:

* representation of fractional numbers as integers e.g. $$\frac{3}{4}$$ or $$1.25$$
* approximation of non-EVM-native math operations such as $$\sqrt {x}$$ or $$\exp(x)$$
* and lastly, **managing error and precision loss from integer operations** (this is the one
  we'll focus on here).

## Integer Division

You experience precision loss as soon as you look to divide or do multiplication
by a non-whole number because the EVM has to somehow represent the result. In
most languages the default is rounding **down** e.g.

```solidity
uint256 x = uint256(15) / 3; // 5 (real: 5.0)
uint256 y = uint256(3) / 2; // 1 (real: 1.5)
```

However rounding up is not only valid but sometimes exactly what you want. This is why
Plank disallows bare `/` to avoid ambiguity, requiring you to explicitly between choose
rounding down division `-/` or rounding up `+/`:

```plank
let x_down = 15 -/ 3; // 5
let x_up = 15 +/ 3; // 5
let y_down = 3 -/ 2; // 1
let y_up = 3 +/ 2; // 2
```

## Acknowledgement

> This post and its implementation was heavily inspired by [Josselin Feist's](https://x.com/Montyly)
great ["Getting Rounding Right in DeFi"](https://seceureka.com/blog/rounding-in-defi) post.


[^feist_getting_rounding_right]: ["Getting Rounding Right in DeFi" by Josselin Feist](https://seceureka.com/blog/rounding-in-defi)
[^uniswap-v3]: [Uniswap v3 whitepaper](https://app.uniswap.org/whitepaper-v3.pdf), Equation 6.29.
