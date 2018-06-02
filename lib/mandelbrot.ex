defmodule Mandelbrot do

  def mandelbrotPixel(line, xf, yf) do
    line = hd(String.split(line, "\n"))
    [x_s, y_s] = String.split(line, " ")
    {px, py} = {String.to_integer(x_s), String.to_integer(y_s)}
    hx = 3.5/xf
    hy = 2/yf
    x0 = px * hx - 2.5
    y0 = py * hy - 1
    x = 0.0
    y = 0.0
    iter = 0
    max_iter = 100

    color = mandelbrotIter(x, y, x0, y0, iter, max_iter)
    Integer.to_string(px) <> "," <> Integer.to_string(py) <> "," <> Integer.to_string(color) <> "\r\n"
  end

  def mandelbrotIter(x, y, _, _, iter, max_iter) when iter < max_iter and x*x + y*y > 2*2 do
    iter
  end

  def mandelbrotIter(_, _, _, _, iter, max_iter) when iter >= max_iter  do
    iter
  end

  def mandelbrotIter(x, y, x0, y0, iter, max_iter) when iter < max_iter and x*x + y*y <= 2*2 do
    mandelbrotIter(x*x - y*y + x0, 2*x*y + y0, x0, y0, iter+1, max_iter)
  end

  def mandelbrot_parallel(points, xf, yf) do
    to_save = File.stream!(points, [], :line)
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn line, acc -> [mandelbrotPixel(line, xf, yf)] ++ acc end)
    |> Enum.into([])
    
     File.write!("results_parallel.csv", to_save)
    end

    def mandelbrot(points, xf, yf) do
      to_save = File.read!(points)
      |> String.split("\r\n")
      |> Enum.map(fn line -> mandelbrotPixel(line, xf, yf) end)

     File.write!("results.csv", to_save)
  end

    def test(points, xf, yf) do
      flow_time = fn -> mandelbrot_parallel(points, xf, yf) end |> :timer.tc |> elem(0)
      time = fn -> mandelbrot(points, xf, yf) end |> :timer.tc |> elem(0)
      {flow_time / 1000000, time / 1000000}
  end

  def testTimeN(points, xf, yf, n) do
    testTimer(points, xf, yf, n, {0, 0, n})
  end

  def testTimer(points, xf, yf, n, {par, seq, m}) do
    case n do
      0 -> {par / 1000000, seq / 1000000}
      _ ->
        parallelTime = fn -> mandelbrot_parallel(points, xf, yf) end |> :timer.tc |> elem(0)
        seqTime = fn -> mandelbrot(points, xf, yf) end |> :timer.tc |> elem(0)
        testTimer(points, xf, yf, n-1, {par + parallelTime / m, seq + seqTime / m, m})
    end
  end

end

