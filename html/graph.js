var d3 = window.d3;
var console = window.console;
var $ = window.$;
var h = 300;

//TODO: too many magic constants in this file

function onLoad (jsondata) {
    "use strict";
    function redraw() {
        var w = $("#chart").parent().width() - 60;
        draw(jsondata, w, h);
    }
    window.onresize = redraw;
    redraw();
}

function draw(jsondata, w, h) {
    "use strict";

    d3.select("#chart")
        .selectAll('*')
        .remove();

    var chart = d3.select("#chart")
        .attr("class", "chart")
        .attr("width", w + 60)
        .attr("height", h + 40)
        .append("g")
        .attr("transform", "translate(30,20)");

    var x = d3.scale.linear()
        .domain([0, 24])
        .range([0, w]);

    var y = d3.scale.linear()
        .domain([10, 80])
        .range([h, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .ticks(24);

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(10);

    chart.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + h + ")")
        .call(xAxis);

    chart.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0,0)")
        .call(yAxis);

    chart.selectAll("line.x")
        .data(x.ticks(24))
        .enter().append("line")
        .attr("class", "x")
        .attr("x1", x)
        .attr("x2", x)
        .attr("y1", 0)
        .attr("y2", h)
        .style("stroke", "#ccc");

    chart.selectAll("line.y")
        .data(y.ticks(10))
        .enter().append("line")
        .attr("class", "y")
        .attr("x1", 0)
        .attr("x2", w)
        .attr("y1", y)
        .attr("y2", y)
        .style("stroke", "#ccc");


    var line = d3.svg.line()
        .x(function (d) {
            return x(d.x);
        })
        .y(function (d) {
            return y(d.y);
        })
        .interpolate("linear");

    chart.append("svg:path")
        .attr("d", line(jsondata.temp))
        .style("stroke-width", 2)
        .style("stroke", "steelblue")
        .style("fill", "none");

    //important not to select all text here, otherwise we clash with existing (tick labels?)
    chart.selectAll("text.label")
        .data(jsondata.current)
        .enter()
        .append("svg:text")
        .text(function (d) {
            return d.y;
        })
        .attr("class", "label")
        .attr("x", function (d) {
            return x(d.x) + 5;
        })
        .attr("y", function (d) {
            return y(d.y);
        })
        .attr("font-family", "sans-serif")
        .attr("font-size", "16px")
        .attr("fill", "black");
}


d3.json('tempdata.json' + window.location.search, onLoad);

