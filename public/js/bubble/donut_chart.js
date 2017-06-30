function donut_chart (_width, _height, _which,_data,isZero){

  if(_which == null){
    if( window.console ) console.log("selector fail");
    return 
  }
  if(_data == null){
    if(  window.console ) console.log("data invalidate or null");
    return 
  }

   var _arc = d3.scale.linear().domain([0.5,100]).range([1,50]);
   var data = _data.filter(function(d){
      return d.val >0;
   });

    data= data.map(function(d){
      return {
        name: d.name,
        val: d.val, 
        type: d.type, display_val: d.val
      };
    });
var w = (_width) || 400,
    h = (_height ) || 400,
    r = Math.min(w, h)  / 2.8,
    labelr = r + 10, // radius for label anchor
    labelr_inner = r - (Math.max(w, h)/4.2), // radius for label anchor
    labelr_outer = r + 4,//+ (Math.max(w, h)/10), // radius for label anchor
    color = d3.scale.category20(),
    donut = d3.layout.pie(),
    arc_outer = d3.svg.arc().innerRadius(r * .95).outerRadius(r),
    arc_inner = d3.svg.arc().innerRadius(r * .6).outerRadius(r * .87);
 
var vis = d3.select(_which)
  .append("svg:svg")
  .data([data])
  .attr("width", w )
  .attr("height", h)
  .append("svg:g")
  .attr("transform", "translate(2,-20)")
  ;

var arcs = vis.selectAll("g.arc.inner")
    .data(donut.value(function(d) { 
        return _arc(d.val);
    }))
  .enter().append("svg:g")
    .attr("class", "arc inner")
    .attr("transform", "translate(" + (r + 50) + "," + (r + 50) + ")");

arcs.append("svg:path")
    .attr("class", function(d){ return d.data.type; })
    .attr("d", arc_inner);

arcs.append("svg:text")
    .attr("transform", function(d,i) {
        var c = arc_inner.centroid(d),
            _x = c[0],
            _y = c[1],
            _h = Math.sqrt(_x*_x + _y*_y);
            var L = 1;
            if(/FEMALE/.test(d.data.name)){
              L -= 0.2;
            }
        return "translate(" + (_x/_h * labelr_inner*L) +  ',' + (_y/_h * labelr_inner*L) +  ")";
    })
    .attr("dy", ".35em")
    .attr("class", function(d){ 
            return "text "+ d.data.type  +" inner";
    })
    .attr("text-anchor", function(d) {
        return "middle";
    })
    .text(function(d, i) { 
      return d.data.name;
    });
arcs.append("svg:text")
    .attr("transform", function(d,i) {
        var c = arc_inner.centroid(d),
            _x = c[0],
            _y = c[1],
            _h = Math.sqrt(_x*_x + _y*_y);
      var p =0;
      if(d.data.display_val > 50){
        p = 0
      }
        return "translate(" + (_x/_h * (labelr_outer+p)) +  ',' + (_y/_h * (labelr_outer+p)) +  ")";
    })
    .attr("dy", ".35em")
    .attr("class", function(d){
      var c = "text pe inner";
      if(d.data.display_val > 50){
        c += ' ob';
      }else{
        c += ' os';
      }
      return c;
    })
    .attr("text-anchor", function(d) {
        return "middle";
    })
    .text(function(d, i) {
      if(isZero) return '0%'; 
      return  d.data.display_val+"%";
    });
}