({
    doInit : function(component, event, helper) {
		component.set("v.IsMobile", helper.detectMob());
        var action = component.get("c.getQuotes");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var Quotes = JSON.parse(action.getReturnValue()).Objects;
            component.set("v.token", Token);
            component.set("v.ShowSpinner", false);
            component.set("v.Quotes", Quotes);
        });
        $A.enqueueAction(action);
    },
    back : function(component, event, helper) {
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": "options"
            },    
            "state": {
                "token": component.get("v.token"),
                "beta": true
            }
        };
                
        component.find("navService").navigate(object);
	},
    IndexP8 : function(component, event, helper) {
        var Index = component.get("v.Index");
        Index += component.get("v.PageSize");
        component.set("v.Index", Index);
	},
    IndexM8 : function(component, event, helper) {
        var Index = component.get("v.Index");
        Index -= component.get("v.PageSize");
        component.set("v.Index", Index);
	}
})