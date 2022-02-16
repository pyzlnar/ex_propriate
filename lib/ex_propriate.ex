defmodule ExPropriate do
  defmacro __using__(opts \\ []) do
    expropriate_all = Keyword.get(opts, :expropriate_all, nil)

    if expropriate_all do
      quote do
        import Kernel, except: [defp: 1, defp: 2]
        import ExPropriate, only: [defp: 1, defp: 2]
      end
    end
  end

  defmacro defp(call, expr \\ nil)

  defmacro defp(call, do: body) do
    quote do
      def unquote(call), do: unquote(body)
    end
  end

  defmacro defp(call, nil) do
    quote do
      def unquote(call)
    end
  end
end
