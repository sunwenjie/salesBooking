function updateFields(cal) {
      var date = cal.selection.get();
      if (date) {
              date = Calendar.intToDate(date);
              $("#calendar-inputField").val( Calendar.printDate(date, "%Y-%m-%d")+" "+cal.getHours() +":"+cal.getMinutes());
      }

};
   var cal =  Calendar.setup({
	showTime: 24,
	onSelect     : updateFields,
        onTimeChange : updateFields,
	minuteStep : 1
    });
    cal.selection.set(parseInt(Date.today().toString('yyyyMMdd')));

$("#calendar-trigger").click( function(e){
	cal.popup(this,null);
});