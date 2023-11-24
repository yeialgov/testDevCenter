({
    doInit : function(component, event, helper) {
        var Venue = component.get("v.Venue");
        var Icon = "";
        switch(Venue.Uncertainty__c){
            case 0:
                Icon = "action:check";
                break;
            case 9:
                Icon = "action:approval";
                break;
            default:
                Icon = "action:canvas";
        }
        component.set("v.UncertaintyIcon", Icon);
        switch(Venue.Channel__c){
            case "Food":
                Icon = "standard:store";
                break;
            case "Big Night Out":
                Icon = "custom:custom81";
                break;
            case "Cafe":
                Icon = "custom:custom65";
                break;
            case "Drinks":
                Icon = "custom:custom56";
                break;
            default:
                Icon = "standard:steps";
        }
        component.set("v.Icon", Icon);
        if (Venue.Days_Since_Last_Shift_Open__c == null) {
            component.set("v.ActiveClass", "activeGray");
        } else if (Venue.Days_Since_Last_Shift_Open__c < 8) {
            component.set("v.ActiveClass", "activeGreen");
        } else if(Venue.Days_Since_Last_Shift_Open__c < 366) {
            component.set("v.ActiveClass", "activeYellow");
        } else {
            component.set("v.ActiveClass", "activeRed");
		}
    },
    Hide : function(component, event, helper) {
        if (confirm("Are you sure you want to deactivate the live connection from MY orderbird?")) {
            var Venue = component.get("v.Venue");
            Venue.Hidden__c = true;
            component.find("recordLoader1").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "ERROR") {alert(saveResult.error[0].message);} else {component.set("v.Venue", Venue);}
            }));
        }    
    },
    Unhide : function(component, event, helper) {
        if (confirm("Are you sure you want to activate the live connection from MY orderbird?")) {
            var Venue = component.get("v.Venue");
            Venue.Hidden__c = false;
            component.find("recordLoader1").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "ERROR") {alert(saveResult.error[0].message);} else {component.set("v.Venue", Venue);}
            }));
        }    
    },
    resendBambora : function(component, event, helper) {
        var VenueId = component.get("v.VenueSFId");
        var action = component.get("c.replaceBamboraRegId");
        action.setParams({"VenueId": VenueId});
        action.setCallback(this, function(response){
            component.set("v.HideBamboraButton", true);
        });
        $A.enqueueAction(action);
    },
    deepLink : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 
            "https://tools.orderbird.com/admin/accounts/venue/" 
            + component.get("v.VenueId")
            + "/"
        });
        urlEvent.fire();
        /*if (component.get("v.Uncertain")) {
            if (confirm("Click OK to confirm this my.Orderbird venue matches this account. If it is a false match, please press Cancel and notify CDS.")) {
                var VenueSFId = component.get("v.VenueSFId");
                var action = component.get("c.confirmObVenue");
                action.setParams({"MyObVenueId": VenueSFId});
                action.setCallback(this, function(response){
                    $A.get('e.force:refreshView').fire();
                });
                $A.enqueueAction(action);
            }
        }*/
    }
})