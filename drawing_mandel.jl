using Gadfly
using DataFrames
using CSV

input="C:\\Users\\piotr\\Desktop\\results.csv"
mydata=CSV.readtable(input)

plot(mydata, layer(x = "x", y = "y", color = "color", Geom.point))