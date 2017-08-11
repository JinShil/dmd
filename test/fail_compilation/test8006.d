/*
 * TEST_OUTPUT:
---
fail_compilation/test8006.d(48): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(52): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(53): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(54): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(55): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(56): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(57): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(58): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(59): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(60): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(61): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(62): Error: function test8006.TInt.x () is not callable using argument types (int)
fail_compilation/test8006.d(65): Error: function test8006.TString.x () is not callable using argument types (string)
fail_compilation/test8006.d(68): Error: function test8006.TString.x () is not callable using argument types (string)
---
 */

// https://issues.dlang.org/show_bug.cgi?id=8006

struct TInt
{
    int mX;

    @property int x()
    {
        return mX;
    }
}

struct TString
{
    string mX;

    @property string x()
    {
        return mX;
    }
}

void main()
{
    // modeled after code from runnable/testassign.d

    TInt ti;
    ti.x += 4;

    // all of these should fail to compile because there is
    // no setter property
    ti.x -= 2;
    ti.x *= 4;
    ti.x /= 2;
    ti.x %= 3;
    ti.x <<= 3;
    ti.x >>= 1;
    ti.x >>>= 1;
    ti.x &= 0xF;
    ti.x |= 0x8;
    ti.x ^= 0xF;
    ti.x ^^= 2;

    TString ts;
    ts.x = "abc";

    // this should fail to compile because there is no setter property
    ts.x ~= "def";
}
