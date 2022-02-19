defmodule ExPropriate.MarkedFunctions do
  def generate_use_ast(_opts) do
    quote do
      import Kernel, except: [def: 1, def: 2, defp: 1, defp: 2]
      import unquote(__MODULE__), only: [def: 1, def: 2, defp: 1, defp: 2]

      @expropriate false
      Module.register_attribute __MODULE__, :expropriated_names, accumulate: true
    end
  end

  def generate_unused_ast do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Module.delete_attribute __MODULE__, :expropriate
    end
  end

  defmacro def(fn_head, fn_body \\ nil) do
    quote do
      if @expropriate do
        @expropriate false
        IO.warn("You set @expropriate before a public function.", Macro.Env.stacktrace(__ENV__))
      end
      unquote(__MODULE__.define_public(fn_head, fn_body))
    end
  end

  defmacro defp(fn_head, fn_body \\ nil) do
    fn_name = fn_head_to_name(fn_head)
    quote do
      cond do
        @expropriate ->
          unquote(__MODULE__.define_first_public_body(fn_name, fn_head, fn_body))
        unquote(fn_name) in @expropriated_names ->
          unquote(__MODULE__.define_public(fn_head, fn_body))
        true ->
          unquote(__MODULE__.define_private(fn_head, fn_body))
      end
    end
  end

  def fn_head_to_name({:when, _, [fn_head|_checks]}) do
    fn_head_to_name(fn_head)
  end

  def fn_head_to_name({name, _, nil}) when is_atom(name) do
    {name, 0}
  end

  def fn_head_to_name({name, _, args}) when is_atom(name) and is_list(args) do
    {name, Enum.count(args)}
  end

  def define_first_public_body(fn_name, fn_head, fn_body) do
    quote do
      @expropriate false
      @expropriated_names unquote(fn_name)
      unquote(__MODULE__.define_public(fn_head, fn_body))
    end
  end

  def define_public(fn_head, nil) do
    quote do
      Kernel.def unquote(fn_head)
    end
  end

  def define_public(fn_head, fn_body) do
    quote do
      Kernel.def unquote(fn_head), unquote(fn_body)
    end
  end

  def define_private(fn_head, nil) do
    quote do
      Kernel.defp unquote(fn_head)
    end
  end

  def define_private(fn_head, fn_body) do
    quote do
      Kernel.defp unquote(fn_head), unquote(fn_body)
    end
  end
end
