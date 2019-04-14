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

import "../unit.dart";
import "../pair.dart";
import "procedure.dart";

class Product extends Procedure {
  final Procedure fst;
  final Procedure snd;

  Product(Procedure this.fst, Procedure this.snd);

  @override
  bool get isCombinator {
    return fst.isCombinator && snd.isCombinator;
  }

  @override
  dynamic call(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.fst is Pair);
    assert(args.snd is Unit);
    var lhs = fst.call(Pair(args.fst.fst, unit), scope, (x) => x);
    var rhs = snd.call(Pair(args.fst.snd, unit), scope, (x) => x);
    return rest(Pair(lhs, rhs));
  }
}
