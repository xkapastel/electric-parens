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

import "value.dart";
import "unit.dart";
import "pair.dart";
import "symbol.dart";
import "number.dart";
import "stringz.dart";

enum _Tag {
  lparen,
  rparen,
  space,
  symbol,
  number,
  string,
}

class _Token {
  final _Tag tag;
  final dynamic value;

  const _Token(_Tag this.tag, dynamic this.value);

  factory _Token.lparen()             => _Token(_Tag.lparen, "(");
  factory _Token.rparen()             => _Token(_Tag.rparen, ")");
  factory _Token.space(String value)  => _Token(_Tag.space, value);
  factory _Token.symbol(String value) => _Token(_Tag.symbol, value);
  factory _Token.number(double value) => _Token(_Tag.number, value);
  factory _Token.string(String value) => _Token(_Tag.string, value);
}

List<Value> read(String src) {
  var tokens = _tokenize(src);
  return _parse(tokens);
}

List<_Token> _tokenize(String runes) {
  var isLparen = (rune) => rune == "(";
  var isRparen = (rune) => rune == ")";
  var isQuote  = (rune) => rune == '"';
  var isSpace = (rune) =>
    [" ", "\t", "\r", "\n"].contains(rune);
  var isSeparator = (rune) =>
    isLparen(rune) || isRparen(rune) || isSpace(rune);

  int index = 0;
  List<_Token> buf = [];

  while (index < runes.length) {
    var rune = runes[index];
    if (isLparen(rune)) {
      var token = _Token.lparen();
      buf.add(token);
      index++;
    } else if (isRparen(rune)) {
      var token = _Token.rparen();
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
      var token = _Token.space(value);
      buf.add(token);
    } else if (isQuote(rune)) {
      index++;
      int start = index;
      while (index < runes.length) {
        var rune = runes[index];
        if (isQuote(rune)) {
          break;
        }
        index++;
      }
      assert(index < runes.length);
      var value = runes.substring(start, index);
      var token = _Token.string(value);
      buf.add(token);
      index++;
    } else {
      int start = index;
      while (index < runes.length) {
        var rune = runes[index];
        if (isSeparator(rune)) {
          break;
        }
        index++;
      }
      var token = null;
      var value = runes.substring(start, index);
      var maybeNumber = double.tryParse(value);
      if (maybeNumber != null) {
        token = _Token.number(maybeNumber);
      } else {
        token = _Token.symbol(value);
      }
      buf.add(token);
    }
  }
  return buf;
}

List<Value> _parse(List<_Token> tokens) {
  int index = 0;
  List<Value> buf = [];
  List<List<Value>> stack = [];

  while (index < tokens.length) {
    var token = tokens[index];
    switch (token.tag) {
    case _Tag.lparen:
      stack.add(buf);
      buf = [];
      index++;
      break;
    case _Tag.rparen:
      if (stack.isEmpty) {
        throw "parens";
      }
      Value xs = Unit();
      for (var value in buf.reversed) {
        xs = Pair(value, xs);
      }
      buf = stack.removeLast();
      buf.add(xs);
      index++;
      break;
    case _Tag.space:
      index++;
      break;
    case _Tag.symbol:
      var value = Symbol(token.value as String);
      buf.add(value);
      index++;
      break;
    case _Tag.number:
      var value = Number(token.value as double);
      buf.add(value);
      index++;
      break;
    case _Tag.string:
      var value = Stringz(token.value as String);
      buf.add(value);
      index++;
      break;
    }
  }
  return buf;
}
