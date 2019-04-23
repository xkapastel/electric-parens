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

class Message {
  final String tags;
  final String sender;
  final String type;
  final List<String> arguments;
  final String rawText;
  const Message(String this.tags, String this.sender, String this.type,
      List<String> this.arguments, String this.rawText);

  String args(int index) => arguments[index];
}

final RegExp irc = RegExp(
    r"^(?:@([^\r\n ]*) +)?(?::([^\r\n ]+) +)?([^\r\n ]+)(?: +([^:\r\n ]+[^\r\n ]*(?: +[^:\r\n ]+[^\r\n ]*)*)|)?(?: +:([^\r\n]*)| +)?[\r\n]*$");

Message parse(String src) {
  var match = irc.firstMatch(src);
  if (match == null) {
    throw "IRC";
  }
  var tags = match.group(1);
  var source = match.group(2);
  var verb = match.group(3);
  var parameters = match.group(4);
  var trailing = match.group(5);
  List<String> arguments = [];
  if (parameters != null) {
    arguments = parameters.split(" ");
  }
  if (trailing != null) {
    arguments.add(trailing);
  }
  return Message(tags, source, verb, arguments, src);
}
