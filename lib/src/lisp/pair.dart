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

dynamic _or(dynamic lhs, dynamic rhs) {
  if (lhs is! Unit) {
    return lhs;
  }
  return rhs;
}

class Pair extends Value {
  dynamic fst;
  dynamic snd;
  bool isList;
  
  Pair(dynamic this.fst, dynamic this.snd) {
    if (snd is Unit) {
      isList = true;
    } else if (snd is Pair) {
      isList = snd.isList;
    } else {
      isList = false;
    }
  }

  @override
  dynamic eval(dynamic scope, Function rest) =>
    fst.eval(scope, (proc) => proc(snd, scope, rest));

  @override
  dynamic evlis(dynamic scope, Function rest) =>
    fst.eval(scope, (fst) => snd.evlis(scope, (snd) => rest(Pair(fst, snd))));

  @override
  dynamic exec(dynamic scope, Function rest) =>
    fst.eval(scope, (fst) => snd.exec(scope, (snd) => rest(_or(snd, fst))));

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
