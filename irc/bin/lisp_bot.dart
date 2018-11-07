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

import "package:lisp/lisp.dart" as lisp;
import "package:irc/irc.dart" as irc;
import "dart:io" as io;
import "dart:async" as async;

main() async {
  var server   = io.Platform.environment["ELECTRIC_IRC_SERVER"];
  var nickname = io.Platform.environment["ELECTRIC_IRC_NICKNAME"];
  var password = io.Platform.environment["ELECTRIC_IRC_PASSWORD"];
  var channel  = io.Platform.environment["ELECTRIC_IRC_CHANNEL"];
  var signal   = "${nickname}:";

  var socket = await io.Socket.connect(server, 6667);
  var client = irc.Client(socket);

  var scope  = lisp.init();
  var uid    = 0;

  client.pass(password);
  client.nick(nickname);
  client.join(channel);

  await for (var message in client.messages) {
    switch (message.type) {
    case "JOIN":
      break;
    case "PING":
      client.pong(message.args(0));
      break;
    case "PRIVMSG":
      var target = message.args(0);
      var string = message.args(1);
      if (target == channel && string.startsWith(signal)) {
        var body = string.replaceFirst(signal, "");
        try {
          var values = lisp.read(body);
          for (var value in values) {
            var result = value.eval(scope, (x) => x);
            var name = "\$${uid}";
            uid++;
            scope[name] = result;
            client.privmsg(channel, "${name} = ${result}");
          }
        } catch(e) {
          client.privmsg(channel, "?");
        }
      }
      break;
    default:
      break;
    }
  }
}
