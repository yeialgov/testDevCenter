({
    Select : function(component, event, helper) {
        
        var option = component.get("v.option");
        var token = component.get("v.token");
        console.log('token in option '+token);
        
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": option
            },    
            "state": {
                "token": token  
            }
        };
                
        component.find("navService").navigate(object);
        
    }
})