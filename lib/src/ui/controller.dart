import 'package:flutter/material.dart';
import 'package:xterm/src/core/buffer/cell_offset.dart';
import 'package:xterm/src/core/buffer/range.dart';
import 'package:xterm/src/core/buffer/range_block.dart';
import 'package:xterm/src/core/buffer/range_line.dart';
import 'package:xterm/src/ui/pointer_input.dart';
import 'package:xterm/src/ui/selection_mode.dart';

class TerminalController with ChangeNotifier {
  BufferRange? _selection;

  BufferRange? get selection => _selection;

  SelectionMode _selectionMode;

  SelectionMode get selectionMode => _selectionMode;

  PointerInputs _pointerInputs;
  bool _suspendPointerInputs;

  /// True if sending pointer events to the terminal is suspended.
  bool get suspendedPointerInputs => _suspendPointerInputs;

  /// The set of pointer events which will be used as mouse input for the terminal.
  PointerInputs get pointerInput => _pointerInputs;

  TerminalController({
    SelectionMode selectionMode = SelectionMode.line,
    PointerInputs pointerInputs = const PointerInputs.none(),
    bool suspendPointerInput = false,
  })  : _selectionMode = selectionMode,
        _pointerInputs = pointerInputs,
        _suspendPointerInputs = suspendPointerInput;

  void setSelection(BufferRange? range) {
    range = range?.normalized;

    if (_selection != range) {
      _selection = range;
      notifyListeners();
    }
  }

  void setSelectionRange(CellOffset begin, CellOffset end) {
    final range = _modeRange(begin, end);
    setSelection(range);
  }

  BufferRange _modeRange(CellOffset begin, CellOffset end) {
    switch (selectionMode) {
      case SelectionMode.line:
        return BufferRangeLine(begin, end);
      case SelectionMode.block:
        return BufferRangeBlock(begin, end);
    }
  }

  void setSelectionMode(SelectionMode newSelectionMode) {
    // If the new mode is the same as the old mode,
    // nothing has to be changed.
    if (_selectionMode == newSelectionMode) {
      return;
    }
    // Set the new mode.
    _selectionMode = newSelectionMode;
    // Check if an active selection exists.
    final selection = _selection;
    if (selection == null) {
      notifyListeners();
      return;
    }
    // Convert the selection into a selection corresponding to the new mode.
    setSelection(_modeRange(selection.begin, selection.end));
  }

  // Select which type of pointer events are send to the terminal.
  void setPointerInputs(PointerInputs pointerInput) {
    _pointerInputs = pointerInput;
    notifyListeners();
  }

  // Toggle sending pointer events to the terminal.
  void setSuspendPointerInput(bool suspend) {
    _suspendPointerInputs = suspend;
    notifyListeners();
  }

  // Returns true if this type of PointerInput should be send to the Terminal.
  bool shouldSendPointerInput(PointerInput pointerInput) {
    // Always return false if pointer input is suspended.
    return _suspendPointerInputs
        ? false
        : _pointerInputs.inputs.contains(pointerInput);
  }

  void clearSelection() {
    _selection = null;
    notifyListeners();
  }

  void addHighlight(BufferRange? range) {
    // TODO: implement addHighlight
  }

  void clearHighlight() {
    // TODO: implement clearHighlight
  }
}
