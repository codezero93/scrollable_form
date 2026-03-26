# scrollable_form

A Flutter package that auto scrolls to the first invalid field when form validation fails.

---

## How it works

`validateAndScroll()` does three things in sequence:

1. **Calls `FormState.validate()`** — triggers every validator so all error messages appear at once.
2. **Walks the element tree** depth-first to find the first `FormFieldState` where `hasError == true`.
3. **Calls `Scrollable.ensureVisible()`** on that element's context, scheduled after the next frame so the error text widget is already laid out before position is measured.

No `InheritedWidget`, no registration, no per-field state, just a tree walk that runs once on submit.

---

## Usage

### 1. Replace `Form` with `ScrollableForm`

```dart
final _formKey = GlobalKey<ScrollableFormState>();

ScrollableForm(
  key: _formKey,
  child: SingleChildScrollView(
    child: Column(children: [ ... ]),
  ),
)
```

### 2. Call `validateAndScroll()` on submit

```dart
void _submit() {
  if (_formKey.currentState!.validateAndScroll()) {
    // all valid — proceed
  }
  // invalid → form shows all errors and scrolls to the first one
}
```

---
## Customise the scroll animation

```dart
ScrollableForm(
  key: _formKey,
  scrollDuration: const Duration(milliseconds: 500),
  scrollCurve: Curves.easeInOutCubic,
  scrollAlignment: 0.2, // 0.0 = top of viewport, 1.0 = bottom
  child: ...,
)
```

---
## Requirements

- Flutter ≥ 3.10.0  
- Dart ≥ 3.0.0
