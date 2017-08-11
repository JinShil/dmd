// https://issues.dlang.org/show_bug.cgi?id=8006

/**************************************************************
* int tests
**************************************************************/
struct TInt
{
    int mX;

    @property int x()
    {
        return mX;
    }

    @property void x(int v)
    {
        mX = v;
    }

    alias x this;
}

// It was found, during the implementation of binary assignment operators
// for @property functions that if the setter was declared before the getter
// the binary assignment operator call would not compile.  This was due
// to the fact that if e.e1.copy() was called after resolveProperties(e.e1)
// that the copy() call would return the wrong overload for the @property
// function.  This is a test to guard against that.
struct TIntRev
{
    int mX;

    @property void x(int v)
    {
        mX = v;
    }

    @property int x()
    {
        return mX;
    }

    alias x this;
}

// Same as TInt but with a binary operator overload.  This is to ensure that
// since binary operator overloads have been defined any access through
// `alias this` calls the `opOpAssign` function and not the `x` property
// This behavior is is defined at https://dlang.org/spec/class.html#alias-this 
struct TIntOp
{
    int mX;

    @property int x()
    {
        return mX;
    }

    @property void x(int v)
    {
        mX = v;
    }

    int mB;
    int opOpAssign(string op)(int rhs)
    {
        return mixin("mB "~op~"= rhs");
    }

    alias x this;
}

// Same as TInt, but setter @property function returns a value
struct TIntRet
{
    int mX;

    @property int x()
    {
        return mX;
    }

    @property int x(int v)
    {
        mX = v;
        return mX;
    }

    alias x this;
}

// same as TInt, but with static @property functions
struct TIntStatic
{
    static int mX;

    static @property int x()
    {
        return mX;
    }

    static @property void x(int v)
    {
        mX = v;
    }

    alias x this;
}

// same as TIntStatic, but setter @property function returns a value
struct TIntRetStatic
{
    static int mX;

    static @property int x()
    {
        return mX;
    }

    static @property int x(int v)
    {
        mX = v;
        return mX;
    }

    alias x this;
}

// This test verifies typical arithmetic and logical operators
void testTInt(T)()
{
    // modeled after code from runnable/testassign.d
    
    static if (typeid(T) is typeid(TInt))
    {
        TInt t;
    }
    else static if (typeid(T) is typeid(TIntRev))
    {
        TIntRev t;
    }
    else static if (typeid(T) is typeid(TIntStatic))
    {
        alias t = TIntStatic;
    }
    else
    {
        static assert(false, "Type is not supported");
    }

    t.x += 4;
    assert(t.mX == 4);
    t.x -= 2;
    assert(t.mX == 2);
    t.x *= 4;
    assert(t.mX == 8);
    t.x /= 2;
    assert(t.mX == 4);
    t.x %= 3;
    assert(t.mX == 1);
    t.x <<= 3;
    assert(t.mX == 8);
    t.x >>= 1;
    assert(t.mX == 4);
    t.x >>>= 1;
    assert(t.mX == 2);
    t.x &= 0xF;
    assert(t.mX == 0x2);
    t.x |= 0x8;
    assert(t.mX == 0xA);
    t.x ^= 0xF;
    assert(t.mX == 0x5);
    t.x ^^= 2;
    assert(t.mX == 25);

    // same as test above, but through the `alias this`
    t = 0;
    t += 4;
    assert(t.mX == 4);
    t -= 2;
    assert(t.mX == 2);
    t *= 4;
    assert(t.mX == 8);
    t /= 2;
    assert(t.mX == 4);
    t %= 3;
    assert(t.mX == 1);
    t <<= 3;
    assert(t.mX == 8);
    t >>= 1;
    assert(t.mX == 4);
    t >>>= 1;
    assert(t.mX == 2);
    t &= 0xF;
    assert(t.mX == 0x2);
    t |= 0x8;
    assert(t.mX == 0xA);
    t ^= 0xF;
    assert(t.mX == 0x5);
    t ^^= 2;
    assert(t.mX == 25);
}

// This test is to verify that the setter @property function
// returns a value if it is explicitly coded to do so
void testTIntRet(T)()
{
    static if (typeid(T) is typeid(TIntRet))
    {
        TIntRet t;
    }
    else static if (typeid(T) is typeid(TIntRetStatic))
    {
        alias t = TIntRetStatic;
    }
    else
    {
        static assert(false, "Type is not supported");
    }

    int r;
    r = t.x += 4;
    assert(r == 4);
    r = t.x -= 2;
    assert(r == 2);
    r = t.x *= 4;
    assert(r == 8);
    r = t.x /= 2;
    assert(r == 4);
    r = t.x %= 3;
    assert(r == 1);
    r = t.x <<= 3;
    assert(r == 8);
    r = t.x >>= 1;
    assert(r == 4);
    r = t.x >>>= 1;
    assert(r == 2);
    r = t.x &= 0xF;
    assert(r == 0x2);
    r = t.x |= 0x8;
    assert(r == 0xA);
    r = t.x ^= 0xF;
    assert(r == 0x5);
    r = t.x ^^= 2;
    assert(r == 25);

    // same as test above, but through the `alias this`
    t = 0;
    r = t += 4;
    assert(r == 4);
    r = t -= 2;
    assert(r == 2);
    r = t *= 4;
    assert(r == 8);
    r = t /= 2;
    assert(r == 4);
    r = t %= 3;
    assert(r == 1);
    r = t <<= 3;
    assert(r == 8);
    r = t >>= 1;
    assert(r == 4);
    r = t >>>= 1;
    assert(r == 2);
    r = t &= 0xF;
    assert(r == 0x2);
    r = t |= 0x8;
    assert(r == 0xA);
    r = t ^= 0xF;
    assert(r == 0x5);
    r = t ^^= 2;
    assert(r == 25);
}

void testTIntOp()
{
    TIntOp t;
    immutable int C = 0xA5A5A5;

    // this should set the mX proeprty as it is not a binary assignment
    t = C;  
    assert(t.mX == C);

    // these should access the opOpAssign overload
    t += 4;
    assert(t.mB == 4);
    assert(t.mX == C);
    t -= 2;
    assert(t.mB == 2);
    assert(t.mX == C);
    t *= 4;
    assert(t.mB == 8);
    assert(t.mX == C);
    t /= 2;
    assert(t.mB == 4);
    assert(t.mX == C);
    t %= 3;
    assert(t.mB == 1);
    assert(t.mX == C);
    t <<= 3;
    assert(t.mB == 8);
    assert(t.mX == C);
    t >>= 1;
    assert(t.mB == 4);
    assert(t.mX == C);
    t >>>= 1;
    assert(t.mB == 2);
    assert(t.mX == C);
    t &= 0xF;
    assert(t.mB == 0x2);
    assert(t.mX == C);
    t |= 0x8;
    assert(t.mB == 0xA);
    assert(t.mX == C);
    t ^= 0xF;
    assert(t.mB == 0x5);
    assert(t.mX == C);
    t ^^= 2;
    assert(t.mB == 25);
    assert(t.mX == C);
}

/**************************************************************
* string/array tests
**************************************************************/
struct TString
{
    string mX;

    @property string x()
    {
        return mX;
    }

    @property void x(string v)
    {
        mX = v;
    }

    alias x this;
}

// same as TString, but setter @property function returns a value
struct TStringRet
{
    string mX;

    @property string x()
    {
        return mX;
    }

    @property string x(string v)
    {
        mX = v;
        return mX;
    }

    alias x this;
}

struct TStringOp
{
    string mX;

    @property string x()
    {
        return mX;
    }

    @property void x(string v)
    {
        mX = v;
    }

    string mB;
    string opOpAssign(string op)(string rhs)
    {
        return mixin("mB "~op~"= rhs");
    }

    alias x this;
}

// same as TString, but for static @property functions
struct TStringStatic
{
    static string mX;

    static @property string x()
    {
        return mX;
    }

    static @property void x(string v)
    {
        mX = v;
    }

    static alias x this;
}

// same as TStringRet, but for static @property functions
struct TStringRetStatic
{
    static string mX;

    static @property string x()
    {
        return mX;
    }

    static @property string x(string v)
    {
        mX = v;
        return mX;
    }

    static alias x this;
}

// Test string (i.e. array) operators
void testTString(T)()
{
    static if (typeid(T) is typeid(TString))
    {
        TString t;
    }
    else static if (typeid(T) is typeid(TStringStatic))
    {
        alias t = TStringStatic;
    }
    else
    {
        static assert(false, "Type is not supported");
    }

    t.x = "abc";
    t.x ~= "def";
    assert(t.mX == "abcdef");

    // same as test above, but through the `alias this`
    t = "abc";
    t ~= "def";
    assert(t.mX == "abcdef");
}

// Test string (i.e. array) operators
void testTStringOp()
{
    TStringOp t;
    immutable string C = "abc";
    t = C;             // this should set mX because it is not a binary assignment
    assert(t.mX == C);

    t.mB = "def";
    t ~= "ghi";
    assert(t.mX == C);
    assert(t.mB == "defghi");
}

// This test is to verify that the setter @property function
// returns a value if it is explicitly coded to do so
void testTStringRet(T)()
{
    static if (typeid(T) is typeid(TStringRet))
    {
        TStringRet t;
    }
    else static if (typeid(T) is typeid(TStringRetStatic))
    {
        alias t = TStringRetStatic;
    }
    else
    {
        static assert(false, "Type is not supported");
    }

    string s;
    t.x = "abc";
    s = t.x ~= "def";
    assert(s == "abcdef");

    // same as test above, but through the `alias this`
    t = "abc";
    s = t ~= "def";
    assert(s == "abcdef");
}

/**************************************************************
* ref @property breakage test
**************************************************************/
struct TRefInt
{
    TRefInt[] mX;

    this(TRefInt[] i)
    {
        mX = i;
    }

    @property ref TRefInt[] x()
    {
        return mX;
    }

    TRefInt opBinaryRight(string op)(TRefInt[] lhs) 
    { 
        mixin("return TRefInt(lhs "~op~" x);"); 
    }
}

void testRefInt()
{
    // Ensure a ref @property is not rewritten
    // This was an odd corner case found in dub's source code. We
    // test specifically for it to avoid breakage
    TRefInt tri1;
    TRefInt tri2;
    tri1.mX ~= tri2;
    tri2.mX ~= tri1;
    tri1.x ~= tri2; // tri2.opBinaryRight!("~=")(tri1.x)
    assert(tri1.mX.length == 2);
}

/**************************************************************
* Free @property function test
**************************************************************/
int mX;
@property int x() { return mX; }
@property void x(int v) { mX = v; }

// Test that free @property functions work
void testFreeFunctionsInt()
{
    x += 4;
    assert(mX == 4);
    x -= 2;
    assert(mX == 2);
    x *= 4;
    assert(mX == 8);
    x /= 2;
    assert(mX == 4);
    x %= 3;
    assert(mX == 1);
    x <<= 3;
    assert(mX == 8);
    x >>= 1;
    assert(mX == 4);
    x >>>= 1;
    assert(mX == 2);
    x &= 0xF;
    assert(mX == 0x2);
    x |= 0x8;
    assert(mX == 0xA);
    x ^= 0xF;
    assert(mX == 0x5);
    x ^^= 2;
    assert(mX == 25);
}

int mXret;
@property int xret() { return mXret; }
@property int xret(int v) { return mXret = v; }

// Same as testFreeFunctions except the we want to
// ensure the binary assignment returns a value
void testFreeFunctionsIntRet()
{
    int r;
    r = xret += 4;
    assert(r == 4);
    r = xret -= 2;
    assert(r == 2);
    r = xret *= 4;
    assert(r == 8);
    r = xret /= 2;
    assert(r == 4);
    r = xret %= 3;
    assert(r == 1);
    r = xret <<= 3;
    assert(r == 8);
    r = xret >>= 1;
    assert(r == 4);
    r = xret >>>= 1;
    assert(r == 2);
    r = xret &= 0xF;
    assert(r == 0x2);
    r = xret |= 0x8;
    assert(r == 0xA);
    r = xret ^= 0xF;
    assert(r == 0x5);
    r = xret ^^= 2;
    assert(r == 25);
}

string mXs;
@property string xs() { return mXs; }
@property void xs(string v) { mXs = v; }

void testFreeFunctionsString()
{
    xs = "abc";
    xs ~= "def";
    assert(mXs == "abcdef");
}

string mXsret;
@property string xsret() { return mXsret; }
@property string xsret(string v) { return mXsret = v; }

void testFreeFunctionsStringRet()
{
    string s;
    xsret = "abc";
    s = xsret ~= "def";
    assert(s == "abcdef");
}

void main()
{
    testTInt!TInt();
    testTInt!TIntRev();
    testTInt!TIntStatic();
    testTIntOp();

    testTIntRet!TIntRet();
    testTIntRet!TIntRetStatic();

    testTString!TString();
    testTString!TStringStatic();
    testTStringOp();

    testTStringRet!TStringRet();
    testTStringRet!TStringRetStatic();

    testFreeFunctionsInt();
    testFreeFunctionsIntRet();

    testFreeFunctionsString();
    testFreeFunctionsStringRet();

    testRefInt();
}
