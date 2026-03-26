import 'package:flutter/widgets.dart';

class ScrollableForm extends StatefulWidget {
  const ScrollableForm({
    super.key,
    required this.child,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.scrollDuration = const Duration(milliseconds: 400),
    this.scrollCurve = Curves.easeInOut,
    this.scrollAlignment = 0.1,
  });

  final Widget child;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onChanged;

  /// Duration of the scroll animation when jumping to an error field.
  final Duration scrollDuration;

  /// Curve of the scroll animation.
  final Curve scrollCurve;

  /// Where the field lands in the viewport after scrolling.
  /// 0.0 = top edge, 1.0 = bottom edge. 0.1 gives a comfortable top offset.
  final double scrollAlignment;

  @override
  ScrollableFormState createState() => ScrollableFormState();
}

class ScrollableFormState extends State<ScrollableForm> {
  final _formKey = GlobalKey<FormState>();

  /// Validates every [FormField] in the subtree, then scrolls to the first
  /// one that failed. Returns true only when all fields are valid.
  ///
  /// Internally this:
  ///  1. Calls [FormState.validate] — triggers every validator and marks
  ///     fields so they all show their error text at once.
  ///  2. Walks the element tree to collect every [FormFieldState] in
  ///     depth-first (top-to-bottom in the widget tree) order.
  ///  3. Picks the first one where [FormFieldState.hasError] is true.
  ///  4. Calls [Scrollable.ensureVisible] after the next frame so the error
  ///     text widget is already laid out before we measure position.
  bool validateAndScroll() {
    final formState = _formKey.currentState!;

    final isValid = formState.validate();
    if (isValid) return true;

    // Schedule after the current frame so error text widgets are laid out
    // and sized before Scrollable.ensureVisible measures their position.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final firstErrorContext =
          _findFirstErrorContext(_formKey.currentContext!);
      if (firstErrorContext != null && firstErrorContext.mounted) {
        Scrollable.ensureVisible(
          firstErrorContext,
          duration: widget.scrollDuration,
          curve: widget.scrollCurve,
          alignment: widget.scrollAlignment,
        );
      }
    });

    return false;
  }

  /// Depth-first walk of the element subtree rooted at [root].
  /// Returns the [BuildContext] of the first [FormFieldState] with an error,
  /// or null if none found.
  BuildContext? _findFirstErrorContext(BuildContext root) {
    BuildContext? result;

    void visit(Element element) {
      if (result != null) return; // stop at first hit

      if (element is StatefulElement && element.state is FormFieldState) {
        final fieldState = element.state as FormFieldState;
        if (fieldState.hasError) {
          result = element;
          return;
        }
      }

      element.visitChildElements(visit);
    }

    (root as Element).visitChildElements(visit);
    return result;
  }

  /// Passthrough to [FormState.save].
  void save() => _formKey.currentState?.save();

  /// Passthrough to [FormState.reset].
  void reset() => _formKey.currentState?.reset();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      child: widget.child,
    );
  }
}
