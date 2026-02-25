---
layout: post
title: "The Vision of Plank"
---

Plank's goal is to empower engineers building complex EVM-based smart contracts. We believe that over the past years, Solidity and its compiler, a critical part of the dev tooling stack, has been neglected compared to other parts of the stack.

Inspired by Foundry and other great tooling, we're raising the bar by learning from the successes and limitations of Solidity and Vyper. Their ecosystems have enabled massive progress, but we believe the standard for expressivity, optimization, and tooling can be much higher.

## "Sensei": A Note on Naming

When Philogy first introduced the language at DevConnect, it was called Sensei. In the months since, we've decided to rename it Plank.

We liked "Plank" for its simplicity and the lore it carries, from physics, to wood, to Minecraft, all of which we can leverage for branding. "Sensei" is not gone entirely, we're recycling the name for our language-agnostic IR, which will be dubbed Sensei IR (SIR).

## Raising the Bar: From Developer Experience to Ecosystem Safety

### Making the Basics Work

Some problems simply shouldn't exist in 2026: "stack too deep" errors, absurd `--via-ir` compile times, or basic editor functionality not working reliably, e.g., syntax highlighting, autocomplete, go-to-definition, hover information, etc.

Furthermore, readable and safe code should not come at the cost of gas efficiency. Core primitives like ABI encoding and external calls must be ergonomic and compile down efficiently. High-level abstractions, such as functions and structs, must be zero-cost. And common standards, such as ERC712, should be available as type-safe, reusable builtins rather than requiring endless error prone repetition.

### Bringing Modern Language Features to the Smart Contract World

Smart contract development shouldn't lag behind modern language design. Despite being the #1 smart contract ecosystem, Ethereum's languages have lagged behind its competitors (Move, Cairo, Sway, etc.) in bringing the newest ideas in language design to its developers:
- Generics and General-Purpose Polymorphism: allows devs to write and audit code once, then reuse it across business logic and tests without gas overhead.
- Metaprogramming: enables devs to extend and shape the language itself without needing to become a compiler engineer (e.g., implement the ERC712 yourself).
- Tagged unions and match statements: help devs to model states and APIs in an intuitive and explicit way, while letting the compiler catch bugs early in the development cycle.

### Extending Beyond Developers

Better developer experience won't just make coding nicer, it will have concrete effects:

**Security:** By avoiding footguns, helping devs catch simple bugs and corner cases early, and minimizing handwritten low-level code, we give teams larger margins to invest in security.

**Gas efficiency:** optimizations happen in the compiler and libraries, not through fragile manual tricks in one-off application code.

**Speed of iteration:** faster compiles, better tooling, safer refactors.

Raise the floor at the language level, and the ceiling of what teams can safely build goes up.

## How to Craft a Plank

All this sounds great, but how can we realistically expect to pull it off as a small team?

First and most importantly, we're skibidi cracked and goated with the sauce (aka we use Claude - cautiously). Jokes aside, we're carefully adapting Zig's compiler design to build a compiler that is minimal in implementation but broad in capability. 

### Comptime

Most of Plank's power comes from *comptime*, the ability to expressively define and perform computation at compile time. Using the same syntax and constructs as normal code, library and application devs can:
- Define generic functions and data types (via structs)
- Manipulate types as values at compile time to specialize code, e.g. defining how `abi.encode` handles arbitrary types, or manipulating struct fields as strings to construct their ERC712 typehash
- Use complex functions to compute constants that are then embedded in the final contract at zero cost

In most other languages, these capabilities are usually provided by separate systems that not only need to be implemented independently, but are also complex. For example, Rust has an intricate type system and two macro systems, while not even providing full type introspection.

Comptime already ensures that many abstractions are zero cost, since they exist purely as compile-time artifacts used to generate constants and specialized runtime code. But comptime alone isn't enough. This is where our new optimization pipeline comes in.

### Sensei IR (SIR)

SIR is our low-level EVM IR (Intermediate Representation), designed to be language-agnostic and reusable, enabling EVM-specific optimizations across multiple languages. Beyond textbook compiler optimizations, we focus on best-in-class optimizations tailored to the EVM-specific parts of compilation.

#### Memory Optimizations

EVM smart contracts are highly resource-constrained, which rules out traditional memory management. Under the EVM's gas model, maintaining a conventional stack and heap is not feasible. Many advanced memory optimizations techniques, typically reserved for the most advanced EVM hackers, can be handled automatically: customizing scratch space, eliminating unnecessary allocations, and reusing temporary free memory without expanding it.

#### Stack Scheduling

The EVM's stack-based architecture is unusual compared to most virtual machines, which typically rely on registers. This uniqueness creates challenges for compiler design: limited stack depth often forces compilers into conservative decisions, producing "stack too deep" errors or excessive memory usage.

Stack optimization usage isn't something developers can realistically do by hand, and the unusual architecture means there aren't many off-the-shelf algorithms to rely on. SIR includes dedicated stack scheduling to compute efficient manipulation sequences, avoiding "stack too deep" errors and unnecessary memory overhead.

### Why We're Building Our Own IR

The EVM as an ISA is simple enough that we believe it's worth investing in a bespoke code generation pipeline that prioritizes optimizations, security, and minimization of attack surface. In order to foster collaboration and community contributions, SIR was designed to be language-agnostic. [Ora](https://www.oralang.org/), another experimental smart contract language, is already adopting it, and we hope the Solar Solidity compiler will adopt it soon as well.

Even though some alternative EVM IRs exist today, we decided to build our own because we do not believe they meet our goals:
- **Yul:** the human-readable IR that Solidity is moving to has several known issues: poor compile times, stack-too-deep edge cases, and suboptimal optimizations.
- **Venom:** Vyper's new SSA IR is promising due to its gas benchmarks and formal verification efforts. However, its Python implementation poses performance and integration challenges. Furthermore, it is primarily designed for Vyper and lacks some features we require for memory management.
- **solx's LLVM fork:** the gas and runtime performance of solx's EVM code generation is promising as well, but its use of LLVM is concerning. LLVM is a huge dependency, notoriously slow and difficult to deal with. On top of that, LLVM does not natively support the EVM, so it requires continuous maintenance and backporting by the solx team.

## Roadmap

We're building Plank in stages, each designed to ship a meaningful increment while moving towards our end goal of creating a complete, production-ready language.

- **Phase I: MVP** - end-to-end compilation, fully working comptime, minimal optimizations. (End of Q1 2026)
- **Phase II: Core QoL & Optimizations** - 80/20 quality-of-life improvements, LSP support, core optimizations such as memory management and stack scheduling. (~Q2 2026)
- **Phase III: Audit-Ready Contracts** - established contract abstraction, audit-ready code, and the beginning of formal verification for key components. (TBD)
- **Phase IV+: Full Verification & AI Assistance** - end-to-end compiler verification, with AI-assisted formal verification support. (TBD)

This project is open-source and self-funded. If you're interested in contributing code or supporting the effort, reach out to us via [X](https://x.com/plankevm). We'll be posting regular updates there and on our [telegram channel](https://t.me/+whhpx5nPli1kNjM6).
