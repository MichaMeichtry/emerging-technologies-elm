# What Is Elm?

## Definition

Elm is a domain-specific, purely functional programming language designed for building reliable web browser-based graphical user interfaces. It is compiled into JavaScript, with a focus on simplicity, performance and robustness [1][4].

Its most advertised feature is the absence of runtime exceptions in practice, a capability enabled by the compiler's static type checking [4].

## Origins

Elm was developed by Evan Czaplicki as his senior thesis at Harvard University's John A. Paulson School of Engineering and Applied Sciences in 2012. The thesis was entitled _'Elm: Concurrent FRP for Functional GUIs"_ and was completed in
collaboration with Stephen Chong, associate professor of computer science [1][2].

The motivation behind Elm was to establish a connection between academic programming language research and mainstream web development. Czaplicki's research highlighted that many of the most innovative ideas developed by academic computer scientists rarely gained traction in mainstream programming [2].

Following his graduation, Czaplicki joined Google's Gmail team for a short period of time, while continuing to develop Elm. In 2013, he joined the team at Prezi, where he dedicated himself to working full-time on the Elm open source initiative. In 2016, he took on the role of Open Source Engineer at NoRedInk and established the Elm Software Foundation [2][3].

## The Problem Elm Addresses

JavaScript - the dominant language of the web - was not designed with large,
complex front-end applications in mind. It suffers from:

- **Runtime errors**: These are crashes that occur when a user runs a program. They are difficult to detect before the program is released [4].
- **Unpredictable state**: The presence of mutable values and side effects in code can make it challenging to understand and maintain [4].
- **Ecosystem fragility**: The typical approach to achieving reliability in JavaScript involves the combination of numerous libraries (e.g. React + Redux + TypeScript + Babel), each of which introduces a degree of complexity [4].

Elm resolves these issues by ensuring that reliability is built into the language itself, rather than being an additional feature [4].

## Key Characteristics

- **Purely functional**: All values are considered constant, and functions consistently generate the same output for equivalent inputs [1].
- **Statically typed with type inference**: The compiler's primary function is to identify errors before the program is executed. While type annotations are not mandatory, they are strongly recommended [1].
- **Compiles to JavaScript**: This software is compatible with all modern browsers and does not require the installation of any additional plugins [1].
- **Domain-specific**: This language has been intentionally designed for front-end web development, rather than being a general-purpose language [1].
- **Friendly error messages**: The compiler has been developed to provide guidance to developers on how to resolve issues, rather than simply reporting failures [4].

## Sources

[1] Czaplicki, E. _Elm: Concurrent FRP for Functional GUIs_. Harvard thesis (2012).
https://elm-lang.org/assets/papers/concurrent-frp.pdf

[2] Harvard SEAS. _Alumni profile: Evan Czaplicki, A.B. '12_ (2015).
https://seas.harvard.edu/news/2015/10/alumni-profile-evan-czaplicki-ab-12

[3] Yahoo Finance / Prezi. _Prezi Funds Development of New Computer Programming
Language_ (2013).
https://finance.yahoo.com/news/prezi-funds-development-computer-programming-130000626.html

[4] Czaplicki, E. _An Introduction to Elm_. Official Elm Guide.
https://guide.elm-lang.org/

---

<sub>Previous | [Project Overview](../01-project-overview/01-project-overview.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Core Concepts](02-core-concepts.md)</sub>
