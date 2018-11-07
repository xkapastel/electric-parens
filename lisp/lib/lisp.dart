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

import "src/value.dart";
import "src/unit.dart";
import "src/pair.dart";
import "src/symbol.dart";
import "src/boolean.dart";
import "src/number.dart";
import "src/scope.dart";
import "src/procedure.dart";
import "src/primitive.dart";
import "src/applicative.dart";
import "src/operative.dart";
import "src/read.dart";

export "src/value.dart";
export "src/unit.dart";
export "src/pair.dart";
export "src/symbol.dart";
export "src/boolean.dart";
export "src/number.dart";
export "src/scope.dart";
export "src/procedure.dart";
export "src/primitive.dart";
export "src/applicative.dart";
export "src/operative.dart";
export "src/read.dart";

Scope init() {
  var ctx = Scope.empty();

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

  dynamic reset(dynamic args, dynamic scope, Function rest) {
    return rest(args.exec(scope, (x) => x));
  }

  dynamic shift(dynamic args, dynamic scope, Function rest0) {
    assert(args is Pair);
    assert(args.fst is Procedure);
    assert(args.snd is Unit);

    dynamic continuationBody(dynamic args, dynamic scope, Function rest1) {
      assert(args is Pair);
      assert(args.snd is Unit);
      return rest1(rest0(args.fst));
    }

    var continuation = Applicative(Primitive(continuationBody));
    var list = Pair(continuation, Unit());
    return args.fst(list, scope, (x) => x);
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

  dynamic define(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Symbol);
    assert(args.snd is Pair);
    assert(args.snd.snd is Unit);
    scope[args.fst] = args.snd.fst.eval(scope, (x) => x);
    return rest(Unit());
  }

  dynamic initialScope(dynamic args, dynamic scope, Function rest) {
    return rest(init());
  }

  dynamic pair(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.snd is Pair);
    assert(args.snd.snd is Unit);
    return rest(Pair(args.fst, args.snd.fst));
  }

  dynamic fst(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Pair);
    assert(args.snd is Unit);
    return rest(args.fst.fst);
  }

  dynamic snd(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Pair);
    assert(args.snd is Unit);
    return rest(args.fst.snd);
  }

  dynamic ifz(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.snd is Pair);
    if (args.snd.snd is Pair) {
      assert(args.snd.snd.snd is Unit);
    }
    return args.fst.eval(scope, (flag) {
      assert(flag is Boolean);
      if (flag.value) {
        return args.snd.fst.eval(scope, rest);
      } else {
        if (args.snd.snd is Pair) {
          return args.snd.snd.fst.eval(scope, rest);
        }
        return rest(Unit());
      }
    });
  }

  dynamic not(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Boolean);
    assert(args.snd is Unit);
    return rest(Boolean(!args.fst.value));
  }

  dynamic and(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Boolean);
      state = state && args.fst.value;
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic or(dynamic args, dynamic scope, Function rest) {
    bool state = false;
    while (args is! Unit) {
      assert(args is Pair);
      assert(args.fst is Boolean);
      state = state || args.fst.value;
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isBoolean(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Boolean);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isNumber(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Number);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isSymbol(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Symbol);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isUnit(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Unit);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isPair(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Pair);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isScope(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Scope);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isProcedure(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Procedure);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isPrimitive(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Primitive);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isApplicative(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Applicative);
      args = args.snd;
    }
    return rest(Boolean(state));
  }

  dynamic isOperative(dynamic args, dynamic scope, Function rest) {
    bool state = true;
    while (args is! Unit) {
      assert(args is Pair);
      state = state && (args.fst is Operative);
      args = args.snd;
    }
    return rest(Boolean(state));
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

  dynamic printz(dynamic args, dynamic scope, Function rest) {
    print(args);
    return rest(Unit());
  }

  ctx["vau"]          = Primitive(vau);
  ctx["wrap"]         = Applicative(Primitive(wrap));
  ctx["unwrap"]       = Applicative(Primitive(unwrap));
  ctx["reset"]        = Applicative(Primitive(reset));
  ctx["shift"]        = Applicative(Primitive(shift));
  ctx["eval"]         = Applicative(Primitive(eval));
  ctx["define"]       = Primitive(define);
  ctx["init"]         = Applicative(Primitive(initialScope));
  ctx["pair"]         = Applicative(Primitive(pair));
  ctx["fst"]          = Applicative(Primitive(fst));
  ctx["snd"]          = Applicative(Primitive(snd));
  ctx["unit"]         = Unit();
  ctx["if"]           = Primitive(ifz);
  ctx["not"]          = Applicative(Primitive(not));
  ctx["and"]          = Applicative(Primitive(and));
  ctx["or"]           = Applicative(Primitive(or));
  ctx["boolean?"]     = Applicative(Primitive(isBoolean));
  ctx["number?"]      = Applicative(Primitive(isNumber));
  ctx["symbol?"]      = Applicative(Primitive(isSymbol));
  ctx["unit?"]        = Applicative(Primitive(isUnit));
  ctx["pair?"]        = Applicative(Primitive(isPair));
  ctx["scope?"]       = Applicative(Primitive(isScope));
  ctx["procedure?"]   = Applicative(Primitive(isProcedure));
  ctx["primitive?"]   = Applicative(Primitive(isPrimitive));
  ctx["applicative?"] = Applicative(Primitive(isApplicative));
  ctx["operative?"]   = Applicative(Primitive(isOperative));
  ctx["true"]         = Boolean(true);
  ctx["false"]        = Boolean(false);
  ctx["+"]            = Applicative(Primitive(add));
  ctx["-"]            = Applicative(Primitive(subtract));
  ctx["*"]            = Applicative(Primitive(multiply));
  ctx["/"]            = Applicative(Primitive(divide));
  ctx["pr"]           = Applicative(Primitive(printz));

  return ctx;
}
