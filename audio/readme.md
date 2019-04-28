`eparens-osc` executes Lisp source code provided on standard
input. The last expression must create a procedure that accepts and
returns one number, from -1 to 1 inclusive. This procedure is
interpreted as a waveform, and is rendered as 64-bit PCM at
44.1kHz. Here's the command I've been using during development (from
the root directory):

```
cat report/src/audio-example-sine | eparens-osc | head -c 2M > test.raw && sox -c 1 -r 44800 -t f64 test.raw test.wav
```
