defmodule ExPropriate.FullModule do
  @moduledoc """
  This module handles expropriation of module-level granularity.

  It can be set up like this:

  ```
  defmodule MyModule do
    use ExPropriate,
      expropriate_all: true

    defp my_private_function do
      :has_been_expropriated
    end
  end

  MyModule.my_private_function
  # :has_been_expropriated
  ```

  It is important to note that this module has been designed to be less "_intrusive_" than the
  function-level granularity. The reason behind this decision is so that it can serve as a fallback
  in case there are issues with the function-level.

  Also a friendly reminder that the functions and macros contained in this module are for internal
  use of the library and it's advised _against_ using them directly.
  """

  @doc """
  Generates the ast necessary to inject this module's `defp/2` macro instead of `Kernel.defp/2`.
  """
  @spec generate_use_ast() :: Macro.t
  def generate_use_ast do
    quote do
      import Kernel, except: [defp: 1, defp: 2]
      import unquote(__MODULE__), only: [defp: 1, defp: 2]
    end
  end

  @doc """
  An override of `Kernel.defp/2`.

  This macro basically forwards the received args to the implicit `def/2`. This usually is
  `Kernel.def/2`, but it could be some other module.
  """
  defmacro defp(fn_head, fn_body \\ nil) do
    quote do
      def unquote(fn_head), unquote(fn_body)
    end
  end
end
