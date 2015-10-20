// credits to JakobOvrum
// https://gist.github.com/JakobOvrum/1a19f670e7a3359006af
import std.traits : isCallable;

private auto curryImpl(F, CurriedArgs...)(F f, CurriedArgs curriedArgs)
{
  import std.traits : ParameterTypeTuple;

  alias Args = ParameterTypeTuple!F;

  static if(CurriedArgs.length == Args.length - 1)
    return (Args[CurriedArgs.length] lastArg) => f(curriedArgs, lastArg);
  else
    return (Args[CurriedArgs.length] nextArg) => curryImpl(f, curriedArgs, nextArg);
}

  auto curry(F)(F f)
if(isCallable!F)
{
  import std.traits : ParameterTypeTuple;

  alias Args = ParameterTypeTuple!F;

  static if(Args.length <= 1)
    return f;
  else
    return (Args[0] arg) => curryImpl(f, arg);
}

unittest
{
  int delegate() nullary = () { return 42; };
  assert(curry(nullary)() == 42);

  int delegate(int) unary = a => a;
  assert(curry(unary)(42) == 42);

  int delegate(int, int, int) sum = (a, b, c) => a + b + c;
  static assert(is(typeof(curry(sum)) == int delegate(int) delegate(int) pure nothrow @safe delegate(int) pure nothrow @safe));
  assert(curry(sum)(1)(2)(3) == 6);

  string delegate(string, int) concat = (str, n) {
    string result;
    foreach(immutable i; 0 .. n)
      result ~= str;
    return result;
  };

  assert(curry(concat)("foo")(3) == "foofoofoo");
}
