var datastore;
var selectedData = new Array();

function find_by_id( array, item_id )
{
	index = 0;
	isFound = false;
	while ( index < array.length )				
		if (item_id == array[index].get('id'))
		{
			isFound = true;
			break;
		}
		else
			index++;
	
	return isFound? index : -1;
}


Ext.onReady(function(){
	
Ext.QuickTips.init();             
	 	
	//var Checkbox = new Ext.grid.CheckboxSelectionModel();
	var Checkbox = new Ext.grid.CheckboxSelectionModel({			
	    listeners: { 
			'rowselect' :  function( sm, rowIndex, record) {
				//Ext.MessageBox.alert("Event rowselect Fired\n" + rowIndex + "\n" + record.get("id"));				
				if ( find_by_id(selectedData, record.get('id')) == -1 ) 				
					selectedData.push(record);
			},
			'rowdeselect' : function( sm, rowIndex, record) {
				//Ext.MessageBox.alert("Event rowdeselect Fired");
				index = find_by_id(selectedData, record.get('id'));
				if ( index > -1 ) 
					selectedData.splice(index,1);
			}
		}
	});
	
	 var SimpleDataStore = new Ext.data.Store({
      proxy: new Ext.data.HttpProxy({
                url: '/optimize/getrecordbypage', 
                method: 'POST'
            }),            
      reader: new Ext.data.JsonReader({
        root: 'results',
        totalProperty: 'total'
       
      },
	   [ 
        {name: 'id', type: 'int'},
        {name: 'name', type: 'string'},
        {name: 'address', type: 'string'},
        {name: 'email', type: 'string'}
        
      ]),
      sortInfo:{field: 'id', direction: "ASC"}
    });
    
  
  var SimpleColumnModel = new Ext.grid.ColumnModel(
    [
	Checkbox,
	{
        header: 'Id',
        readOnly: true,
        dataIndex: 'id',
        width: 40,
        hidden: false
		
      },{
        header: 'Name',
        dataIndex: 'name',
        width: 130
        
      },{
        header: 'Address',
        dataIndex: 'address',
        width: 200
        
      },{
		header: 'Email',
        dataIndex: 'email',
		vtype:'email',
        width: 180
		}]
    );
    SimpleColumnModel.defaultSortable= true;
	

	//additional tutorial today... create form edit
	var formEdit = new Ext.form.FormPanel({
	    url:'simplegrid.php?act=edit',
		baseCls: 'x-plain',
        labelWidth: 90,
        defaultType: 'textfield',
		reader: new Ext.data.JsonReader ({
			root: 'results',
			totalProperty: 'total',
			id: 'id',
			fields: [
				'id','name','address','email'
			]
		}),
        items: [
			new Ext.form.Hidden ({
				name: 'id'					
			}),
			{
				fieldLabel: 'Name',
	            name: 'name',
	            anchor:'100%'
			},
			{
				fieldLabel: 'Address',
	            name: 'address',
				xtype:'textarea',
	            width:220
			},
			{
	            fieldLabel: 'Email',
	            name: 'email',
				vtype:'email',
	            width:220
	        }
		],
		
		buttons: [{
            text: 'SAVE',
			handler:function(){
				formEdit.getForm().submit({
					waitMsg:'Storing Data...',
					failure: function(form, action) {
						Ext.MessageBox.alert('Error Message', 'Data Failur.....');
						formEdit.getForm().reset();
					},
					success: function(form, action) {
						Ext.MessageBox.alert('Confirm', 'Success to storing data...');
						SimpleDataStore.load({params:{start:0,limit:3}});
						window.hide();
						formEdit.getForm().reset();
					}
				})
			}
        },{
            text: 'Cancel',
			handler: function(){
				window.hide();
			}
        }]
	});
	var window = new Ext.Window({
		title: 'Edit Input',
        width: 340,
        height:310,
        minWidth: 300,
        minHeight: 310,
///		layout: 'card',
        plain:true,
        bodyStyle:'padding:3px;',
        buttonAlign:'center',
		closeAction:'hide',
		modal: true,
		animCollapse:true,
		activeItem:0,
        items: [
			formEdit
		]
    });
	//function delete
	function del(btn){
		if(btn == 'yes'){
			var m = SimpleListingEditorGrid.getSelectionModel().getSelections();
			SimpleDataStore.load({params:{del:m[0].get("id"),start:0,limit:6}});
		}
	}

	var combo = new Ext.form.ComboBox({
	  name : 'perpage',
	  width: 40,
	  store: new Ext.data.ArrayStore({
		fields: ['id'],
		data  : [
		  ['3'],
		  ['5'],
		  ['6']
		]
	  }),
	  mode : 'local',
	  value: '3',

	  listWidth     : 40,
	  triggerAction : 'all',
	  displayField  : 'id',
	  valueField    : 'id',
	  editable      : false,
	  forceSelection: true
	});

	
	var bbar =  new Ext.PagingToolbar({
            pageSize: 3,
            store: SimpleDataStore,
            displayInfo: true,
            displayMsg: 'Displaying data {0} - {1} of {2}',
            emptyMsg: "No data to display",
			items : [
				'-',
				'Per Page: ',
				combo
			]
        });
		
	combo.on('select', function(combo, record) {
	  bbar.pageSize = parseInt(record.get('id'), 10);
	  //bbar.doLoad(bbar.cursor);
	  bbar.doRefresh();
	}, this);
		  
  var SimpleListingEditorGrid =  new Ext.grid.GridPanel({
      title: 'Simple Grid',
	  store: SimpleDataStore,
      cm: SimpleColumnModel,
	  sm: Checkbox,
	   //componen tbar 
	   tbar:[		
		 {
			//button edit
			text:'Edit',
			//iconCls:'edit-grid',//create icon
			handler: function()
			{
				 var m = SimpleListingEditorGrid.getSelectionModel().getSelections();//function select
				 if(m.length > 0)
				 {
					//get id
					formEdit.getForm().load({url:'simplegrid.php?act=get&id='+ m[0].get('id'), waitMsg:'Loading'});
					window.show();			 
				 }
				 else
				 {
					Ext.MessageBox.alert('Message', 'please... Choose one of file...!');
				 }
			}
		 
		 },
		 {
			//buttton delete
			text:'Delete',
			//iconCls:'delete',//create icon
			handler: function()
			{
				var m = SimpleListingEditorGrid.getSelectionModel().getSelections();
				if(m.length > 0){
					Ext.MessageBox.confirm('Message', 'are you sure to delete this file?' , del);
				}
				else{
					Ext.MessageBox.alert('Message', 'please... Choose one of file...!');
				}
			}
		},
		{
			//buttton test
			text:'Test',
			//iconCls:'delete',//create icon
			handler: function()
			{
				var str = "";
				for ( i = 0 ; i < selectedData.length ; i++ )
					str += selectedData[i].get('id') + ",";
				Ext.MessageBox.alert('Message', str);
			}
		}	 
		    
		 
	   ],
	   viewConfig: {
            forceFit:true
        },
	    
        frame:true,
	    collapsible: true,
        animCollapse: true,
        width:600,
	    height:250,
	  
	  bbar: bbar
	  
	   });
	 
	SimpleListingEditorGrid.render('kingsly');

	SimpleDataStore.addListener( 'load', function() {		

		 // SimpleListingEditorGrid.getSelectionModel().selectRecords((this.queryBy(function(record, id) {
			 // return record.get('id') > 10;
		 // })).getRange());

		SimpleListingEditorGrid.getSelectionModel().selectRecords((this.queryBy(function(record, id) {
			return find_by_id( selectedData, record.get('id') ) > -1;
		})).getRange());
		 
	 });
	 
	SimpleDataStore.load({params:{start:0,limit:3}});
	 
	// SimpleDataStore.addListener( 'beforeload', function() {		

		 // var m = SimpleListingEditorGrid.getSelectionModel().getSelections() ;
		 
		 // if (m.length > 0 \)
			// Ext.MessageBox.alert('Message', m[0].get('id'));	
		 
	 // });
	 
	// Checkbox.selectRows(new Array(1,2,3));
	 
    datastore = SimpleDataStore;
    
  });