/*
TEST_OUTPUT:
---
fail_compilation/dep_pascal.d(11): Error: `extern(Pascal)` is obsolete. You might want to use `extern(Windows)` instead.
---
*/

// This test was created to verify the error message emitted when using `extern(Pascal)`.  When `extern(Pascal)` is
// removed from the language, this test can be deleted.

extern (Pascal) int foop();