---
layout: default
title: "(TBD) auto rounding title"
math: true
---

# {{ page.title }}

A while ago [Josselin Feist](https://x.com/Montyly) wrote "Getting Rounding
Right"[^1], an excellent piece going over why rounding matters and why it's
non-trivial. The post also included some helpful tips for how to deal with
this problem but they largely hinged on what basically boils down to "be very
careful and analyze everything", and while I can always vouch for that when
developing smart contracts I believe our tooling must do more to alleviate
the mental burden of developing secure & efficient smart contracts.

Revisiting this problem now I'd like to share a simple PoC[^2] in Plank,
demonstrating how some simple use of generics combined with the newly added (but
not yet released) methods[^3] feature gives us a very cool pattern that helps us
more easily define math and control rounding direction.

## Why Rounding Matters

First a summary. Rounding is the source of error you get when you try to implement and
approximate mathematical equations over continuous, real numbers as smart
contract code operating on discrete integers.

Managing it is _crucial_ as it has been the source of many high profile exploits:
$8.4M from Bunni V2 (2025)[^bunny-v2], $1.2M from Balancer
(2023)[^balancer-1], $55M from Kyberswap (2023)[^kyber], $94.8M from Balancer +$120M from its forks (2025)[^balancer-2], and several more I haven't listed here.

Managing it is **non-trivial** because every division and often multiplication
carries the security critical decision of: do I make this operation round
*down*, or do I round *up*.

Generally the default in languages like Solidity is rounding down with the `/`
operator, but often e.g. computing the required deposit amount to mint a given
amount of shares, you actually want to round *up*.

This is why in Plank, for integer division the language disallows a plain slash
(`/`) and requires you to explicitly choose between `-/`, which rounds down and
`+/` which rounds up.

The common recommendation & framework for making this choice is "rounding in
favor of the protocol" which I'd generalize as "round in favor of the
non-adversarial party". This second formulation also explains the common caveat
to "rounding in favor of the protocol" which is you can't always trivially do
that if both parties of a transaction could be adversarial, as incorrectly
rounding in either's favor could become exploitable e.g. a borrower in a
lending protocol and the liquidator.

However generally this advise is sound and even in the liquidation example J.
Feist gives, I'd argue rounding up is the correct approach with the caveat that
you want to cap it at the position's total available collateral to avoid
reverting if you overestimate by one unit.

## Implementation Challenges

When attempting to round in a certain direction, J. Feist posits two main problems:
- Reusability: how do I reuse some piece of maths/value that might be expected to
  round two different ways
- Complexity: as your equation grows and your code changes, continuously
  updating & verifying your code to ensure the right direction becomes
  increasingly ownerous

**The Heart of the Solution**

Make every step of your math parametric over the rounding direction and then
recursively select the correct rounding direction based on some basic rules:

|Operation|Rounding Down|Rounding Up|
|---------|----------|--------|
|$$A \cdot B$$ (unsigned)|$$\text{down}(A) \cdot \text{down}(B)$$|$$\text{up}(A)\cdot\text{up}(B)$$|
|$$A - B$$|$$\text{down}(A) - \text{up}(B)$$|$$\text{up}(A) - \text{down}(B)$$|
|$$A + B$$|$$\text{down}(A) + \text{down}(B)$$|$$\text{up}(A) + \text{up}(B)$$|
|$$A / B$$ (unsigned)|$$\left\lfloor \frac{\text{down}(A)}{\text{up}(B)} \right\rfloor$$|$$\left\lceil \frac{\text{up}(A)}{\text{down}(B)} \right\rceil$$|
|$$A^P$$ (unsigned)|$$\begin{cases} \text{down}(A)^{\text{up}(P)} & \text{if } \text{down}(A) < 1 \\ \text{down}(A)^{\text{down}(P)} & \text{otherwise} \end{cases}$$|$$\begin{cases} \text{up}(A)^{\text{down}(P)} & \text{if } \text{up}(A) < 1 \\ \text{up}(A)^{\text{up}(P)} & \text{otherwise} \end{cases}$$|

So given a top-level rounding direction "up" / "down" we can then recursively
walk our expression to determine the rounding direction of the entire system.

We then create a data structure that allows us to represent our desired equation as
data and then pass in a rounding direction when we need to evaluate it:

```plank
const Round = struct {
    is_up: bool,

    fn up() Self {
        Self { is_up: true }
    }

    fn down() Self {
        Self { is_up: false }
    }
};

const Sub = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, r: Round) u256 {
            if r.is_up {
                self.lhs.eval(Round.up()) - self.rhs.eval(Round.down())
            } else {
                self.lhs.eval(Round.down()) - self.rhs.eval(Round.up())
            }
        }
    }
};

const sub = fn (lhs: $Lhs, rhs: $Rhs) Sub(Lhs, Rhs) {
    Sub(Lhs, Rhs) { lhs, rhs }
};
```

The `r: Round` type tells us what direction to round while `Sub(Lhs, Rhs)` is a
generic type that represents a subtraction between any two expressions that
supports the same `fn eval(self: Self, r: Round) u256` interface. The `sub`
helper function just lets us instantiate `Sub` more easily.

To 


We can use the same pattern to implement the rules for multiplication, addition and
division as types. 






---

[^1]: [https://seceureka.com/blog/rounding-in-defi](https://seceureka.com/blog/rounding-in-defi)
[^2]: PoC = "proof of concept"
[^3]: The ability to define methods on custom types was added in [`1bd8ca56e`](https://github.com/plankevm/plank-monorepo/commit/1bd8ca56ed96940be4d35dbb75b22386fffa26e1) but is not yet part of a stable release.
[^bunny-v2]: [https://blog.bunni.xyz/posts/exploit-post-mortem](https://blog.bunni.xyz/posts/exploit-post-mortem)
[^balancer-1]: [https://medium.com/balancer-protocol/rate-manipulation-in-balancer-boosted-pools-technical-postmortem-53db4b642492](https://medium.com/balancer-protocol/rate-manipulation-in-balancer-boosted-pools-technical-postmortem-53db4b642492)
[^balancer-2]: [https://medium.com/balancer-protocol/nov-3-exploit-post-mortem-51dcbeb6b020?utm_source=chatgpt.com](https://medium.com/balancer-protocol/nov-3-exploit-post-mortem-51dcbeb6b020?utm_source=chatgpt.com)
[^kyber]: [https://blog.kyberswap.com/post-mortem-kyberswap-elastic-exploit/?utm_source=chatgpt.com](https://blog.kyberswap.com/post-mortem-kyberswap-elastic-exploit/?utm_source=chatgpt.com)
