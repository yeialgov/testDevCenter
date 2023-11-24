({
    doInit : function(component, event, helper) {
        var Data = {};
        var Array = [];
        var Curr = component.get("v.Currency");
        Data["Items"] = Array;
        Data["Details"] = {};
        Data.Details.WireFirstPayment = false;
        Data.Details.PayByInstalment = false;
        Data.Details.PayPalLink = false;
        Data.Details.InvoiceOwner = 0;
        Data.Details.PaymentMethod = "Bank Transfer";
        Data.Details.ContractEffectiveDate = new Date().toISOString().split("T")[0];
        Data.Details.ServiceActivationDate = new Date().toISOString().split("T")[0];
        var expiry = new Date();
        expiry.setDate(expiry.getDate() + 30);
        Data.Details.ExpirationDate = new Date(expiry).toISOString().split("T")[0];
        component.set("v.Data",Data);
        var action = component.get("c.getPrices");
        action.setParams({"Curr": Curr});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var PriceMap = {};
                var BundleMap = {};
                var ReturnData = JSON.parse(response.getReturnValue());
                var prices = ReturnData.Pricebook;
                var bundles = ReturnData.Bundles;
                var QuoteWarnings = ReturnData.QuoteWarnings;
                for (var x=0;x<prices.length;x++) {
                    PriceMap[prices[x].Key__c] = { "Price" : prices[x].UnitPrice, "PBE" : prices[x].Id };
                }
                for (var x=0;x<bundles.length;x++) {
                    var records = bundles[x].Product_Bundle_Assignments__r.records;
                    bundles[x].bundleprice = 0;
                    bundles[x].bundletax = 0;
                    bundles[x].recurring = 0;
                    bundles[x].onetime = 0;
                    for (var y=0;y<records.length;y++){
                        try {
                            var priceadd = PriceMap[Curr+":"+records[y].Product__r.ZuoraId__c].Price;
                            bundles[x].bundleprice += priceadd;
                            if (records[y].Product__r.Taxable__c) bundles[x].bundletax += priceadd * 0.19;
                            if (records[y].Product__r.Type__c == 'OneTime' || (records[y].Product__r.Model__c == 'DiscountFixedAmount' && records[y].Product__r.TriggerEvent__c == 'ContractEffective')) {
                                bundles[x].onetime += priceadd;
                            } else {
                                bundles[x].recurring += priceadd;
                            }
                        } catch(err) {}
                    }
                    BundleMap[bundles[x].Id] = bundles[x];
                }
                component.set("v.PriceMap", PriceMap);
                component.set("v.BundleMap", BundleMap);
                component.set("v.QuoteWarnings", QuoteWarnings);
                console.log("========////========");
                console.log(JSON.stringify(ReturnData));
                console.log("========////========");
            }
        });
        $A.enqueueAction(action);
    },
    SetQuote : function(component, event, helper) {
        helper.QuoteSetter(component, helper);
    },
    SetExpiry : function(component, event, helper) {
        try{
            var Quote = component.get("v.Quote");
            var Data = component.get("v.Data");
            Data.Details.ExpirationDate = Quote.ExpirationDate;
            component.set("v.Data", Data);
        }catch(err){}
    },
    handleApplicationEvent : function(component, event, helper) {
        helper.processMessage(component, helper, event.getParam("message"));
    },
    PayByInstalEvent : function(component, event) {
        var Num = 0;
        if (component.get("v.Data").Details.PayByInstalment) {
            Num = 1;
            var Data = component.get("v.Data");
            Data.Details.PaymentMethod = "Bank Transfer";
            component.set("v.Data", Data);
        }
        console.log('should fire pbi event');
		var appEvent = $A.get("e.c:PayByInstalment");
        appEvent.setParams({"Num":Num});
        appEvent.fire();
    },
    WireFirstPayment : function(component, event) {
        if (!component.get("v.Data").Details.WireFirstPayment) {
            var Data = component.get("v.Data");
            Data.Details.PayPalLink = false;
            component.set("v.Data", Data);
        }
    },
    PayByPayPal : function(component, event) {
        if (component.get("v.Data").Details.PayPalLink) {
            var Data = component.get("v.Data");
            Data.Details.WireFirstPayment = true;
            component.set("v.Data", Data);
        }
    },
    saveButton : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Data = component.get("v.Data");
        var IsAmendment = component.get("v.IsAmendment");
        var OverFour = component.get("v.Subtotal") >= 4000;
        var QWs = component.get("v.QuoteWarnings");
        var HasQWError = false;
        for (var x=0; x<QWs.length; x++) {
            if (QWs[x].Flag__c && QWs[x].IsError__c) HasQWError = true;
        }
        if (HasQWError || (!Data.Details.WireFirstPayment && !Data.Details.PayByInstalment && OverFour && !IsAmendment)) {
        	component.set("v.ShowSpinner", false);
            alert("You cannot save this Quote with error(s).");
        } else {
            var SaveType = event.getParams().saveAction;
            if (Data.Details.InvoiceOwner == 3) alert("Contact someone in CDS to assign Invoice Owner of \"Other.\"");
            if (SaveType == "Update") helper.UpdateQuote(component);
            if (SaveType == "Create") helper.CreateQuote(component);
        }
    },
    DateChange : function(component, event, helper) {
        helper.DateChanger(component);
    }
})