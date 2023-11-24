({
	clicked : function(component, event, helper) {
        console.log(component.get("v.Quote").Id);
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": "quote"
            },    
            "state": {
                "token": component.get("v.Token"),
                "quoteId": component.get("v.Quote").Id
            }
        };
                
        component.find("navService2").navigate(object);
	}
})