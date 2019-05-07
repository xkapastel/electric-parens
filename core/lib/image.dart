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
import "package:path/path.dart";
import "dart:io";
import "dart:async";

Future<lisp.Environment> open(String path) async {
  var env = lisp.init();
  var directory = Directory(path);
  await for (var entity in directory.list()) {
    if (entity is File) {
      var name = basename(entity.path);
      var source = await entity.readAsString();
      var value = env.evalString(source);
      env[name] = value;
    }
  }
  return env;
}
