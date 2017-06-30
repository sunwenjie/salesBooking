    function check_option(option_value){
		document.getElementById('period_txt').innerHTML= option_value;	
        if (option_value == "Custom") {
        }
		else if (option_value == "This month") {
			monthselect((new Date().getMonth()+1),new Date().getFullYear());
		}
		else if (option_value == "Last month") {	
			monthselect(new Date().getMonth(),new Date().getFullYear());
		}
        else if(option_value == "All_time"){
		}
		else if(option_value == "This week"){weekselect(0);}
		else if(option_value == "Last week"){weekselect(1);}
		else if(option_value == "Yesterday"){dateselect(1);}
		else if(option_value == "Last 7 days"){dateselect(7);}
		else if(option_value == "Last 14 days"){dateselect(14);}
		else if(option_value == "Last 30 days"){dateselect(30);}
		
			document.getElementById('date_select').style.display = "none";	
			document.getElementById('date_txt').style.display = "block";	
			document.getElementById('calendar_layer2').style.display = "none";	
					
    }


	
	function initial(){
		
		document.getElementById('period_txt').innerHTML = p_value;
		
		if (p_value == "specific"){
			document.getElementById('date_select').style.display = "none";	
			document.getElementById('date_txt').style.display = "none";	
			document.getElementById('calendar_layer2').style.display = "block";				
		}
	
		document.getElementById("datefrom_c").value = document.getElementById("datefrom").innerHTML;
		document.getElementById("dateto_c").value = document.getElementById("dateto").innerHTML;
		getContent(dateformat(document.getElementById('datefrom').innerHTML),dateformat(document.getElementById('dateto').innerHTML),document.getElementById('period_txt').innerHTML);	
	}
	
	
	function weekselect(week){
		
		var today = new Date();
		var date2 = new Date();	
		
		if(week==0){
			today.setDate((-today.getDay())+today.getDate());
			var datefrom_t = today.getFullYear() + "/" + (today.getMonth()+1) + "/" + today.getDate();		
			date2.setDate(-1+date2.getDate());	
			var dateto_t = date2.getFullYear() + "/" + (date2.getMonth()+1) + "/" + (date2.getDate());

		}else{
			today.setDate(((-today.getDay())+today.getDate())-1); 
			var dateto_t = today.getFullYear() + "/" + (today.getMonth()+1) + "/" + today.getDate();		
			date2.setDate(((-date2.getDay())+date2.getDate())-1-6);
			var datefrom_t = date2.getFullYear() + "/" + (date2.getMonth()+1) + "/" + (date2.getDate());		
		
		}		
			document.getElementById('datefrom').innerHTML = dateformat_s(datefrom_t);		
			document.getElementById('dateto').innerHTML= dateformat_s(dateto_t);		

			getContent(dateformat(datefrom_t),dateformat(dateto_t),document.getElementById('period_txt').innerHTML);			
	}
	
	function dateselect(day){
		
		var date = new Date();
		date.setDate(-day+date.getDate());
		var datefrom_t = date.getFullYear() + "/" + (date.getMonth()+1) + "/" + date.getDate();		
		
		var date2 = new Date();		
		date2.setDate(-1+date2.getDate());	
		var dateto_t = date2.getFullYear() + "/" + (date2.getMonth()+1) + "/" + date2.getDate();		
		document.getElementById('datefrom').innerHTML = dateformat_s(datefrom_t);		
		document.getElementById('dateto').innerHTML= dateformat_s(dateto_t);

		getContent(dateformat(datefrom_t),dateformat(dateto_t),document.getElementById('period_txt').innerHTML);
	}

	function monthselect(month,year){		
		var date = new Date();
		if(date.getDate() != 1){
			date.setDate(-1+date.getDate());
		}
		if(month == new Date().getMonth()){	
		
			document.getElementById("datefrom").innerHTML=dateformat_s(year + "/" + month + "/" + 1);
			document.getElementById("dateto").innerHTML=dateformat_s(year + "/" + month + "/" + daysInMonth(month, year));
		}else{
			
			document.getElementById("datefrom").innerHTML=dateformat_s(year + "/" + month + "/" + 1);
			document.getElementById("dateto").innerHTML=dateformat_s(year + "/" + month + "/" + date.getDate());		
		}
		getContent(dateformat(document.getElementById("datefrom").innerHTML),dateformat(document.getElementById("dateto").innerHTML),document.getElementById('period_txt').innerHTML);
	}
	
	function daysInMonth(month, year) {
		return new Date(year, month, 0).getDate();
	}

	function generate_data(){

		if(document.getElementById("dateto_c").value == "" && document.getElementById("datefrom_c").value != ""){
		   document.getElementById("dateto_c").value = document.getElementById("datefrom_c").value; 
		}else if(document.getElementById("datefrom_c").value == "" && document.getElementById("dateto_c").value != ""){
		   document.getElementById("datefrom_c").value = document.getElementById("dateto_c").value; 
		} 
		document.getElementById("datefrom").innerHTML = document.getElementById("datefrom_c").value;
		document.getElementById("dateto").innerHTML = document.getElementById("dateto_c").value;
		if(document.getElementById("datefrom_c").value != "" && document.getElementById("dateto_c").value != ""){
			getContent(dateformat(document.getElementById("datefrom").innerHTML),dateformat(document.getElementById("dateto").innerHTML),"specific");
		}
	
	}

	function generate_data2(){

    var s = $('input[name=in]').val();
    var e = $('input[name=out]').val();

    if(s != "" && e != "") {
			getContent(dateformat(s),dateformat(e),"specific");
		}
	
	}
		
	function dateformat(date){
	
		var date_array = date.split("-",3);
		if(date_array[1].length == 1 && date_array[1] < 10){
			date_array[1] = "0" + date_array[1];
		}	
		if(date_array[2].length == 1 && date_array[2] < 10){
			date_array[2] = "0" + date_array[2];
		}			
		return date_array[0] + date_array[1] + date_array[2];
	}

	function dateformat_s(date){
	
		var date_array = date.split("-",3);
		if(date_array[1].length == 1 && date_array[1] < 10){
			date_array[1] = "0" + date_array[1];
		}	
		if(date_array[2].length == 1 && date_array[2] < 10){
			date_array[2] = "0" + date_array[2];
		}			
		return date_array[0] + "-" + date_array[1] + "-" + date_array[2];
	}	
	
	function showPanel(p_value){
	
		if(p_value == "show_date" && document.getElementById('date_select').style.display == "none"){
			document.getElementById('date_select').style.display = "block";	
		}else if(p_value == "show_date" && document.getElementById('date_select').style.display == "block"){
			document.getElementById('date_select').style.display = "none";	
			
		}
		else if (p_value == "specific"){
			document.getElementById('date_select').style.display = "none";	
			document.getElementById('date_txt').style.display = "none";	
			document.getElementById('calendar_layer2').style.display = "block";				
		}
	
	
	}

	function date_min(){
	  var date = new Date();
	  
	  sDate2 = date.getFullYear() + "/" + (date.getMonth()+1) + "/" + (date.getDate());
	  
	  
	  if(document.getElementById('datefrom_c').value != "" && document.getElementById('dateto_c').value != ""){
		
		x = DateDiff(document.getElementById('datefrom_c').value,document.getElementById('dateto_c').value)
		if(x<0){
			var date_from_s = document.getElementById('datefrom_c').value;
			var date_to_s = document.getElementById('dateto_c').value;
			document.getElementById('datefrom_c').value = date_to_s;
			document.getElementById('dateto_c').value = date_from_s;
		}
	  }
	}
     
	  function DateDiff(sDate1, sDate2){ 
        var aDate, aDate2, oDate1, oDate2, iDays;
		
		aDate = sDate1.split("/");
		oDate1 = aDate[0] + "" + aDate[1] + "" + aDate[2];
		aDate2 = sDate2.split("/");
		oDate2 = aDate2[0] + "" + aDate2[1] + "" + aDate2[2];		
		if(oDate2 - oDate1 < 0 ){
			return -1;
		}else if(aDate2[0] - aDate[0] <0){
			return -1;
		}else{
			return 1;
		}
	} 

	function close_date_select(){
		document.getElementById('date_select').style.display = "none";
	}	

  function num_format(str, sep, p) {
    var num = parseFloat(str);
    num = num.toFixed(p);
	  num += '';
	  x = num.split('.');
	  x1 = x[0];
	  x2 = x.length > 1 ? (parseInt(x[1], 10) == 0 ? '':'.' + x[1]) : '';
	  var rgx = /(\d+)(\d{3})/;
	  while (rgx.test(x1)) {
	  	x1 = x1.replace(rgx, '$1' + sep + '$2');
	  }
	  return x1 + x2;
  }
