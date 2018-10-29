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

import "dart:collection";

class Value {  
  Value eval(Scope scope, Function rest) =>
    rest(this);

  Value evlis(Scope scope, Function rest) =>
    throw "not a list";

  Value call(Value args, Scope scope, Function rest) =>
    throw "not a procedure";
}

class Unit extends Value {
  @override
  Value evlis(Scope scope, Function rest) =>
    rest(this);

  @override
  String toString() =>
    "unit";
}

class Pair extends Value {
  Value fst;
  Value snd;
  bool isList;
  
  Pair(Value fstA, Value sndA) {
    fst = fstA;
    snd = sndA;
    if (sndA is Unit) {
      isList = true;
    } else if (sndA is Pair) {
      isList = sndA.isList;
    } else {
      isList = false;
    }
  }

  @override
  Value eval(Scope scope, Function rest) =>
    fst.eval(scope, (proc) => proc(snd, scope, rest));

  @override
  Value evlis(Scope scope, Function rest) =>
    fst.eval(scope, (fst) => snd.evlis(scope, (snd) => rest(Pair(fst, snd))));

  @override
  String toString() {
    if (isList) {
      var buf = new StringBuffer();
      dynamic xs = this;
      buf.write("(");
      while (xs is! Unit) {
        assert(xs is Pair);
        buf.write(xs.fst);
        if (xs.snd is! Unit) {
          buf.write(" ");
        }
        xs = xs.snd;
      }
      buf.write(")");
      return buf.toString();
    } else {
      return "(${fst} * ${snd})";
    }
  }
}

class Symbol extends Value {
  String value;
  Symbol(String this.value);

  @override
  Value eval(Scope scope, Function rest) =>
    rest(scope[this]);

  @override
  String toString() =>
    value;
}

class Scope extends Value {
  Scope parent;
  Map<String, Value> frame;

  Scope(Scope this.parent) {
    frame = new HashMap();
  }

  factory Scope.empty() =>
    Scope(null);

  factory Scope.initial() {
    var scope = Scope.empty();

    Value debug(Value args, Scope scope, Function rest) {
      print("debugging...");
      return rest(Unit());
    }

    scope["debug"] = Primitive(debug);
    return scope;
  }

  Value operator[](dynamic key) {
    key = key.toString();
    if (frame.containsKey(key)) {
      return frame[key];
    }
    if (parent != null) {
      return parent[key];
    }
    throw "undefined";
  }

  void operator[]=(dynamic key, Value value) {
    key = key.toString();
    frame[key] = value;
  }

  @override
  String toString() =>
    "<scope>";
}

class Procedure extends Value {
  @override
  Value call(Value args, Scope scope, Function rest) =>
    rest(Pair(this, args));
}

class Primitive extends Procedure {
  final Function body;

  Primitive(Function this.body);

  @override
  Value call(Value args, Scope scope, Function rest) =>
    body(args, scope, rest);

  @override
  String toString() =>
    "<procedure>";
}

class Applicative extends Procedure {
  final Procedure body;

  Applicative(Procedure this.body);

  @override
  Value call(Value args, Scope scope, Function rest) =>
    args.evlis(scope, (args) => body(args, scope, rest));
}

class Operative extends Procedure {
  final Value args;
  final Value body;
  final Scope statik;
  final Symbol dynamik;

  Operative(
    Value this.args,
    Value this.body,
    Scope this.statik,
    Symbol this.dynamik);

  @override
  Value call(Value args, Scope scope, Function rest) {
    Scope local = Scope(statik);
    dynamic lhs = this.args;
    if (lhs is Symbol) {
      local[lhs] = args;
    } else {
      dynamic rhs = args;
      while (lhs is! Unit) {
        assert(lhs is Pair);
        assert(rhs is Pair);
        assert(lhs.fst is Symbol);
        local[lhs.fst] = rhs.fst;
        lhs = lhs.snd;
        rhs = rhs.snd;
      }
    }
    local[dynamik] = scope;
    return body.eval(local, rest);
  }
}
