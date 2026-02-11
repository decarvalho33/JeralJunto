import 'dart:async';

import 'package:flutter/material.dart';

class PostFrameActions {
  const PostFrameActions._();

  static void run(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  static void showSnackBar(BuildContext context, SnackBar snackBar) {
    run(() {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  static Future<T?> showDialogPostFrame<T>(
    BuildContext context,
    WidgetBuilder builder,
  ) {
    final completer = Completer<T?>();
    run(() async {
      if (!context.mounted) {
        completer.complete(null);
        return;
      }
      final result = await showDialog<T>(
        context: context,
        builder: builder,
      );
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
    return completer.future;
  }

  static Future<T?> push<T>(BuildContext context, Route<T> route) {
    final completer = Completer<T?>();
    run(() async {
      if (!context.mounted) {
        completer.complete(null);
        return;
      }
      final result = await Navigator.of(context).push(route);
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
    return completer.future;
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool showDragHandle = false,
  }) {
    final completer = Completer<T?>();
    run(() async {
      if (!context.mounted) {
        completer.complete(null);
        return;
      }
      final result = await showModalBottomSheet<T>(
        context: context,
        showDragHandle: showDragHandle,
        builder: builder,
      );
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
    return completer.future;
  }
}
