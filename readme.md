# Electric Parens
<span class="badge-paypal"><a href="https://paypal.me/xkapastel" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>

Electric Parens is a Lisp environment written in Dart.

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
returns one number, from -1 to 1 inclusive. This procedure is
interpreted as a waveform, and is rendered as 64-bit PCM at
44.1kHz. Here's the command I've been using during development:

```
cat lisp/audio.lisp | eparens-osc | head -c 2M > test.raw && sox -c 1 -r 44100 -t f64 test.raw test.wav
```

`eparens-irc` is an IRC bot that evaluates Electric Lisp. It uses the
following environment variables:

```
export EPARENS_IRC_SERVER="irc.freenode.net"
export EPARENS_IRC_NICKNAME="chunkylover53"
export EPARENS_IRC_PASSWORD="password123"
export EPARENS_IRC_CHANNEL="#eparens"
```

[API documentation for the Dart implementation](https://xkapastel.github.io/electric-parens/api/index.html) is available on [GitHub Pages](https://xkapastel.github.io/electric-parens/api/index.html).

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

## License
Electric Parens is available under the GNU Affero General Public
License, version 3; see the `LICENSE` file for details.
