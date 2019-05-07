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

export "error/error.dart";
export "error/evlis.dart";
export "error/exec.dart";
export "error/combine.dart";
export "error/undefined.dart";
export "error/redefined.dart";
export "error/parens.dart";
export "error/type.dart";
export "error/eof.dart";
export "error/token.dart";

import "error/type.dart";
import "error/eof.dart";

import "../value.dart";

void acceptBoolean(Value value) {
  if (value is! Boolean) {
    throw Type("boolean", value);
  }
}

void acceptNumber(Value value) {
  if (value is! Number) {
    throw Type("number", value);
  }
}

void acceptSymbol(Value value) {
  if (value is! Symbol) {
    throw Type("symbol", value);
  }
}

void acceptString(Value value) {
  if (value is! Stringz) {
    throw Type("string", value);
  }
}

void acceptNil(Value value) {
  if (value is! Nil) {
    throw Type("nil", value);
  }
}

void acceptPair(Value value) {
  if (value is! Pair) {
    throw Type("pair", value);
  }
}

void acceptEnvironment(Value value) {
  if (value is! Environment) {
    throw Type("env", value);
  }
}

void acceptProcedure(Value value) {
  if (value is! Procedure) {
    throw Type("procedure", value);
  }
}

void acceptWrap(Value value) {
  if (value is! Wrap) {
    throw Type("wrap", value);
  }
}

void rejectNil(Value value) {
  if (value is Nil) {
    throw Type("nonnil", value);
  }
}

void rejectEof(String src, int index) {
  if (index >= src.length) {
    throw Eof(src);
  }
}
