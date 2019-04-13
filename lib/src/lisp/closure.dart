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
import "procedure.dart";

class Closure extends Procedure {
  final Procedure lhs;
  final Procedure mid;
  final Procedure rhs;

  Closure(Procedure this.lhs, Procedure this.mid, Procedure this.rhs);

  @override
  bool get isCombinator {
    return lhs.isCombinator && mid.isCombinator && rhs.isCombinator;
  }

  @override
  dynamic call(dynamic args, dynamic scope, Function rest) {
    return lhs.call(args, scope, (result) {
      var args = Pair(result, unit);
      return mid.call(args, scope, (result) {
        var args = Pair(result, unit);
        return rhs.call(args, scope, rest);
      });
    });
  }
}
