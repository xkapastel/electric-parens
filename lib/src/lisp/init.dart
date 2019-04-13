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
import "case.dart";
import "unit.dart";
import "pair.dart";
import "symbol.dart";
import "number.dart";
import "stringz.dart";
import "scope.dart";
import "procedure.dart";
import "primitive.dart";
import "applicative.dart";
import "operative.dart";
import "sum.dart";
import "product.dart";
import "exponent.dart";
import "sequence.dart";

import "dart:math";

Value _listAll(Function predicate, dynamic args) {
  bool state = true;
  while (args is! Unit) {
    assert(args is Pair);
    state = state && predicate(args.fst);
    args = args.snd;
  }
  if (state) {
    return Right(unit);
  } else {
    return Left(unit);
  }
}

Value _listFold(Function cons, dynamic args) {
  assert(args is Pair);
  assert(args.snd is! Unit);
  Value state = args.fst;
  args = args.snd;
  while (args is! Unit) {
    assert(args is Pair);
    state = cons(state, args.fst);
    args = args.snd;
  }
  return state;
}

Procedure _consSum(dynamic fst, dynamic snd) {
  assert(fst is Applicative);
  assert(snd is Applicative);
  return Applicative(Sum(fst.body, snd.body));
}

Procedure _consProduct(dynamic fst, dynamic snd) {
  assert(fst is Applicative);
  assert(snd is Applicative);
  return Applicative(Product(fst.body, snd.body));
}

Procedure _consExponent(dynamic fst, dynamic snd) {
  assert(fst is Applicative);
  assert(snd is Applicative);
  return Applicative(Exponent(fst.body, snd.body));
}

Procedure _consSequence(dynamic fst, dynamic snd) {
  assert(fst is Applicative);
  assert(snd is Applicative);
  return Applicative(Sequence(fst.body, snd.body));
}

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

dynamic _copy(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Unit);
  return rest(Pair(args.fst, args.fst));
}

dynamic _inl(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Unit);
  return rest(Left(args.fst));
}

dynamic _inr(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.snd is Unit);
  return rest(Right(args.fst));
}

dynamic _join(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
  assert(args.fst is Case);
  assert(args.snd is Unit);
  return rest(args.fst.body);
}

dynamic _sequence(dynamic args, dynamic scope, Function rest) {
  return rest(_listFold(_consSequence, args));
}

dynamic _sum(dynamic args, dynamic scope, Function rest) {
  return rest(_listFold(_consSum, args));
}

dynamic _product(dynamic args, dynamic scope, Function rest) {
  return rest(_listFold(_consProduct, args));
}

dynamic _exponent(dynamic args, dynamic scope, Function rest) {
  return rest(_listFold(_consExponent, args));
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

dynamic _isCase(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Case, args));
}

dynamic _isLeft(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Left, args));
}

dynamic _isRight(dynamic args, dynamic scope, Function rest) {
  return rest(_listAll((x) => x is Right, args));
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

dynamic _list(dynamic args, dynamic scope, Function rest) {
  return rest(args);
}

dynamic _listStar(dynamic args, dynamic scope, Function rest) {
  assert(args is Pair);
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
  ctx["define"] = Primitive(_define);
  ctx["reset"] = Applicative(Primitive(_reset));
  ctx["shift"] = Applicative(Primitive(_shift));
  ctx[">>>"] = Applicative(Primitive(_sequence));
  ctx["+++"] = Applicative(Primitive(_sum));
  ctx["***"] = Applicative(Primitive(_product));
  ctx["^^^"] = Applicative(Primitive(_exponent));
  ctx["init"] = Applicative(Primitive(_initialScope));
  ctx["inl"] = Applicative(Primitive(_inl));
  ctx["inr"] = Applicative(Primitive(_inr));
  ctx["join"] = Applicative(Primitive(_join));
  ctx["fst"] = Applicative(Primitive(_fst));
  ctx["snd"] = Applicative(Primitive(_snd));
  ctx["copy"] = Applicative(Primitive(_copy));
  ctx["unit"] = unit;
  ctx["pair"] = Applicative(Primitive(_pair));
  ctx["symbol?"] = Applicative(Primitive(_isSymbol));
  ctx["number?"] = Applicative(Primitive(_isNumber));
  ctx["string?"] = Applicative(Primitive(_isString));
  ctx["case?"] = Applicative(Primitive(_isCase));
  ctx["left?"] = Applicative(Primitive(_isLeft));
  ctx["right?"] = Applicative(Primitive(_isRight));
  ctx["unit?"] = Applicative(Primitive(_isUnit));
  ctx["pair?"] = Applicative(Primitive(_isPair));
  ctx["scope?"] = Applicative(Primitive(_isScope));
  ctx["procedure?"] = Applicative(Primitive(_isProcedure));
  ctx["primitive?"] = Applicative(Primitive(_isPrimitive));
  ctx["applicative?"] = Applicative(Primitive(_isApplicative));
  ctx["operative?"] = Applicative(Primitive(_isOperative));
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
