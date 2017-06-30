Array.prototype.max = function () {
    return Math.max.apply(Math, this);
};

function update_recommand_height(){
var a=[];
$('.recommand_msg_box_container').each(function(){

    a.push($(this).height());

});
var max_height = a.max();

$('.recommand_msg_box_container').each(function(){

	$(this).height(max_height);

});

};