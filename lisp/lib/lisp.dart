// This file is a part of Electric Parens.
// Copyright (C) 2018 Matthew Blount

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <https://www.gnu.org/licenses/.

import "src/lisp/value.dart";
import "src/lisp/unit.dart";
import "src/lisp/pair.dart";
import "src/lisp/symbol.dart";
import "src/lisp/number.dart";
import "src/lisp/scope.dart";
import "src/lisp/procedure.dart";
import "src/lisp/primitive.dart";
import "src/lisp/applicative.dart";
import "src/lisp/operative.dart";
import "src/lisp/read.dart";

export "src/lisp/value.dart";
export "src/lisp/unit.dart";
export "src/lisp/pair.dart";
export "src/lisp/symbol.dart";
export "src/lisp/scope.dart";
export "src/lisp/procedure.dart";
export "src/lisp/primitive.dart";
export "src/lisp/applicative.dart";
export "src/lisp/operative.dart";
export "src/lisp/read.dart";

Scope init() {
  var init = Scope.empty();

  dynamic debug(dynamic args, dynamic scope, Function rest) {
    print("debugging...");
    print(args);
    return rest(Unit());
  }

  dynamic vau(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.snd is Pair);
    assert(args.snd.fst is Symbol);
    var proc = Operative(args.fst, args.snd.snd, scope, args.snd.fst);
    return rest(proc);
  }

  dynamic wrap(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Procedure);
    assert(args.snd is Unit);
    return rest(Applicative(args.fst));
  }

  dynamic unwrap(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Applicative);
    assert(args.snd is Unit);
    return rest(args.fst.body);
  }

  dynamic eval(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.snd is Pair);
    assert(args.snd.snd is Unit);
    return args.snd.fst.eval(scope, (local) {
      assert(local is Scope);
      return args.fst.eval(local, rest);
    });
  }

  dynamic reset(dynamic args, dynamic scope, Function rest) {
    return rest(args.exec(scope, (x) => x));
  }

  dynamic shift(dynamic args, dynamic scope, Function rest0) {
    assert(args is Pair);
    assert(args.fst is Procedure);
    assert(args.snd is Unit);

    dynamic continuationBody(dynamic args, dynamic scope, dynamic rest1) {
      assert(args is Pair);
      assert(args.snd is Unit);
      return rest1(rest0(args.fst));
    }

    var continuation = Applicative(Primitive(continuationBody));
    var list = Pair(continuation, Unit());
    return args.fst(list, scope, (x) => x);
  }

  dynamic add(dynamic args, dynamic scope, Function rest) {
    double state = 0.0;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Number);
      state += args.fst.value;
      args = args.snd;
    }
    return rest(Number(state));
  }

  dynamic subtract(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Number);
    if (args.snd is Unit) {
      return rest(Number(0.0 - args.fst.value));
    }
    double state = args.fst.value;
    args = args.snd;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Number);
      state -= args.fst.value;
      args = args.snd;
    }
    return rest(Number(state));
  }

  dynamic multiply(dynamic args, dynamic scope, Function rest) {
    double state = 1.0;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Number);
      state *= args.fst.value;
      args = args.snd;
    }
    return rest(Number(state));
  }

  dynamic divide(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Number);
    if (args.snd is Unit) {
      return rest(Number(1.0 / args.fst.value));
    }
    double state = args.fst.value;
    args = args.snd;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Number);
      state /= args.fst.value;
      args = args.snd;
    }
    return rest(Number(state));
  }

  init["debug"]  = Primitive(debug);
  init["vau"]    = Primitive(vau);
  init["wrap"]   = Applicative(Primitive(wrap));
  init["unwrap"] = Applicative(Primitive(unwrap));
  init["eval"]   = Primitive(eval);
  init["reset"]  = Applicative(Primitive(reset));
  init["shift"]  = Applicative(Primitive(shift));
  init["+"]      = Applicative(Primitive(add));
  init["-"]      = Applicative(Primitive(subtract));
  init["*"]      = Applicative(Primitive(multiply));
  init["/"]      = Applicative(Primitive(divide));
  
  return init;
}
