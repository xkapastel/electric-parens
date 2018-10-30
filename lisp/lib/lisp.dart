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

import "src/lisp/value.dart";
import "src/lisp/unit.dart";
import "src/lisp/pair.dart";
import "src/lisp/symbol.dart";
import "src/lisp/scope.dart";
import "src/lisp/procedure.dart";
import "src/lisp/primitive.dart";
import "src/lisp/applicative.dart";
import "src/lisp/operative.dart";
import "src/lisp/read.dart";

export "src/lisp/value.dart";
export "src/lisp/unit.dart";
export "src/lisp/pair.dart";
export "src/lisp/symbol.dart";
export "src/lisp/scope.dart";
export "src/lisp/procedure.dart";
export "src/lisp/primitive.dart";
export "src/lisp/applicative.dart";
export "src/lisp/operative.dart";
export "src/lisp/read.dart";

Scope init() {
  var init = Scope.empty();

  dynamic debug(dynamic args, dynamic scope, Function rest) {
    print("debugging...");
    print(args);
    return rest(Unit());
  }

  dynamic eval(dynamic args, dynamic scope, Function rest) {
    assert(args is Pair);
    assert(args.snd is Pair);
    assert(args.snd.snd is Unit);
    return args.snd.fst.eval(scope, (local) {
      assert(local is Scope);
      return args.fst.eval(local, rest);
    });
  }

  init["debug"] = Primitive(debug);
  init["eval"]  = Primitive(eval);
  
  return init;
}
