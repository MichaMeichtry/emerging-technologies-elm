# Project Overview

This document explains the context of this project, the reasoning behind our choices, and how we approached the work. For navigation and setup, see the [README](../../README.md).

---

## Context

This project was carried out as part of the module "63-51 Emerging Technologies" of the Business Information Technology degree at HES-SO Valais Wallis.

The module requires students to independently discover an emerging technology, evaluate it, build something with it, and transmit that knowledge to classmates and professors. The result must be self-contained so that a reader should be able to understand, run, and evaluate the technology without visiting any other resource.

---

## Why Elm?

Elm is not a mainstream technology, which makes it a relevant subject for this module. It represents a different way of thinking about frontend development, one that prioritises correctness and reliability over flexibility.

Most frontend developers work with JavaScript or TypeScript-based frameworks. Elm deliberately steps away from that ecosystem and introduces a strict functional model with no runtime errors by design. Understanding Elm means understanding what trade-offs that approach involves, and when those trade-offs are worth making.

It is also a well-scoped technology. Elm has a single clear use case (browser applications), a defined architecture (TEA), and a small but complete set of core concepts. That makes it realistic to cover thoroughly within the scope of this project.

---

## Our Approach

We structured the project in four layers, each building on the previous:

**1. Theory first.** Before writing comparisons or building anything, we documented what Elm is, how it works, and what ideas it is built on. This is the foundation everything else refers back to.

**2. Comparison second.** Once the theory was clear, we compared Elm analytically to the technologies a developer would realistically consider instead. The comparison is structured around defined criteria and is intentionally balanced. We cover where Elm fits well and where it does not.

**3. Examples alongside theory.** Small standalone programs and examples are used to make the theory concrete. Each example targets a specific concept and can be run in the browser without any local setup.

**4. Prototype last.** The prototype brings everything together in a single working application. It is not just a demo. Every feature is chosen to demonstrate a specific Elm concept, and the documentation connects each feature back to the theory.

---

## Why This Prototype?

The prototype is an **IT Service Desk Ticket System**. It was chosen because it maps naturally onto Elm's strengths:

- It has meaningful state (tickets, statuses, filters, a form) that benefits from strict typing
- The ticket lifecycle (Open, In Progress, Resolved, Closed) is a natural fit for custom types and pattern matching
- It is complex enough to demonstrate real Elm features, but simple enough to run without a backend

A simpler prototype like a counter or a to-do list would demonstrate Elm's mechanics, but not its value for a real use case. A more complex prototype with a backend would add setup friction that works against the goal of making this accessible to readers.

---

## How to Read This Repository

The recommended reading order follows the four layers above:

1. [What is Elm?](../02-elm-theory/01-what-is-elm.md)
2. [Core Concepts](../02-elm-theory/02-core-concepts.md)
3. [The Elm Architecture](../02-elm-theory/03-the-elm-architecture.md)
4. [Elm Ecosystem](../02-elm-theory/04-elm-ecosystem.md)
5. [Comparison Overview](../03-comparison/01-comparison-overview.md)
6. [Prototype Overview](../04-prototype/01-prototype-overview.md)

Each file is also written to be readable on its own if you want to jump directly to a specific topic.

---

<sub>Previous | [README](../../README.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [What is Elm?](../02-elm-theory/01-what-is-elm.md)</sub>
