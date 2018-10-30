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

import "dart:collection";
import "package:electric/src/lisp/value.dart";

class Scope extends Value {
  Scope parent;
  Map<String, dynamic> frame;

  Scope(Scope this.parent) {
    frame = new HashMap();
  }

  factory Scope.empty() =>
    Scope(null);

  dynamic operator[](dynamic key) {
    key = key.toString();
    if (frame.containsKey(key)) {
      return frame[key];
    }
    if (parent != null) {
      return parent[key];
    }
    throw "undefined";
  }

  void operator[]=(dynamic key, dynamic value) {
    key = key.toString();
    frame[key] = value;
  }

  @override
  String toString() =>
    "<scope>";
}
