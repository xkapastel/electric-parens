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

class _Task {
  final String code;
  final Function sink;
  _Task(String this.code, Function this.sink);
}

Stream<_Task> session(Socket socket) async* {
  var lineDecoder = LineSplitter();
  var lines = socket.transform(utf8.decoder).transform(lineDecoder);
  try {
    await for (var line in lines) {
      print("recv: ${line}");
      yield _Task(line, (x) {
        print("send: ${x}");
        socket.writeln(x);
      });
    }
  } on FormatException catch (err) {
    // When I type C-c in telnet I get this exception, complaining about an 0xff
    // byte. So I'll just assume it's okay to use this to signal a client
    // disconnection, but in the future I'll want to think more carefully about
    // the exceptions that can occur here.
    socket.close();
  }
}

Future main() async {
  String src = await drain(stdin.transform(utf8.decoder));
  var scope = lisp.init();
  scope.evalString(src);
  var uid = 0;
  const address = "127.0.0.1";
  const port = 4000;

  print("Listening on ${address}:${port}...");
  var server = await ServerSocket.bind(address, port);
  var socket = await server.first;
  print("Client connected.");
  await for (var task in session(socket)) {
    try {
      var values = lisp.read(task.code);
      for (var value in values) {
        var result = value.eval(scope, (x) => x);
        var name = "\$${uid}";
        uid++;
        scope[name] = result;
        task.sink("${name} = ${result}");
      }
    } catch (e) {
      task.sink("?");
    }
  }
  print("Client disconnected.");
}
