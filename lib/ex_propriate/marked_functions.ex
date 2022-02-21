defmodule ExPropriate.MarkedFunctions do
  @moduledoc """
  This module handles expropriation of function-level granularity.

  It can be set up like this:

  ```elixir
  defmodule MyModule do
    use ExPropriate

    # Function becomes public
    @expropriate true
    defp expropriated_function,
      do: :am_expropriated

    # Functions with multiple bodies only need to be tagged on the first body
    @expropriate true
    defp divide_by(number) when is_integer(number) and number > 0,
      do: {:ok, div(100, number)}

    defp divide_by(_other),
      do: :error

    # Untagged functions remain private
    defp remains_private,
      do: :am_private
  end

  MyModule.expropriated_function
  # :am_expropriated

  MyModule.divide_by(2)
  # { :ok, 50 }

  MyModule.divide_by(0)
  # :error

  MyModule.remains_private
  # (UndefinedFunctionError) function MyModule.remains_private/0 is undefined or private.
  ```

  The objective of this module was to be able to explicitly state which functions need to be
  expropriated. The tradeoff is that this module is more "_intrusive_" than the module-level
  granularity, since it overrides both `Kernel.def/2` and `Kernel.defp/2`.

  Also a friendly reminder that the functions and macros contained in this module are for internal
  use of the library and it's advised _against_ using them directly.
  """

  @typedoc """
  AST containing the definition of a function's body.

  Typically it's a keyword list containing at least a `[do: expr]`. It also may be `nil` (if only
  the function head is being declared), and it may also contain other keys like `:rescue`, `:catch`,
  `:after`, etc.

  ```elixir
  [do: {:+, [], [1, 2]}]
  |> Macro.to_string
  # "[do: 1 + 2]"

  [
    do: {
      :/,
      [],
      [{:a, [], nil}, {:b, [], Elixir}]
    },
    rescue: [{
      :->,
      [],
      [
        [{:error, [], nil}],
        {{:., [], [{:__aliases__, [], [:IO]}, :puts]}, [],
        [{:error, [], nil}]}
      ]
    }]
  ]
  |> Macro.to_string
  # "[do: a / b, rescue: (error -> IO.puts(error))]"
  ```
  """

  @type fn_body :: Macro.t | nil

  @typedoc """
  AST containing the definition of a function's head.

  Contains at least the function name, arguments and clauses.
  Does not contain `def` or `defp`.

  **Examples**:

  ```elixir
  {:with_no_args, [], []}
  |> Macro.to_string
  # "with_no_args()"

  {:with_two_args, [], [{:arg1, [], nil}, {:arg2, [], nil}}
  |> Macro.to_string
  # "with_two_args(arg1, arg2)"

  {
    :when,
    [],
    [
      {:with_when, [], [{:arg, [], nil}]},
      {:>, [], [{:arg,  [], nil}, 0]}
    ]
  }
  |> Macro.to_string
  # "with_when(arg) when arg > 1"
  ```
  """

  @type fn_head :: Macro.t

  @typedoc """
  Tuple containing a function's name and arity.

  ```elixir
  {:my_function, 2}
  ```
  """
  @type fn_name :: {name :: atom, arity :: non_neg_integer}

  @doc """
  Generates the AST necessary to expropriate only tagged functions on compile time.

  - Injects this module's `def/2` and `defp/2` macro in favor of `Kernel.def/2` and `Kernel.defp/2`.
  - Setups attributes that are later used by the `def/2` and `defp/2` macros.
  """
  @spec generate_use_ast() :: Macro.t
  def generate_use_ast do
    quote do
      import Kernel, except: [def: 1, def: 2, defp: 1, defp: 2]
      import unquote(__MODULE__), only: [def: 1, def: 2, defp: 1, defp: 2]

      @expropriate false
      Module.register_attribute(__MODULE__, :expropriated_names, accumulate: true)
    end
  end

  @doc """
  Generates AST to prevent warnings for unused `@expropriate` attributes.

  These warnings happened when the module has `@expropriate` attributes, but ExPropriate is disabled
  at a config level. Eg: in `prod` environment.
  """
  @spec generate_unused_ast() :: Macro.t
  def generate_unused_ast do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Module.delete_attribute(__MODULE__, :expropriate)
    end
  end

  @doc """
  An override of `Kernel.def/2`.

  This macro checks if the `@expropriate` attribute was set to `true` before defining a public
  function, and outputs a warning if that's the case.

  Regardless of the warning, it _always_ defines the fuction using `Kernel.def/2`
  """
  defmacro def(fn_head, fn_body \\ nil) do
    quote do
      if @expropriate do
        @expropriate false
        IO.warn("You set @expropriate before a public function.", Macro.Env.stacktrace(__ENV__))
      end
      unquote(__MODULE__.define_public(fn_head, fn_body))
    end
  end

  @doc """
  An override of `Kernel.defp/2`.

  This macro decides whether or not the expropriate the function body based on the following
  criteria:

  * The `@expropriate` attribute is set to `true`
  * The function's name (`t:fn_name/0`) was already expropriated. (For functions with multiple
    bodies)
  """
  defmacro defp(fn_head, fn_body \\ nil) do
    case fn_head_to_name(fn_head) do
      {:ok, fn_name} ->
        quote do
          cond do
            @expropriate ->
              unquote(define_first_public_body(fn_name, fn_head, fn_body))
            unquote(fn_name) in @expropriated_names ->
              unquote(define_public(fn_head, fn_body))
            true ->
              unquote(define_private(fn_head, fn_body))
          end
        end
      _ ->
        message = "ExPropriate: There was an error expropriating the function: #{Macro.to_string(fn_head)}"
        quote do
          IO.warn(unquote(message), Macro.Env.stacktrace(__ENV__))
          unquote(define_private(fn_head, fn_body))
        end
    end
  end

  @doc """
  Transforms a function's head AST into a tuple containing the name and arity of the function.
  """
  @spec fn_head_to_name(fn_head) :: {:ok, fn_name} | :error
  def fn_head_to_name({:when, _, [fn_head|_checks]}) do
    fn_head_to_name(fn_head)
  end

  def fn_head_to_name({name, _, nil}) when is_atom(name) do
    {:ok, {name, 0}}
  end

  def fn_head_to_name({name, _, args}) when is_atom(name) and is_list(args) do
    {:ok, {name, Enum.count(args)}}
  end

  def fn_head_to_name(_other) do
    :error
  end

  @doc """
  Defines a public function via `Kernel.def/2`, and sets the necessary attributes for the following
  bodies.

  Called by expropriated functions when they define their first body. In addition to defining the
  function as public, this function also sets the `@expropriate` attribute back to `false` and
  registers the function's name to the `@expropriated_names` attribute.

  If the function has multiple bodies, it will directly call `define_public/2` instead.
  """
  @spec define_first_public_body(fn_name, fn_head, fn_body) :: Macro.t
  def define_first_public_body(fn_name, fn_head, fn_body) do
    quote do
      @expropriate false
      @expropriated_names unquote(fn_name)
      unquote(define_public(fn_head, fn_body))
    end
  end

  @doc """
  Defines a public function via `Kernel.def/2`

  Called by functions that are being expropriated.
  """
  @spec define_public(fn_head, fn_body) :: Macro.t
  def define_public(fn_head, fn_body) do
    quote do
      Kernel.def unquote(fn_head), unquote(fn_body)
    end
  end

  @doc """
  Defines a private function via `Kernel.defp/2`

  Called by functions that are **not** being expropriated.
  """
  @spec define_private(fn_head, fn_body) :: Macro.t
  def define_private(fn_head, fn_body) do
    quote do
      Kernel.defp unquote(fn_head), unquote(fn_body)
    end
  end
end
