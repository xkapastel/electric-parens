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

import "unit.dart";
import "pair.dart";
import "symbol.dart";
import "scope.dart";
import "procedure.dart";

class Operative extends Procedure {
  final dynamic params;
  final dynamic body;
  final dynamic lexical;
  final dynamic dynamik;

  Operative(dynamic this.params, dynamic this.body, dynamic this.lexical,
      dynamic this.dynamik) {}

  @override
  bool get isCombinator => false;

  @override
  dynamic call(dynamic args, dynamic scope, Function rest) {
    Scope local = Scope(lexical);
    dynamic lhs = params;
    dynamic rhs = args;
    while (lhs is! Unit) {
      if (lhs is Symbol) {
        local[lhs] = rhs;
        break;
      } else {
        assert(lhs is Pair);
        assert(rhs is Pair);
        assert(lhs.fst is Symbol);
        local[lhs.fst] = rhs.fst;
        lhs = lhs.snd;
        rhs = rhs.snd;
      }
    }
    if (dynamik is Symbol) {
      local[dynamik] = scope;
    } else {
      assert(dynamik is Unit);
    }
    return body.exec(local, rest);
  }
}
