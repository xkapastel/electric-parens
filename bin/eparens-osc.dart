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

import "package:eparens/lisp.dart" as lisp;
import "dart:io";
import "dart:async";
import "dart:convert";

Future<String> drain(Stream<String> stream) async {
  var buf = new StringBuffer();
  await for (var chunk in stream) {
    buf.write(chunk);
  }
  return buf.toString();
}

Future main() async {
  String src = await drain(stdin.transform(utf8.decoder));
  lisp.Scope ctx = lisp.init();
  lisp.Value proc = ctx.evalString(src);
  int rate = 22050;
  double time = 0.0;
  while (true) {
    List<int> buf = new List(rate);
    for (var i = 0; i < buf.length; i++) {
      double sample = ctx.apply1d(proc, time);
      buf[i] = (sample * 255.0).toInt();
      time += 1 / rate;
    }
    stdout.add(buf);
    try {
      await stdout.flush();
    } catch(e) {
      await stdout.close();
      break;
    }
  }
}
