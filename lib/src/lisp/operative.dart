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

import "package:eparens/src/lisp/value.dart";
import "package:eparens/src/lisp/unit.dart";
import "package:eparens/src/lisp/pair.dart";
import "package:eparens/src/lisp/symbol.dart";
import "package:eparens/src/lisp/scope.dart";
import "package:eparens/src/lisp/procedure.dart";

class Operative extends Procedure {
  final dynamic params;
  final dynamic body;
  final dynamic statik;
  final dynamic dynamik;

  Operative(
    dynamic this.params,
    dynamic this.body,
    dynamic this.statik,
    dynamic this.dynamik) {
  }

  @override
  dynamic call(dynamic args, dynamic scope, Function rest) {
    Scope local = Scope(statik);
    dynamic lhs = params;
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
    return body.exec(local, rest);
  }
}
