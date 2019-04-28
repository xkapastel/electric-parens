# The Electric Lisp Report
A document in the style of the Revised Scheme Report, for specifying
the Electric Lisp language and software development kit.

The Electric Lisp report will also specify the basic data structures
provided by the SDK: lists, sets, maps and so on, in the style of
Clojure and Haskell. The emphasis is on immutable data and algebraic
manipulation.

## Language
Electric Lisp is a *Lisp-1*, with *fexprs* and *delimited
continuations*:

- Lisp-1 means there's just one namespace for both values and
  functions, as opposed to a Lisp-2 like Emacs Lisp.

- Fexprs are kind of like "first class macros": the primitive
  constructor of procedures is `vau`, not `lambda`, and it creates
  procedures that receive their arguments *unevaluated*, in addition
  to the environment at the call site.

- Delimited continuations are like purely functional macros: they
  enable more well-behaved synactic abstraction than fexprs or macros,
  and in particular they allow the concise expression of *monadic*
  design patterns.
