({
	reloadData : function(component, event, helper) {
        component.find('recordLoader').reloadRecord(true);
        for (var x=0; x<10; x++) {
            try{component.find("c" + x).AddrBldrReload();}catch(err){}
        }
	}
})