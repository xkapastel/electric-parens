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

import "package:electric/src/value.dart" as api;

enum Tag {
  lparen,
  rparen,
  space,
  symbol,
}

class Token {
  final Tag tag;
  final String value;
  const Token(Tag this.tag, String this.value);

  factory Token.lparen() => Token(Tag.lparen, "(");
  factory Token.rparen() => Token(Tag.rparen, ")");
  factory Token.space(String value) => Token(Tag.space, value);
  factory Token.symbol(String value) => Token(Tag.symbol, value);
}

List<api.Value> read(String src) {
  var tokens = tokenize(src);
  return parse(tokens);
}

List<Token> tokenize(String runes) {
  var isLparen = (rune) => rune == "(";
  var isRparen = (rune) => rune == ")";
  var isSpace = (rune) =>
    [" ", "\t", "\r", "\n"].contains(rune);
  var isSeparator = (rune) =>
    isLparen(rune) || isRparen(rune) || isSpace(rune);

  int index = 0;
  List<Token> buf = [];

  while (index < runes.length) {
    var rune = runes[index];
    if (isLparen(rune)) {
      var token = Token.lparen();
      buf.add(token);
      index++;
    } else if (isRparen(rune)) {
      var token = Token.rparen();
      buf.add(token);
      index++;
    } else if (isSpace(rune)) {
      int start = index;
      while (index < runes.length) {
        var rune = runes[index];
        if (!isSpace(rune)) {
          break;
        }
        index++;
      }
      var value = runes.substring(start, index);
      var token = Token.space(value);
      buf.add(token);
    } else {
      int start = index;
      while (index < runes.length) {
        var rune = runes[index];
        if (isSeparator(rune)) {
          break;
        }
        index++;
      }
      var value = runes.substring(start, index);
      var token = Token.symbol(value);
      buf.add(token);
    }
  }
  return buf;
}

List<api.Value> parse(List<Token> tokens) {
  int index = 0;
  List<api.Value> buf = [];
  List<List<api.Value>> stack = [];

  while (index < tokens.length) {
    var token = tokens[index];
    switch (token.tag) {
    case Tag.lparen:
      stack.add(buf);
      buf = [];
      index++;
      break;
    case Tag.rparen:
      if (stack.isEmpty) {
        throw "parens";
      }
      api.Value xs = api.Unit();
      for (var value in buf.reversed) {
        xs = api.Pair(value, xs);
      }
      buf = stack.removeLast();
      buf.add(xs);
      index++;
      break;
    case Tag.space:
      index++;
      break;
    case Tag.symbol:
      var value = api.Symbol(token.value);
      buf.add(value);
      index++;
      break;
    }
  }
  return buf;
}
