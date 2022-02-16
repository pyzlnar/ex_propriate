# ExPropriate

ExPropariate is an Elixir library that allows you to decide whether or not a function is public at
compile time.

When would you want to do this?

Testing.

There's an argument to be had that you should be testing your private functions through your public
interfaces, and I agree! But it's also true that often times projects grow more complicated than
you'd wish.

The aim is to provide a way to be able to test your overly complicated private functions without
compromising the design. So that you may eventually refactor as necesary.

When push comes to shove, a questionably designed, but well tested function is better than a
questionably designed and vaguely tested one.

## WIP

At this time the library is in a proof of concept state, but I want to add more granularity on
config level and function level.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_propriate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_propriate, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_propriate>.

