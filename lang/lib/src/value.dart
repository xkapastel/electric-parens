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
  Value evlis(Scope scope, Function rest) =>
    rest(this);

  toString() =>
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

  Value eval(Scope scope, Function rest) =>
    fst.eval(scope, (proc) => proc(snd, scope, rest));

  Value evlis(Scope scope, Function rest) =>
    fst.eval(scope, (fst) => snd.evlis(scope, (snd) => rest(Pair(fst, snd))));

  String toString() {
    if (isList) {
      var buf = new StringBuffer();
      dynamic xs = this;
      buf.write("(");
      while (xs is! Unit) {
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

  Value eval(Scope scope, Function rest) =>
    rest(scope[this]);

  toString() =>
    value;
}

class Scope extends Value {
  Scope parent;
  Map<String, Value> frame;

  Scope(Scope this.parent) {
    frame = new HashMap();
  }

  Value operator[](Symbol key) {
    if (frame.containsKey(key.value)) {
      return frame[key.value];
    }
    if (parent != null) {
      return parent[key];
    }
    throw "undefined";
  }

  void operator[]=(Symbol key, Value value) {
    frame[key.value] = value;
  }

  String toString() =>
    "<scope>";
}
