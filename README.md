# Electric Parens
<a href="https://liberapay.com/xkapastel/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a> [![ko-fi](https://www.ko-fi.com/img/donate_sm.png)](https://ko-fi.com/T6T5QRUW)

Electric Parens is a Lisp machine written in Dart.

## About
I don't really have a goal in mind for this project. I just like Lisp
and machine learning and wanted to hack on them. In particular, I'm
excited about the [Kernel](https://web.cs.wpi.edu/~jshutt/kernel.html)
dialect of Lisp, and the recent trend in deep learning. Dart also
turned out to be a nice language with a convenient and easy to use
standard library.

There are a couple of beliefs that guide this project:

### UI = API
Users are programmers. An application's primary interface should
provide some amount of programmatic control, rather than hiding all of
it behind a complex "API".

### PL = AI
Programming languages and artificial intelligence are both general
interfaces to computation. The two can and should be merged to provide
a more expressive means of control.

## Getting Started
There are a bunch of binaries in `bin/`, all prefixed with
`eparens-`. You can install them globally with pub, by executing the
following within the repository's directory:

```
pub get
pub global activate --source path .
```

`eparens-osc` executes Lisp source code provided on standard
input. The last expression must create a procedure that accepts and
returns one number, from 0 to 1 inclusive. This procedure is
interpreted as a waveform, and is rendered as 8-bit PCM at 22050Hz.

`eparens-irc` is an IRC bot that evaluates Electric Lisp. It uses the
following environment variables:

```
export ELECTRIC_IRC_SERVER="irc.freenode.net"
export ELECTRIC_IRC_NICKNAME="chunkylover53"
export ELECTRIC_IRC_PASSWORD="password123"
export ELECTRIC_IRC_CHANNEL="#help"
```

## Electric Lisp
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

### Vau Expressions
"First class macros", fexprs, history of Lisp.

### Delimited Continuations
Monadic patterns, examples: remove evaluation etc.

### Arrows
An arrow is a function, independent of Lisp procedures. Why have a
second type of "procedure"? Because Lisp procedures are entangled with
their environment through the use of variables. Arrows are
combinators, which means they do not use variables, and are therefore
completely independent of their environment. This simplifies formal
manipulation, in particular program synthesis.

## Creative Coding

## Roadmap
### Latent Spaces
In my opinion, latent spaces are one of the coolest ideas to ever come
out of computer science. Arithmetic operations are assigned meaning by
optimizing a function, letting you implement semantics you can't
describe explicitly.

I plan on using *arrows*, a domain specific language embedded in
Electric Lisp, to explore latent spaces.

## License
Electric Parens is available under the GNU Affero General Public
License, version 3; see the `LICENSE` file for details.
