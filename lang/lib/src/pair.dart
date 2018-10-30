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

import "package:electric/src/value.dart";
import "package:electric/src/unit.dart";

class Pair extends Value {
  dynamic fst;
  dynamic snd;
  bool isList;
  
  Pair(dynamic fstA, dynamic sndA) {
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
  dynamic eval(dynamic scope, Function rest) =>
    fst.eval(scope, (proc) => proc(snd, scope, rest));

  @override
  dynamic evlis(dynamic scope, Function rest) =>
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
