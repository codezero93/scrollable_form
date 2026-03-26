# scrollable_form

A Flutter package that auto scrolls to the first invalid field when form validation fails.

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
  }
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
