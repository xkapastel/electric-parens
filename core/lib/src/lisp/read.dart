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

enum _Tag {
  lparen,
  rparen,
  space,
  symbol,
  number,
  string,
  dot,
}

class _Token {
  final _Tag tag;
  final dynamic value;
  final int position;

  const _Token(_Tag this.tag, dynamic this.value, this.position);

  factory _Token.lparen(int pos) => _Token(_Tag.lparen, "(", pos);
  factory _Token.rparen(int pos) => _Token(_Tag.rparen, ")", pos);
  factory _Token.space(String value, int pos) => _Token(_Tag.space, value, pos);
  factory _Token.symbol(String value, int pos) =>
      _Token(_Tag.symbol, value, pos);
  factory _Token.number(double value, int pos) =>
      _Token(_Tag.number, value, pos);
  factory _Token.string(String value, int pos) =>
      _Token(_Tag.string, value, pos);
  factory _Token.dot(int pos) => _Token(_Tag.dot, ".", pos);
}

List<Value> read(String src) {
  var tokens = _tokenize(src);
  return _parse(tokens, src);
}

List<_Token> _tokenize(String runes) {
  var isLparen = (rune) => rune == "(";
  var isRparen = (rune) => rune == ")";
  var isQuote = (rune) => rune == '"';
  var isDot = (rune) => rune == '.';
  var isSpace = (rune) => [" ", "\t", "\r", "\n"].contains(rune);
  var isSeparator = (rune) => isLparen(rune) || isRparen(rune) || isSpace(rune);

  int index = 0;
  List<_Token> buf = [];

  while (index < runes.length) {
    var rune = runes[index];
    if (isLparen(rune)) {
      var token = _Token.lparen(index);
      buf.add(token);
      index++;
    } else if (isRparen(rune)) {
      var token = _Token.rparen(index);
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
      var token = _Token.space(value, start);
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
      rejectEof(runes, index);
      var value = runes.substring(start, index);
      var token = _Token.string(value, start);
      buf.add(token);
      index++;
    } else if (isDot(rune)) {
      var token = _Token.dot(index);
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
        token = _Token.number(maybeNumber, start);
      } else {
        token = _Token.symbol(value, start);
      }
      buf.add(token);
    }
  }
  return buf;
}

List<Value> _parse(List<_Token> tokens, String src) {
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
          throw Parens(src, token.position);
        }
        dynamic xs = nil;
        for (var value in buf.reversed) {
          if (value is Symbol && value.value == ".") {
            acceptPair(xs);
            acceptSymbol(xs.fst);
            acceptNil(xs.snd);
            xs = xs.fst;
          } else {
            xs = Pair(value, xs);
          }
        }
        buf = stack.removeLast();
        buf.add(xs);
        index++;
        break;
      case _Tag.space:
        index++;
        break;
      case _Tag.symbol:
        var value = null;
        if (token.value.startsWith("#")) {
          switch (token.value) {
            case "#t":
              value = Boolean(true);
              break;
            case "#f":
              value = Boolean(false);
              break;
            default:
              throw Token(token.value);
          }
        } else {
          value = Symbol(token.value as String);
        }
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
      case _Tag.dot:
        var value = Symbol(".");
        buf.add(value);
        index++;
        break;
      default:
        throw Token(token.value);
    }
  }
  return buf;
}
