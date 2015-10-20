import std.traits : isFunctionPointer;

// File not used, because, huh, I can't use those as a delegate

// private Args[..] x; == alias sequence
// >int add(int a, int b) { return a + b; }
// >AliasSeq!(int, int) operands;
// >-- OR --
// >ParameterTypeTuple!add operands;
// >operands[0] = 42;
// >operands[1] = 8;
// >assert(add(operands) == 50);

// credit:
// https://gist.github.com/JakobOvrum/8b2cd11b911079735b14

private struct Curry(uint n, F...)
    if (F.length == 1) // accept F... so that we can pass `foo()` and `&foo`
{
  import std.traits : ParameterTypeTuple;

  alias Args = ParameterTypeTuple!F;
  // static assert(is(ParameterTypeTuple!(string function(string, int)) == AliasSeq!(string, int)));
  // ParameterTypeTuple!(string function(string, int))[0] == string, ParameterTypeTuple!(string function(string, int))[1] == int

  static if (is(F[0])) // is it a type...
    private F[0] func; // then it's a function pointer or delegate type, and the function pointer or delegate needs to be stored as a field
  else
    alias func = F[0];

  private Args[0 .. n] args;

  static if (n == Args.length - 1) {
    auto ref opCall(Args[n] lastArg) {
      return func(args, lastArg);
    }
  } else {
    auto opCall(Args[n] nextArg) {
      Curry!(n + 1, F) next;
      static if(is(F[0]))
        next.func = func;
      next.args[0 .. n] = args;
      next.args[n] = nextArg;
      return next;
    }
  }
}

auto curry(F)(F func)
  if (isFunctionPointer!F || is(F == delegate))
{
  Curry!(0, F) result;
  result.func = func;
  return result;
}

auto curry(alias func)() {
  Curry!(0, func) result;
  return result;
}
