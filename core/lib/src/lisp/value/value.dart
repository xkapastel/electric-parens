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

import "error.dart" as error;

class Value {
  dynamic eval(dynamic scope, Function rest) => rest(this);

  dynamic evlis(dynamic scope, Function rest) {
    throw error.Evlis(this, scope, rest);
  }

  dynamic exec(dynamic scope, Function rest) {
    throw error.Exec(this, scope, rest);
  }

  dynamic call(dynamic args, dynamic scope, Function rest) {
    throw error.Combine(this, args, scope, rest);
  }
}
