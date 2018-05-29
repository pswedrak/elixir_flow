defmodule Words do

  def countWords_parallel(name) do
    File.stream!(name, [], :line)
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, map ->
      Map.update(map, word, 1, & &1+1) end)
    |> Enum.into(%{})
  end
  
  def countWords(name) do
    File.read!(name)
	  |> String.split("\n")
    |> Enum.flat_map(&String.split/1)
    |> Enum.reduce(%{}, fn word, map ->
      Map.update(map, word, 1, & &1+1) end)
  end

	def testTimeN(name, n) do
		testTimer(name, n, {0, 0, n})
	end
	
	defp testTimer(name, n, {par, seq, m}) do
    case n do
      0 -> {par / 1000000, seq / 1000000}
      _ ->
           parallelTime = fn -> countWords_parallel(name) end |> :timer.tc |> elem(0)
           seqTime = fn -> countWords(name) end |> :timer.tc |> elem(0)
           testTimer(name, n-1, {par + parallelTime / m, seq + seqTime / m, m})
           end
  end
		
	
end
