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

import "package:eparens/lisp.dart" as lisp;
import "dart:io" as io;

void main() {
  var scope = lisp.init();
  var uid = 0;
  while (true) {
    io.stdout.write("> ");
    var line = io.stdin.readLineSync();
    try {
      var values = lisp.read(line);
      for (var value in values) {
        var result = value.eval(scope, (x) => x);
        var name = "\$${uid}";
        uid++;
        scope[name] = result;
        print("${name} = ${result}");
      }
    } catch (e) {
      print("ERROR: ${e}");
      continue;
    }
  }
}
