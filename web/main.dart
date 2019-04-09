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

import "package:eparens/lisp.dart";

import "dart:html";

main() {
  CanvasElement canvas = document.querySelector("#display");
  CanvasRenderingContext2D ctx = canvas.getContext("2d");

  onWindowResize(event) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }

  onAnimationFrame(delta) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = "#ff0000";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    window.requestAnimationFrame(onAnimationFrame);
  }

  window.onResize.listen(onWindowResize);
  onWindowResize(null);
  onAnimationFrame(0);
}
