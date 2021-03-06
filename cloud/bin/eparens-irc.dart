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
import "package:eparens/image.dart" as image;
import "package:eparens_cloud/irc.dart" as irc;
import "dart:io" as io;
import "util.dart" as util;

class Task {
  final String code;
  final Function sink;
  Task(String this.code, Function this.sink);
}

main() async {
  var server = io.Platform.environment["EPARENS_IRC_SERVER"];
  var nickname = io.Platform.environment["EPARENS_IRC_NICKNAME"];
  var password = io.Platform.environment["EPARENS_IRC_PASSWORD"];
  var channel = io.Platform.environment["EPARENS_IRC_CHANNEL"];
  var signal = "${nickname}:";

  var socket = await io.Socket.connect(server, 6667);
  var client = irc.Client(socket);

  var env = null;
  try {
    env = await image.open("./src");
  } on lisp.Error catch (err) {
    print(err.error);
    return;
  }
  var uid = 0;

  Stream<Task> parse(Stream<irc.Message> messages) async* {
    await for (var message in messages) {
      print(message.rawText);
      switch (message.type) {
        case "PING":
          var body = message.args(0);
          client.pong(body);
          break;
        case "PRIVMSG":
          var target = message.args(0);
          var string = message.args(1);
          if (target == channel && string.startsWith(signal)) {
            var code = string.replaceFirst(signal, "");
            var sink = (data) {
              print("=> ${data}");
              client.privmsg(channel, data);
            };
            yield Task(code, sink);
          } else if (target == nickname) {
            var sender = message.sender.split("!")[0];
            var code = string;
            var sink = (data) {
              print("=> ${data}");
              client.privmsg(sender, data);
            };
            yield Task(code, sink);
          }
          break;
        default:
          break;
      }
    }
  }

  client.pass(password);
  client.nick(nickname);
  client.join(channel);

  await for (var task in parse(client.messages)) {
    try {
      var values = lisp.read(task.code);
      for (var value in values) {
        var result = value.eval(env, (x) => x);
        var name = "\$${uid}";
        uid++;
        env[name] = result;
        task.sink("${name} = ${result}");
      }
    } on lisp.Error catch (err) {
      task.sink(err.error);
    }
  }
}
