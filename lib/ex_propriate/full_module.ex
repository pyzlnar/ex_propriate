defmodule ExPropriate.FullModule do
  def generate_use_ast(_opts) do
    quote do
      import Kernel, except: [defp: 1, defp: 2]
      import unquote(__MODULE__), only: [defp: 1, defp: 2]
    end
  end

  defmacro defp(fn_head, fn_body \\ nil) do
    quote do
      def unquote(fn_head), unquote(fn_body)
    end
  end
end
