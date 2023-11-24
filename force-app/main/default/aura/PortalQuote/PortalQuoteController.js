({
    doInit : function(component, event, helper) {
        component.set("v.IsMobile", helper.detectMob());
        var action = component.get("c.getQuote");
        action.setParams({
            "Token": component.get("v.token"),
            "QuoteId": component.get("v.quoteId")
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var Quote = JSON.parse(action.getReturnValue()).QuoteData;
            for (var x=0; x<Quote.LineItems.length; x++) {
                console.log(x);
                if (Quote.LineItems[x].IsBundle) {
                    Quote.LineItems[x].Bundle = Quote.BundleMap[Quote.LineItems[x].AR.pbid];
                }
            }
            component.set("v.token", Token);
            component.set("v.ShowSpinner", false);
            component.set("v.Quote", Quote);
        });
        $A.enqueueAction(action);
    },
    back : function(component, event, helper) {
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": "quotes"
            },    
            "state": {
                "token": component.get("v.token"),
                "beta": true
            }
        };
        
        component.find("navService").navigate(object);
    }
})