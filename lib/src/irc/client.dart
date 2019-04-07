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

import "dart:io";
import "dart:async";

import "package:eparens/src/irc/message.dart";

class Client {
  final Socket socket;

  Client(Socket this.socket);

  nick(String nickname) {
    socket.write("NICK ${nickname}\n");
    socket.write("USER ${nickname} 0 * :${nickname}\n");
  }

  pass(String password) {
    socket.write("PASS ${password}\n");
  }

  join(String channel) {
    socket.write("JOIN ${channel}\n");
  }

  pong(String message) {
    socket.write("PONG :${message}\n");
  }

  privmsg(String target, String message) {
    socket.write("PRIVMSG ${target} :${message}\n");
  }

  Stream<Message> get messages async* {
    await for (var line in stringify(socket)) {
      yield parse(line);
    }
  }
}

Stream<String> stringify(Socket socket) async* {
  List<int> buf = [];
  await for (var data in socket) {
    for (int byte in data) {
      if (byte == 10) {
        var string = String.fromCharCodes(buf);
        yield string;
        buf = [];
      } else {
        buf.add(byte);
      }
    }
  }
}
