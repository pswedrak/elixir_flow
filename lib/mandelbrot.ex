defmodule Mandelbrot do

  def mandelbrotPixel(line) do
    line = hd(String.split(line, "\n"))
    [x_s, y_s] = String.split(line, " ")
    {px, py} = {String.to_integer(x_s), String.to_integer(y_s)}
    hx = 3.5/200
    hy = 2/150
    x0 = px * hx - 2.5
    y0 = py * hy - 1
    x = 0.0
    y = 0.0
    iter = 0
    max_iter = 1000

    color = mandelbrotIter(x, y, x0, y0, iter, max_iter)
    Integer.to_string(px) <> " " <> Integer.to_string(py) <> " " <> Integer.to_string(color) <> "\r\n"
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

  def mandelbrot(points) do
    to_save = File.stream!(points, [], :line)
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn line, acc -> [mandelbrotPixel(line)] ++ acc end)
    |> Enum.into([])
    |> List.to_string()

     File.write!("results.txt", to_save)
    end
end

