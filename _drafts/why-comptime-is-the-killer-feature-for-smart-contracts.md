---
layout: post
title: "Why Comptime is the Killer Feature for Smart Contracts"
---

Comptime (short for “compile time”) is a powerful feature that enables developers to execute arbitrary code during compilation. It uses the same syntax as regular code, but instead of being executed at runtime, selected parts are evaluated ahead of time and embedded directly into the final bytecode.

Here are three reasons why comptime is a game-changer for smart contracts.

## Comptime reduces on-chain cost

The EVM charges for computation, not compilation. Anything you can move out of runtime and execute at compile time is effectively free.

With comptime, you can:
- Precompute expensive values (e.g. lookup tables like Uniswap’s getSqrtRatioAtTick)
- Fold constant expressions
- Eliminate unused branches and dead code

For example, consider:

```
price = 1000 * 10**18 * 365 * 24 * 3600;
```

With comptime, the compiler evaluates it once and embeds the final value in the bytecode. No runtime cost, no repeated computation.

This also reduces code size. The compiler collapses everything to the minimal representation the EVM needs to execute, leading to cheaper deployment and lower gas usage.

In practice, comptime lets you express richer logic without paying for it at runtime: the compiler does the heavy lifting, while the chain only sees the final optimized result.

## Comptime makes contracts safer and easier to audit

Smart contracts operate in a hostile environment where bugs are expensive and irreversible. Comptime shifts failure earlier, into compilation, where it’s cheap and safe.

Instead of relying on runtime checks, you can:
- Validate invariants at compile time
- Eliminate entire branches the compiler can prove unnecessary
- Encode assumptions directly into the type system

This leads to simpler runtime code:
- Less runtime logic → smaller attack surface
- Fewer checks → easier audits
- More explicit logic → straightforward reasoning


It also improves readability. Imagine you see this hardcoded constant:

```
0xfffcb933bd6fad37aa2d162d1a594001
```

If you need to use or audit this code, what do you make of it? Do you know by heart that this is ≈ 1 / sqrt(1.0001) in high-precision fixed-point math?

With comptime, you can write:

```
1 / sqrt(1.0001)
```

and the compiler will evaluate it and embed the value in the bytecode. Both compile to the same result, but only one is understandable. Auditors can see how a value is derived, not just the output.

The result is a clear “what you see is what you get” contract: logic is explicit, and the compiled output reflects it. In an ecosystem where audits are expensive and bugs are costly, this directly reduces risk and cost.

Comptime also enables security through early failure and static guarantees. Where possible, bounds checks, overflow checks, and invariants are evaluated at compile time, reducing runtime overhead and attack surface. This eliminates subtle bugs (e.g., chain-specific differences can be handled safely with comptime conditionals) and makes contracts easier to reason about and simulate.

## Comptime enables zero-cost abstraction and code generation

Comptime allows the compiler to treat types as values and generate code from them, unlocking powerful abstractions without runtime overhead.

### Generics (without cost)

Instead of duplicating logic for every type, you write a single generic implementation. The compiler specializes it for each use case, producing optimized bytecode with:
- No runtime type checks
- No unused code paths
- No abstraction penalty

For example, rather than writing the same function or struct multiple times for uint256, int256, address, or custom structs, you write one generic version. Comptime then specializes (monomorphizes) it, generating only the exact, optimized bytecode needed for each case.

Why are generics very useful in smart contracts?
- No deduplication: one generic SafeMath, Array, or ERC20 wrapper instead of many copies.
- Cleaner libraries: generic math functions, Merkle proof handlers, or access control modules without gas penalty.
- Smaller, faster bytecode than hand-written specialized versions, because the compiler can aggressively fold constants and eliminate dead code per specialization.

In short, comptime makes generics not just convenient, but safe and gas-efficient, which is crucial in the EVM world.

### Type introspection → automatic generation

Type introspection (a.k.a. reflection) lets a language examine and manipulate type information at compile time. In Plank, the compiler can inspect a type’s properties - what fields a struct has, their names and types, size and alignment, or whether a type is a struct, enum, integer, address, etc. - and use that information to automatically generate correct code.

Instead of the developer manually writing logic for every struct or interface, the compiler can iterate over fields, functions, and constraints to produce encoders, validators, call wrappers, and more.

Example:

Instead of manually writing fragile ERC712 typehash strings, the compiler derives them from the struct definition. If the struct changes, the hash updates automatically. No more manual errors and forgotten updates. Goodbye mismatched typehashes: if you add, remove, or rename a field in your struct, the typehash updates automatically.

**Benefits:**
- Safer interactions: generated code always matches the actual types
- Less boilerplate and fewer bugs: no drift between logic and data
- Zero runtime overhead: everything resolves at compile time; the deployed contract only contains the final result

Other high-value uses include auto-generating ABI encoders/decoders, computing storage slots automatically for upgradeable contracts, and producing generic event emitters or validation logic.

## Why Comptime Changes Everything

Smart contracts run in an adversarial, resource-constrained, publicly verifiable environment where every cycle and every byte matters forever. Comptime is the disciplined response: push as much work as possible to compile time, leaving runtime as the smallest, safest, cheapest fallback.

This isn’t just an optimization technique — it’s a design philosophy. Plank treats "comptime > runtime" as a first principle, directly addressing the unique constraints of smart contracts rather than retrofitting a general-purpose language. The result: contracts that are cheaper to run, easier to audit, and more expressive to write — without tradeoffs.

