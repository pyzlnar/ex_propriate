defmodule ExPropriate do
  defmacro __using__(opts \\ []) do
    expropriate_all = Keyword.get(opts, :expropriate_all, false)

    quote do
      import Kernel, except: [defp: 1, defp: 2]
      import ExPropriate, only: [defp: 1, defp: 2]

      @expropriate_all unquote(expropriate_all)
    end
  end

  defmacro defp(call, expr \\ nil)

  defmacro defp(call, do: body) do
    quote do
      if @expropriate_all do
        def unquote(call), do: unquote(body)
      else
        Kernel.defp unquote(call), do: unquote(body)
      end
    end
  end

  defmacro defp(call, nil) do
    quote do
      if @expropriate_all do
        def unquote(call)
      else
        Kernel.defp unquote(call)
      end
    end
  end
end
