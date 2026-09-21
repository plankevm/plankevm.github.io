---
layout: default
title: "Solving Smart Contract Rounding in <100 Lines of Code"
math: true
---

# {{ page.title }}

A while ago, [Josselin Feist](https://x.com/Montyly) wrote [Getting Rounding
Right](https://seceureka.com/blog/rounding-in-defi), an excellent piece going
over why rounding matters and why it's non-trivial when developing smart contracts.

Assuming you're familiar with the problem (read the article if you're
not), I want to jump straight to a cool demo with Plank, showing off how you can
extend the language with a simple library to help you define and
set the rounding direction of an entire equation to more easily "round in favor
of the protocol".

In just ~100 lines we can define a framework that addresses 2 key problems that Feist
nicely categorized, namely complexity and reusability. To reiterate:
1. Complexity: how do we correctly set and maintain the correct rounding direction in a larger equation composed of many nested subterms?
2. Reusability: how do we define and reuse equations that may need to round in
   different directions based on their use?

## Code as Data

The core idea is simple: if we can manipulate/inspect the equation as data, we
can easily propagate the top-level rounding preference based on simple rules:

(TODO: give more explain rules)

|Operation|Rounding Down|Rounding Up|
|---------|----------|--------|
|$$A \cdot B$$ (unsigned)|$$\text{down}(A) \cdot \text{down}(B)$$|$$\text{up}(A)\cdot\text{up}(B)$$|
|$$A - B$$|$$\text{down}(A) - \text{up}(B)$$|$$\text{up}(A) - \text{down}(B)$$|
|$$A + B$$|$$\text{down}(A) + \text{down}(B)$$|$$\text{up}(A) + \text{up}(B)$$|
|$$A / B$$ (unsigned)|$$\left\lfloor \frac{\text{down}(A)}{\text{up}(B)} \right\rfloor$$|$$\left\lceil \frac{\text{up}(A)}{\text{down}(B)} \right\rceil$$|
|$$A^P$$ (unsigned)|$$\begin{cases} \text{down}(A)^{\text{up}(P)} & \text{if } \text{down}(A) < 1 \\ \text{down}(A)^{\text{down}(P)} & \text{otherwise} \end{cases}$$|$$\begin{cases} \text{up}(A)^{\text{down}(P)} & \text{if } \text{up}(A) < 1 \\ \text{up}(A)^{\text{up}(P)} & \text{otherwise} \end{cases}$$|

> Note: The code demoed in this article uses some of the new v0.2 features,
> which as of now (22-Sep-2026) is not yet in
> a stable release. Build from source on `main` if you want to try it out.


These rules are straightforward to define in Plank:

```plank
// For the plain `u256` inputs in a calculation.
const Value = struct {
    value: u256,

    fn eval(self: Self, _round_up: bool) u256 {
        self.value
    }
};

const Div = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, round_up: bool) u256 {
            // In Plank `+/` is integer division that rounds towards +∞ and `-/` towards -∞
            if round_up {
                self.lhs.eval(true) +/ self.rhs.eval(false)
            } else {
                self.lhs.eval(false) -/ self.rhs.eval(true)
            }
        }
    }
};
```

<details markdown="1">
<summary markdown="span">
_Expand for full definitions of `Add`, `Sub`, `Mul`_
</summary>

```plank
const Add = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, round_up: bool) u256 {
            self.lhs.eval(round_up) + self.rhs.eval(round_up)
        }
    }
};

const Sub = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, round_up: bool) u256 {
            self.lhs.eval(round_up) - self.rhs.eval(!round_up)
        }
    }
};

const Mul = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, round_up: bool) u256 {
            self.lhs.eval(round_up) * self.rhs.eval(round_up)
        }
    }
};
```

</details>

<p></p>

Now we can define a calculation like `x * WAD / y` and it will automatically propagate rounding (I
know this is **super** ugly and we will fix that in a moment):

```plank
const WAD = 1000000000000000000;

const wad_div_up = fn (x: u256, y: u256) u256 {
    Div(Mul(Value, Value), Value) {
        lhs: Mul(Value, Value) {
            lhs: Value { value: x },
            rhs: Value { value: WAD },
        },
        rhs: Value { value: y },
    }.eval(true)
};
```

Leveraging generics, we can now represent our computations: multiplication,
addition, subtraction, division (and more if we wanted) as data, deferring the
actual calculation until we have the rounding direction.

## Cleaning up the Library

The first issue is that building up our calculation has a lot of boilerplate,
so let's clean that up by introducing some helpers:

```plank
const value = fn (x: u256) Value {
    Value { value: x }
};

const mul = fn (lhs: $Lhs, rhs: $Rhs) Mul(Lhs, Rhs) {
    Mul(Lhs, Rhs) { lhs: lhs, rhs: rhs }
};

const add = fn (lhs: $Lhs, rhs: $Rhs) Add(Lhs, Rhs) {
    Add(Lhs, Rhs) { lhs: lhs, rhs: rhs }
};

const sub = fn (lhs: $Lhs, rhs: $Rhs) Sub(Lhs, Rhs) {
    Sub(Lhs, Rhs) { lhs: lhs, rhs: rhs }
};

const div = fn (lhs: $Lhs, rhs: $Rhs) Div(Lhs, Rhs) {
    Div(Lhs, Rhs) { lhs: lhs, rhs: rhs }
};
```

Using the new API our function now looks like this:

```plank
const WAD = 1000000000000000000;

const wad_div_up = fn (x: u256, y: u256) u256 {
    div(mul(value(x), value(WAD)), value(y)).eval(true)
};
```

Much cleaner! But we can do even better.

The `Mul`, `Div`, `Add` and `Sub` types are already generic, so they could just handle `u256`
directly instead of requiring us to wrap it in `value(...)`:

```plank
// `$T` means the parameter `x` is allowed to be any type and the type it ends
// up being is captured as `T`.
const eval_or_value = fn (x: $T, round_up: bool) u256 {
    if T == u256 { x } else { x.eval(round_up) }
};

const Mul = fn (Lhs: type, Rhs: type) type {
    struct {
        lhs: Lhs,
        rhs: Rhs,

        fn eval(self: Self, round_up: bool) u256 {
            // Replaced `self.lhs.eval(round_up) * self.rhs.eval(round_up)`
            eval_or_value(self.lhs, round_up) * eval_or_value(self.rhs, round_up)
        }
    }
};
```

_Updating `Div`, `Add`, `Sub` to use `eval_or_value` is left as an exercise to the reader._

Our original expression is now simplified down to:

```plank
const WAD = 1000000000000000000;

const wad_div_up = fn (x: u256, y: u256) u256 {
    div(mul(x, WAD), y).eval(true)
};
```

This is not as nice as using infix operators `*`, `+`, `-` and `-/`, but is as good
as or better than Solidity's usual `x.mulDivUp(y, z)` and having to remember to
manually update and maintain the correct direction at every point.

## Reusability

From the definition, it's trivial to see why and how calculations are now reusable:


```plank
const reused = fn (x: u256, y: u256, a: u256) void {
    let wad_div = div(mul(x, WAD), y);

    let add_up = add(wad_div, a).eval(true);
    let add_down = add(wad_div, a).eval(false);

    // ...
};
```

In this example, `wad_div` is just `x * WAD / y` but **deferred**, so it can be copied and used in different
calculation trees and evaluated with different rounding directions.

## Gas Cost

While I haven't done precise measurements, by simply inspecting the compiler's intermediate
outputs (with `-O2 --show-sir-final`) of different calculation definitions, it's
clear that the overhead this abstraction imposes is low, if not zero, because this
largely gets simplified to a bunch of small functions and calls, many of which
get inlined and further simplified thanks to the new inlining optimization pass.

This framework also introduces the opportunity to make the calculation *cheaper*
than a normal calculation by allowing you to define chaining and
deferred checking of errors in intermediate calculations.

You see what happens when you write something like `x * WAD / y` is it gets split
up into individual calculations and checks:

```
(pseudo code)

a := unchecked_mul(x, WAD)
if mul_overflow(a, x, WAD) {
    revert();
}
if y == 0 {
    revert();
}
b := unchecked_div(a, y);
```

However since `if` branches are more expensive than just accumulating the error
and checking it only once at the end, you could save gas by combining the checks:

```
(pseudo code)
a := unchecked_mul(x, WAD)
b := unchecked_div(a, y);
if mul_overflow(a, x, WAD) || y == 0 {
    revert();
}
```

If any of the intermediate steps failed it's fine because you'll revert at the
end in any case. However this gets very messy to manually do, but with a
framework like the one above it'd be fairly easy to have done automatically in
the background.

Define a simple result wrapper like:

```plank
const ArithResult = struct {
    value: u256,
    zero_iff_ok: u256,

    fn unwrap(self: Self) u256 {
        require(self.zero_iff_ok == 0);
        self.value
    }
};
```

Then have every intermediate `eval` aggregate and return `ArithResult` instead
of `u256` and just do one final `.unwrap()` at the end. I personally find this
idea quite compelling, and may end up putting this in Plank's standard library at
some point.

## Conclusion

Beyond rounding I think there are many more things you could tackle using Plank
that would otherwise require clunky static analysis tooling and ugly, verbose code.

I hope this snippet inspired you to use Plank and see how you can leverage it
to tackle and simplify your smart contract development.

Big thanks to Josselin Feist for the original inspiration.
