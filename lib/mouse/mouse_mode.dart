import 'package:xterm/mouse/position.dart';
import 'package:xterm/terminal/terminal.dart';

abstract class MouseMode {
  const MouseMode();

  static const none = MouseModeNone();
  // static const x10 = MouseModeX10();
  static const vt200 = MouseModeVT200();
  // static const buttonEvent = MouseModeX10();

  void onTap(Terminal terminal, Position offset);
  void onDoubleTap(Terminal terminal, Position offset) {}
  void onPanStart(Terminal terminal, Position offset) {}
  void onPanUpdate(Terminal terminal, Position offset) {}
}

class MouseModeNone extends MouseMode {
  const MouseModeNone();

  @override
  void onTap(Terminal terminal, Position offset) {
    terminal.debug.onMsg('tap: $offset');
  }

  @override
  void onDoubleTap(Terminal terminal, Position offset) {
    terminal.selectWordOrRow(offset);
  }

  @override
  void onPanStart(Terminal terminal, Position offset) {
    terminal.selection!.init(offset);
  }

  @override
  void onPanUpdate(Terminal terminal, Position offset) {
    terminal.selection!.update(offset);
  }
}

class MouseModeX10 extends MouseMode {
  const MouseModeX10();

  @override
  void onTap(Terminal terminal, Position offset) {
    final btn = 1;

    final px = offset.x + 1;
    final py = terminal.buffer.convertRawLineToViewLine(offset.y) + 1;

    final buffer = StringBuffer();
    buffer.writeCharCode(0x1b);
    buffer.write('[M');
    buffer.writeCharCode(btn + 32);
    buffer.writeCharCode(px + 32);
    buffer.writeCharCode(py + 32);
    terminal.backend?.write(buffer.toString());
  }
}

class MouseModeVT200 extends MouseMode {
  const MouseModeVT200();

  @override
  void onTap(Terminal terminal, Position offset) {
    final btn = 1;

    final px = offset.x + 1;
    final py = terminal.buffer.convertRawLineToViewLine(offset.y) + 1;

    final buffer = StringBuffer();
    // Create escape sequence signaling that button 1 is pressed.
    buffer.writeCharCode(0x1b);
    buffer.write('[M');
    buffer.writeCharCode(btn - 1); // 0 -> MB1, 1 -> MB2, 2 -> MB3
    buffer.writeCharCode(px + 32); // Coordinates are encoded as for X10 mouse.
    buffer.writeCharCode(py + 32);
    // Create escape sequence signaling that button 1 is released.
    buffer.writeCharCode(0x1b);
    buffer.write('[M');
    buffer.writeCharCode(3); // 3 signals a release
    buffer.writeCharCode(px + 32); // Coordinates are encoded as for X10 mouse.
    buffer.writeCharCode(py + 32);
    terminal.backend?.write(buffer.toString());
  }
}

abstract class ExtendedMouseMode {
  const ExtendedMouseMode();

  static const none = ExtendedMouseModeNone();
  static const sgr = ExtendedMouseModeSGR();

  void onTap(Terminal terminal, Position offset) {}
  void onDoubleTap(Terminal terminal, Position offset) {}
  void onPanStart(Terminal terminal, Position offset) {}
  void onPanUpdate(Terminal terminal, Position offset) {}
}

class ExtendedMouseModeNone extends ExtendedMouseMode {
  const ExtendedMouseModeNone();
}

class ExtendedMouseModeSGR extends ExtendedMouseMode {
  const ExtendedMouseModeSGR();
  @override
  void onTap(Terminal terminal, Position offset) {
    final btn = 1;

    final px = offset.x + 1;
    final py = terminal.buffer.convertRawLineToViewLine(offset.y) + 1;

    final buffer = StringBuffer();
    // Create escape sequence signaling that button 1 is pressed.
    buffer.writeCharCode(0x1b);
    buffer.write('[<');
    buffer.write((btn - 1).toString()); // 0 -> MB1, 1 -> MB2, 2 -> MB3
    buffer.write(';');
    buffer.write(px.toString()); // Coordinates are encoded as digits.
    buffer.write(';');
    buffer.write(py.toString());
    buffer.write('M');
    // Create escape sequence signaling that button 1 is released.
    buffer.writeCharCode(0x1b);
    buffer.write('[<');
    buffer.write((btn - 1).toString()); // 0 -> MB1, 1 -> MB2, 2 -> MB3
    buffer.write(';');
    buffer.write(px.toString()); // Coordinates are encoded as digits.
    buffer.write(';');
    buffer.write(py.toString());
    buffer.write('m');
    terminal.backend?.write(buffer.toString());
  }
}
