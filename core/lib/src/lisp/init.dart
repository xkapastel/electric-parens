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
  while (args is! Nil) {
    acceptPair(args);
    state = state && predicate(args.fst);
    args = args.snd;
  }
  return Boolean(state);
}

Value _listFold(Function cons, dynamic args) {
  acceptPair(args);
  rejectNil(args.snd);
  Value state = args.fst;
  args = args.snd;
  while (args is! Nil) {
    acceptPair(args);
    state = cons(state, args.fst);
    args = args.snd;
  }
  return state;
}

dynamic _vau(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  // Hack, need disjunction for accept.
  if (args.snd.fst is! Nil) {
    acceptSymbol(args.snd.fst);
  }
  var proc = Vau(args.fst, args.snd.snd, env, args.snd.fst);
  return rest(proc);
}

dynamic _wrap(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptProcedure(args.fst);
  acceptNil(args.snd);
  return rest(Wrap(args.fst));
}

dynamic _unwrap(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptWrap(args.fst);
  acceptNil(args.snd);
  return rest(args.fst.body);
}

dynamic _reset(dynamic args, dynamic env, Function rest) {
  return rest(args.exec(env, (x) => x));
}

dynamic _shift(dynamic args, dynamic env, Function rest0) {
  acceptPair(args);
  acceptProcedure(args.fst);
  acceptNil(args.snd);

  dynamic body(dynamic args, dynamic env, Function rest1) {
    acceptPair(args);
    acceptNil(args.snd);
    return rest1(rest0(args.fst));
  }

  var continuation = Wrap(Native(body));
  var list = Pair(continuation, nil);
  return args.fst(list, env, (x) => x);
}

dynamic _eval(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  acceptNil(args.snd.snd);
  return args.snd.fst.eval(env, (local) {
    acceptEnvironment(local);
    return args.fst.eval(local, rest);
  });
}

dynamic _initialEnvironment(dynamic args, dynamic env, Function rest) {
  return rest(init());
}

dynamic _pair(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  acceptNil(args.snd.snd);
  return rest(Pair(args.fst, args.snd.fst));
}

dynamic _fst(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.fst);
  acceptNil(args.snd);
  return rest(args.fst.fst);
}

dynamic _snd(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.fst);
  acceptNil(args.snd);
  return rest(args.fst.snd);
}

dynamic _ifz(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptPair(args.snd);
  if (args.snd.snd is Pair) {
    acceptNil(args.snd.snd.snd);
  }
  return args.fst.eval(env, (flag) {
    acceptBoolean(flag);
    if (flag.value) {
      return args.snd.fst.eval(env, rest);
    } else {
      if (args.snd.snd is Pair) {
        return args.snd.snd.fst.eval(env, rest);
      }
      return rest(nil);
    }
  });
}

dynamic _not(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptBoolean(args.fst);
  acceptNil(args.snd);
  return rest(Boolean(!args.fst.value));
}

dynamic _and(dynamic args, dynamic env, Function rest) {
  bool state = true;
  while (args is! Nil) {
    acceptPair(args);
    acceptBoolean(args.fst);
    state = state && args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _or(dynamic args, dynamic env, Function rest) {
  bool state = false;
  while (args is! Nil) {
    acceptPair(args);
    acceptBoolean(args.fst);
    state = state || args.fst.value;
    args = args.snd;
  }
  return rest(Boolean(state));
}

dynamic _isBoolean(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Boolean, args));
}

dynamic _isSymbol(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Symbol, args));
}

dynamic _isNumber(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Number, args));
}

dynamic _isString(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Stringz, args));
}

dynamic _isNil(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Nil, args));
}

dynamic _isPair(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Pair, args));
}

dynamic _isEnvironment(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Environment, args));
}

dynamic _isProcedure(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Procedure, args));
}

dynamic _isNative(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Native, args));
}

dynamic _isWrap(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Wrap, args));
}

dynamic _isVau(dynamic args, dynamic env, Function rest) {
  return rest(_listAll((x) => x is Vau, args));
}

dynamic _add(dynamic args, dynamic env, Function rest) {
  double state = 0.0;
  while (args is! Nil) {
    acceptPair(args);
    acceptNumber(args.fst);
    state += args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _subtract(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  if (args.snd is Nil) {
    return rest(Number(0.0 - args.fst.value));
  }
  double state = args.fst.value;
  args = args.snd;
  while (args is! Nil) {
    acceptPair(args);
    acceptNumber(args.fst);
    state -= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _multiply(dynamic args, dynamic env, Function rest) {
  double state = 1.0;
  while (args is! Nil) {
    acceptPair(args);
    acceptNumber(args.fst);
    state *= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _divide(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  if (args.snd is Nil) {
    return rest(Number(1.0 / args.fst.value));
  }
  double state = args.fst.value;
  args = args.snd;
  while (args is! Nil) {
    acceptPair(args);
    acceptNumber(args.fst);
    state /= args.fst.value;
    args = args.snd;
  }
  return rest(Number(state));
}

dynamic _exp(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptNil(args.snd);
  return rest(Number(exp(args.fst.value)));
}

dynamic _log(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptNil(args.snd);
  return rest(Number(log(args.fst.value)));
}

dynamic _sin(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptNil(args.snd);
  return rest(Number(sin(args.fst.value)));
}

dynamic _cos(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  acceptNumber(args.fst);
  acceptNil(args.snd);
  return rest(Number(cos(args.fst.value)));
}

dynamic _printz(dynamic args, dynamic env, Function rest) {
  print(args);
  return rest(nil);
}

dynamic _list(dynamic args, dynamic env, Function rest) {
  return rest(args);
}

dynamic _listStar(dynamic args, dynamic env, Function rest) {
  acceptPair(args);
  var buf = [];
  while (args is! Nil) {
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

Environment init() {
  var ctx = Environment.empty();

  ctx["vau"] = Native(_vau);
  ctx["wrap"] = Wrap(Native(_wrap));
  ctx["unwrap"] = Wrap(Native(_unwrap));
  ctx["eval"] = Wrap(Native(_eval));
  ctx["reset"] = Wrap(Native(_reset));
  ctx["shift"] = Wrap(Native(_shift));
  ctx["if"] = Native(_ifz);
  ctx["not"] = Wrap(Native(_not));
  ctx["and"] = Wrap(Native(_and));
  ctx["or"] = Wrap(Native(_or));
  ctx["nil"] = nil;
  ctx["pair"] = Wrap(Native(_pair));
  ctx["fst"] = Wrap(Native(_fst));
  ctx["snd"] = Wrap(Native(_snd));
  ctx["init"] = Wrap(Native(_initialEnvironment));
  ctx["boolean?"] = Wrap(Native(_isBoolean));
  ctx["symbol?"] = Wrap(Native(_isSymbol));
  ctx["number?"] = Wrap(Native(_isNumber));
  ctx["string?"] = Wrap(Native(_isString));
  ctx["nil?"] = Wrap(Native(_isNil));
  ctx["pair?"] = Wrap(Native(_isPair));
  ctx["env?"] = Wrap(Native(_isEnvironment));
  ctx["procedure?"] = Wrap(Native(_isProcedure));
  ctx["native?"] = Wrap(Native(_isNative));
  ctx["wrap?"] = Wrap(Native(_isWrap));
  ctx["operative?"] = Wrap(Native(_isVau));
  ctx["#t"] = Boolean(true);
  ctx["#f"] = Boolean(false);
  ctx["+"] = Wrap(Native(_add));
  ctx["-"] = Wrap(Native(_subtract));
  ctx["*"] = Wrap(Native(_multiply));
  ctx["/"] = Wrap(Native(_divide));
  ctx["exp"] = Wrap(Native(_exp));
  ctx["log"] = Wrap(Native(_log));
  ctx["sin"] = Wrap(Native(_sin));
  ctx["cos"] = Wrap(Native(_cos));
  ctx["pr"] = Wrap(Native(_printz));
  ctx["list"] = Wrap(Native(_list));
  ctx["list*"] = Wrap(Native(_listStar));

  return ctx;
}
