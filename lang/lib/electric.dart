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

import "src/value.dart";
import "src/unit.dart";
import "src/pair.dart";
import "src/symbol.dart";
import "src/scope.dart";
import "src/procedure.dart";
import "src/primitive.dart";
import "src/applicative.dart";
import "src/operative.dart";
import "src/read.dart";

export "src/value.dart";
export "src/unit.dart";
export "src/pair.dart";
export "src/symbol.dart";
export "src/scope.dart";
export "src/procedure.dart";
export "src/primitive.dart";
export "src/applicative.dart";
export "src/operative.dart";
export "src/read.dart";

Scope initialScope() {
  var init = Scope.empty();

  dynamic debug(dynamic args, dynamic scope, Function rest) {
    print("debugging...");
    return rest(Unit());
  }

  init["debug"] = Primitive(debug);
  
  return init;
}
