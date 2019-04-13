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

import "case.dart";
import "unit.dart";
import "pair.dart";
import "procedure.dart";

class Sum extends Procedure {
  final Procedure fst;
  final Procedure snd;

  Sum(Procedure this.fst, Procedure this.snd);

  @override
  bool get isCombinator {
    return fst.isCombinator && snd.isCombinator;
  }

  @override
  dynamic call(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Case);
    assert(args.snd is Unit);
    if (args.fst is Left) {
      var inner = Pair(args.fst.body, unit);
      return fst.call(inner, scope, (result) {
        return rest(Left(result));
      });
    } else {
      assert(args.fst is Right);
      var inner = Pair(args.fst.body, unit);
      return snd.call(inner, scope, (result) {
        return rest(Right(result));
      });
    }
  }
}
