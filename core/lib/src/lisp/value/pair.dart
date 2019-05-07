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
import "nil.dart";
import "error.dart";

dynamic _or(dynamic lhs, dynamic rhs) {
  if (lhs is! Nil) {
    return lhs;
  }
  return rhs;
}

class Pair extends Value {
  dynamic fst;
  dynamic snd;
  bool isList;

  Pair(dynamic this.fst, dynamic this.snd) {
    if (snd is Nil) {
      isList = true;
    } else if (snd is Pair) {
      isList = snd.isList;
    } else {
      isList = false;
    }
  }

  @override
  dynamic eval(dynamic env, Function rest) {
    return fst.eval(env, (proc) {
      return proc(snd, env, rest);
    });
  }

  @override
  dynamic evlis(dynamic env, Function rest) =>
      fst.eval(env, (fst) => snd.evlis(env, (snd) => rest(Pair(fst, snd))));

  @override
  dynamic exec(dynamic env, Function rest) =>
      fst.eval(env, (fst) => snd.exec(env, (snd) => rest(_or(snd, fst))));

  @override
  String toString() {
    if (isList) {
      var buf = new StringBuffer();
      dynamic xs = this;
      buf.write("(");
      while (xs is! Nil) {
        acceptPair(xs);
        buf.write(xs.fst);
        if (xs.snd is! Nil) {
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
