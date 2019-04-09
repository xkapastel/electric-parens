// This file is a part of Electric Parens.
// Copyright (C) 2019 Matthew Blount

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

import "value.dart";
import "unit.dart";
import "pair.dart";
import "boolean.dart";
import "symbol.dart";
import "number.dart";
import "stringz.dart";
import "scope.dart";
import "procedure.dart";
import "primitive.dart";
import "applicative.dart";
import "operative.dart";
import "read.dart";

import "dart:math";

dynamic _vau(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Pair);
  assert(args.snd.fst is Symbol);
  var proc = Operative(args.fst, args.snd.snd, scope, args.snd.fst);
  return rest(proc);
}

dynamic _wrap(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Procedure);
  assert(args.snd is Unit);
  return rest(Applicative(args.fst));
}

dynamic _unwrap(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Applicative);
  assert(args.snd is Unit);
  return rest(args.fst.body);
}

dynamic _reset(dynamic args, dynamic scope, Function rest) {
  return rest(args.exec(scope, (x) => x));
}

dynamic _shift(dynamic args, dynamic scope, Function rest0) {
  assert(args is Pair);
  assert(args.fst is Procedure);
  assert(args.snd is Unit);

  dynamic continuationBody(dynamic args, dynamic scope, Function rest1) {
    assert(args is Pair);
    assert(args.snd is Unit);
    return rest1(rest0(args.fst));
  }

  var continuation = Applicative(Primitive(continuationBody));
  var list = Pair(continuation, unit);
  return args.fst(list, scope, (x) => x);
}

dynamic _eval(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Pair);
  assert(args.snd.snd is Unit);
  return args.snd.fst.eval(scope, (local) {
    assert(local is Scope);
    return args.fst.eval(local, rest);
  });
}

dynamic _define(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Symbol);
  assert(args.snd is Pair);
  assert(args.snd.snd is Unit);
  scope[args.fst] = args.snd.fst.eval(scope, (x) => x);
  return rest(unit);
}

dynamic _initialScope(dynamic args, dynamic scope, Function rest) {
  return rest(init());
}

dynamic _pair(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Pair);
  assert(args.snd.snd is Unit);
  return rest(Pair(args.fst, args.snd.fst));
}

dynamic _fst(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Pair);
  assert(args.snd is Unit);
  return rest(args.fst.fst);
}

dynamic _snd(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Pair);
  assert(args.snd is Unit);
  return rest(args.fst.snd);
}

dynamic _ifz(dynamic args, dynamic scope, Function rest) {
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
      return rest(unit);
    }
  });
}

dynamic _not(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Boolean);
  assert(args.snd is Unit);
  return rest(Boolean(!args.fst.value));
}

dynamic _and(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    assert(args.fst is Boolean);
    state = state && args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _or(dynamic args, dynamic scope, Function rest) {
  bool state = false;
  while (args is! Unit) {
    assert(args is Pair);
    assert(args.fst is Boolean);
    state = state || args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isBoolean(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Boolean);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isSymbol(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Symbol);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isNumber(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Number);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isString(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Stringz);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isUnit(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Unit);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isPair(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Pair);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isScope(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Scope);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isProcedure(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Procedure);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isPrimitive(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Primitive);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isApplicative(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Applicative);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isOperative(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && (args.fst is Operative);
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _add(dynamic args, dynamic scope, Function rest) {
  double state = 0.0;
  while (args is! Unit) {
    assert(args is Pair);
    assert(args.fst is Number);
    state += args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _subtract(dynamic args, dynamic scope, Function rest) {
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

dynamic _multiply(dynamic args, dynamic scope, Function rest) {
  double state = 1.0;
  while (args is! Unit) {
    assert(args is Pair);
    assert(args.fst is Number);
    state *= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _divide(dynamic args, dynamic scope, Function rest) {
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

dynamic _exp(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Number);
  assert(args.snd is Unit);
  return rest(Number(exp(args.fst.value)));
}

dynamic _log(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Number);
  assert(args.snd is Unit);
  return rest(Number(log(args.fst.value)));
}

dynamic _sin(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Number);
  assert(args.snd is Unit);
  return rest(Number(sin(args.fst.value)));
}

dynamic _cos(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Number);
  assert(args.snd is Unit);
  return rest(Number(cos(args.fst.value)));
}

dynamic _printz(dynamic args, dynamic scope, Function rest) {
  print(args);
  return rest(unit);
}

Scope init() {
  var ctx = Scope.empty();

  ctx["vau"] = Primitive(_vau);
  ctx["wrap"] = Applicative(Primitive(_wrap));
  ctx["unwrap"] = Applicative(Primitive(_unwrap));
  ctx["reset"] = Applicative(Primitive(_reset));
  ctx["shift"] = Applicative(Primitive(_shift));
  ctx["eval"] = Applicative(Primitive(_eval));
  ctx["define"] = Primitive(_define);
  ctx["init"] = Applicative(Primitive(_initialScope));
  ctx["pair"] = Applicative(Primitive(_pair));
  ctx["fst"] = Applicative(Primitive(_fst));
  ctx["snd"] = Applicative(Primitive(_snd));
  ctx["unit"] = unit;
  ctx["if"] = Primitive(_ifz);
  ctx["not"] = Applicative(Primitive(_not));
  ctx["and"] = Applicative(Primitive(_and));
  ctx["or"] = Applicative(Primitive(_or));
  ctx["boolean?"] = Applicative(Primitive(_isBoolean));
  ctx["symbol?"] = Applicative(Primitive(_isSymbol));
  ctx["number?"] = Applicative(Primitive(_isNumber));
  ctx["string?"] = Applicative(Primitive(_isString));
  ctx["unit?"] = Applicative(Primitive(_isUnit));
  ctx["pair?"] = Applicative(Primitive(_isPair));
  ctx["scope?"] = Applicative(Primitive(_isScope));
  ctx["procedure?"] = Applicative(Primitive(_isProcedure));
  ctx["primitive?"] = Applicative(Primitive(_isPrimitive));
  ctx["applicative?"] = Applicative(Primitive(_isApplicative));
  ctx["operative?"] = Applicative(Primitive(_isOperative));
  ctx["true"] = Boolean(true);
  ctx["false"] = Boolean(false);
  ctx["+"] = Applicative(Primitive(_add));
  ctx["-"] = Applicative(Primitive(_subtract));
  ctx["*"] = Applicative(Primitive(_multiply));
  ctx["/"] = Applicative(Primitive(_divide));
  ctx["exp"] = Applicative(Primitive(_exp));
  ctx["log"] = Applicative(Primitive(_log));
  ctx["sin"] = Applicative(Primitive(_sin));
  ctx["cos"] = Applicative(Primitive(_cos));
  ctx["pr"] = Applicative(Primitive(_printz));

  return ctx;
}
