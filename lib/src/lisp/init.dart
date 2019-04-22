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

import "dart:math";
import "value.dart";

Value _listAll(Function predicate, dynamic args) {
  bool state = true;
  while (args is! Unit) {
    acceptPair(args);
    state = state && predicate(args.fst);
    args = args.snd;
  }
  return Boolean(state);
}

Value _listFold(Function cons, dynamic args) {
  acceptPair(args);
  rejectUnit(args.snd);
  Value state = args.fst;
  args = args.snd;
  while (args is! Unit) {
    acceptPair(args);
    state = cons(state, args.fst);
    args = args.snd;
  }
  return state;
}

dynamic _vau(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  acceptSymbol(args.snd.fst);
  var proc = Operative(args.fst, args.snd.snd, scope, args.snd.fst);
  return rest(proc);
}

dynamic _wrap(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptProcedure(args.fst);
  acceptUnit(args.snd);
  return rest(Applicative(args.fst));
}

dynamic _unwrap(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptApplicative(args.fst);
  acceptUnit(args.snd);
  return rest(args.fst.body);
}

dynamic _reset(dynamic args, dynamic scope, Function rest) {
  return rest(args.exec(scope, (x) => x));
}

dynamic _shift(dynamic args, dynamic scope, Function rest0) {
  acceptPair(args);
  acceptProcedure(args.fst);
  acceptUnit(args.snd);

  dynamic body(dynamic args, dynamic scope, Function rest1) {
    acceptPair(args);
    acceptUnit(args.snd);
    return rest1(rest0(args.fst));
  }

  var continuation = Applicative(Primitive(body));
  var list = Pair(continuation, unit);
  return args.fst(list, scope, (x) => x);
}

dynamic _eval(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  acceptUnit(args.snd.snd);
  return args.snd.fst.eval(scope, (local) {
    acceptScope(local);
    return args.fst.eval(local, rest);
  });
}

dynamic _initialScope(dynamic args, dynamic scope, Function rest) {
  return rest(init());
}

dynamic _pair(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  acceptUnit(args.snd.snd);
  return rest(Pair(args.fst, args.snd.fst));
}

dynamic _fst(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.fst);
  acceptUnit(args.snd);
  return rest(args.fst.fst);
}

dynamic _snd(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.fst);
  acceptUnit(args.snd);
  return rest(args.fst.snd);
}

dynamic _ifz(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  if (args.snd.snd is Pair) {
    acceptUnit(args.snd.snd.snd);
  }
  return args.fst.eval(scope, (flag) {
    acceptBoolean(flag);
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
  acceptPair(args);
  acceptBoolean(args.fst);
  acceptUnit(args.snd);
  return rest(Boolean(!args.fst.value));
}

dynamic _and(dynamic args, dynamic scope, Function rest) {
  bool state = true;
  while (args is! Unit) {
    acceptPair(args);
    acceptBoolean(args.fst);
    state = state && args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _or(dynamic args, dynamic scope, Function rest) {
  bool state = false;
  while (args is! Unit) {
    acceptPair(args);
    acceptBoolean(args.fst);
    state = state || args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isBoolean(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Boolean, args));
}

dynamic _isSymbol(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Symbol, args));
}

dynamic _isNumber(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Number, args));
}

dynamic _isString(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Stringz, args));
}

dynamic _isUnit(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Unit, args));
}

dynamic _isPair(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Pair, args));
}

dynamic _isScope(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Scope, args));
}

dynamic _isProcedure(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Procedure, args));
}

dynamic _isPrimitive(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Primitive, args));
}

dynamic _isApplicative(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Applicative, args));
}

dynamic _isOperative(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Operative, args));
}

dynamic _add(dynamic args, dynamic scope, Function rest) {
  double state = 0.0;
  while (args is! Unit) {
    acceptPair(args);
    acceptNumber(args.fst);
    state += args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _subtract(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  if (args.snd is Unit) {
    return rest(Number(0.0 - args.fst.value));
  }
  double state = args.fst.value;
  args = args.snd;
  while (args is! Unit) {
    acceptPair(args);
    acceptNumber(args.fst);
    state -= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _multiply(dynamic args, dynamic scope, Function rest) {
  double state = 1.0;
  while (args is! Unit) {
    acceptPair(args);
    acceptNumber(args.fst);
    state *= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _divide(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  if (args.snd is Unit) {
    return rest(Number(1.0 / args.fst.value));
  }
  double state = args.fst.value;
  args = args.snd;
  while (args is! Unit) {
    acceptPair(args);
    acceptNumber(args.fst);
    state /= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _exp(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptUnit(args.snd);
  return rest(Number(exp(args.fst.value)));
}

dynamic _log(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptUnit(args.snd);
  return rest(Number(log(args.fst.value)));
}

dynamic _sin(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptUnit(args.snd);
  return rest(Number(sin(args.fst.value)));
}

dynamic _cos(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptUnit(args.snd);
  return rest(Number(cos(args.fst.value)));
}

dynamic _printz(dynamic args, dynamic scope, Function rest) {
  print(args);
  return rest(unit);
}

dynamic _list(dynamic args, dynamic scope, Function rest) {
  return rest(args);
}

dynamic _listStar(dynamic args, dynamic scope, Function rest) {
  acceptPair(args);
  var buf = [];
  while (args is! Unit) {
    buf.add(args.fst);
    args = args.snd;
  }
  var state = null;
  for (var value in buf.reversed) {
    if (state == null) {
      state = value;
    } else {
      state = Pair(value, state);
    }
  }
  return rest(state);
}

Scope init() {
  var ctx = Scope.empty();

  ctx["vau"] = Primitive(_vau);
  ctx["wrap"] = Applicative(Primitive(_wrap));
  ctx["unwrap"] = Applicative(Primitive(_unwrap));
  ctx["eval"] = Applicative(Primitive(_eval));
  ctx["reset"] = Applicative(Primitive(_reset));
  ctx["shift"] = Applicative(Primitive(_shift));
  ctx["if"] = Primitive(_ifz);
  ctx["not"] = Applicative(Primitive(_not));
  ctx["and"] = Applicative(Primitive(_and));
  ctx["or"] = Applicative(Primitive(_or));
  ctx["unit"] = unit;
  ctx["pair"] = Applicative(Primitive(_pair));
  ctx["fst"] = Applicative(Primitive(_fst));
  ctx["snd"] = Applicative(Primitive(_snd));
  ctx["init"] = Applicative(Primitive(_initialScope));
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
  ctx["#t"] = Boolean(true);
  ctx["#f"] = Boolean(false);
  ctx["+"] = Applicative(Primitive(_add));
  ctx["-"] = Applicative(Primitive(_subtract));
  ctx["*"] = Applicative(Primitive(_multiply));
  ctx["/"] = Applicative(Primitive(_divide));
  ctx["exp"] = Applicative(Primitive(_exp));
  ctx["log"] = Applicative(Primitive(_log));
  ctx["sin"] = Applicative(Primitive(_sin));
  ctx["cos"] = Applicative(Primitive(_cos));
  ctx["pr"] = Applicative(Primitive(_printz));
  ctx["list"] = Applicative(Primitive(_list));
  ctx["list*"] = Applicative(Primitive(_listStar));

  return ctx;
}
