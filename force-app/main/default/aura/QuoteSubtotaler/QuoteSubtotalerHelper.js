({
    processMessage : function(component, helper, message) {
        var data = component.get("v.Data");
        var BundleMap = component.get("v.BundleMap");
        var ProdMap = {};
        var eventData = JSON.parse(message);
        if (eventData.Name == "Payment by Instalments Setup Fee") {
            data.Details.PayByInstalment = eventData.Num == 1;
            if (data.Details.PayByInstalment) {
                var Data = component.get("v.Data");
                Data.Details.WireFirstPayment = false;
                Data.Details.PaymentMethod = "Bank Transfer";
                component.set("v.Data", Data);
            }
        }
        var total = 0;
        var otime = 0; 
        var recur = 0;
        var txamt = 0;
        var exists = false;
        for (var i=data.Items.length-1;i>=0;i--) {
            ProdMap[data.Items[i].Id] = data.Items[i].Num;
            if (data.Items[i].CustomDiscount != null) {
                data.Items[i].unitprice = data.Items[i].CustomDiscount;
                data.Items[i].totalprice = data.Items[i].unitprice;
            }
            if (data.Items[i].Id == eventData.Id) {
                exists = true;
                data.Items[i].Num = eventData.Num;
                data.Items[i].totalprice = data.Items[i].unitprice * data.Items[i].Num;
                if (eventData.Num == null) {
                    data.Items.splice(i,1);
                } else {
                    if (data.Items[i].totalprice != null) {
                        total += data.Items[i].totalprice;
                    	if (eventData.Taxable__c) txamt += data.Items[i].totalprice * 0.19;
                    }
                    if (data.Items[i].isBundle) {
                        otime += BundleMap[data.Items[i].Id].onetime;
                        recur += BundleMap[data.Items[i].Id].recurring;
                    } else {
                        if (data.Items[i].Type__c == 'OneTime' || (data.Items[i].Model__c == 'DiscountFixedAmount' && data.Items[i].TriggerEvent__c == 'ContractEffective')) {
                            otime += data.Items[i].totalprice;
                        } else if (data.Items[i].Type__c != null) {
                            recur += data.Items[i].totalprice;
                        }
                    }
                }
            } else {
                if (data.Items[i].totalprice != null) {
                    total += data.Items[i].totalprice;
                	if (eventData.Taxable__c) txamt += data.Items[i].totalprice * 0.19;
                }
                if (data.Items[i].isBundle && data.Items[i].Num != null) {
                    otime += BundleMap[data.Items[i].Id].onetime;
                    recur += BundleMap[data.Items[i].Id].recurring;
                } else {
                    if (data.Items[i].Type__c == 'OneTime' || (data.Items[i].Model__c == 'DiscountFixedAmount' && data.Items[i].TriggerEvent__c == 'ContractEffective')) {
                        otime += data.Items[i].totalprice;
                    } else if (data.Items[i].Type__c != null) {
                        recur += data.Items[i].totalprice;
                    }
                }
            }
        }
        ProdMap[eventData.Id] = eventData.Num;
        if (!exists) {
            var newItem = eventData;
            var newItemArray = [];
            var Bundle = component.get("v.BundleMap")[newItem.Id];
            if (Bundle != null) {
                newItem["isBundle"] = true;
                newItem["isBundleItem"] = false;
                newItem["Id"] = Bundle.Id;
                newItem["unitprice"] = Bundle.bundleprice;
                
                var records = Bundle.Product_Bundle_Assignments__r.records;
                for (var b=0;b<records.length;b++) {
                    var niaObject = {};
                    niaObject["Name"] = "----" + records[b].Product__r.Name;
                    niaObject["ZuoraId"] = records[b].Product__r.ZuoraId__c;
                    newItemArray.push(niaObject);
                }
            } else {
                newItem["isBundle"] = false;
                newItem["isBundleItem"] = false;
                newItem["Id"] = newItem.Id;
                try {
                    newItem["pricebookentryid"] = component.get("v.PriceMap")[component.get("v.Currency")+":"+newItem.ZuoraId__c].PBE;
                    if (newItem["CustomDiscount"] == null) {
                        newItem["unitprice"] = component.get("v.PriceMap")[component.get("v.Currency")+":"+newItem.ZuoraId__c].Price;
                    } else {
                        newItem["unitprice"] = newItem["CustomDiscount"];
                    }
                    } catch(err) {}
            }
            if (newItem["unitprice"] != null) {
                newItem["totalprice"] = newItem["unitprice"] * eventData.Num;
                if (newItem.totalprice != null) {
                    total += newItem.totalprice;
                	if (eventData.Taxable__c || newItem.isBundle) txamt += newItem.totalprice * 0.19;
                }
                if (newItem.isBundle) {
                    otime += BundleMap[newItem.Id].onetime;
                    recur += BundleMap[newItem.Id].recurring;
                } else {
                    if (newItem.Type__c == 'OneTime' || (newItem.Model__c == 'DiscountFixedAmount' && newItem.TriggerEvent__c == 'ContractEffective')) {
                        otime += newItem.totalprice;
                    } else if (newItem.Type__c != null) {
                        recur += newItem.totalprice;
                    }
                }
            }
            data.Items.push(newItem);
            for (var z=0; z<newItemArray.length; z++) {
                var newExtra = {};
                newExtra["Name"] = newItemArray[z].Name;
                newExtra["Id"] = Bundle.Id;
                newExtra["unitprice"] = null;
                newExtra["totalprice"] = null;
                newExtra["Num"] = null;
                newExtra["isBundle"] = true;
                newExtra["isBundleItem"] = true;
                data.Items.push(newExtra);
            }
        }
        data["TaxAmount"] = txamt;
        var QuoteWarnings = component.get("v.QuoteWarnings");
        for (var key=0; key<QuoteWarnings.length; key++) {
            QuoteWarnings[key].Flag__c = true;
            for (var x=0; x<QuoteWarnings[key].QWCs__r.records.length && QuoteWarnings[key].Flag__c; x++) {
                var QWQty = ProdMap[QuoteWarnings[key].QWCs__r.records[x].Product__c];
                console.log()
                switch (QuoteWarnings[key].QWCs__r.records[x].Quantity__c) {
                    case "None":
                        QuoteWarnings[key].Flag__c = (QWQty == null || QWQty == 0);
                        break;
                    case "At least one":
                        QuoteWarnings[key].Flag__c = (QWQty > 0);
                        break;
                    case "Exactly one":
                        QuoteWarnings[key].Flag__c = (QWQty == 1);
                        break;
                    default:
                        QuoteWarnings[key].Flag__c = (QWQty > 1);
                }
            }
            if (QuoteWarnings[key].Flag__c) console.log("!!!!!yahtzee!!!!:"+JSON.stringify(QuoteWarnings[key]));
        }
        component.set("v.Data", data);
        component.set("v.QuoteWarnings", QuoteWarnings);
        component.set("v.DataStr", JSON.stringify(data));
        component.set("v.OneTime", otime);
        component.set("v.Recurring", recur);
        component.set("v.Subtotal", total);
        component.set("v.VAT", txamt);
        component.set("v.Total", total + txamt);
    },
    UpdateQuote : function(component) {
        var Curr = component.get("v.Currency");
        var QuoteId = component.get("v.QuoteId");
        var action = component.get("c.upsertQuote");
        var Data = component.get("v.Data");
        console.log(JSON.stringify(Data));
        if (Data.Details.PayByInstalment) Data.Details.WireFirstPayment = true;
        action.setParams({
            "JSONPayload": JSON.stringify(Data),
            "BundleMap": JSON.stringify(component.get("v.BundleMap")),
            "PriceMap": JSON.stringify(component.get("v.PriceMap")),
            "OpportunityName": null,
            "OpportunityId": null,
            "QuoteId": QuoteId,
            "curr": Curr
        });
        action.setCallback(this, function(response){
            console.log("==============");
            console.log(JSON.stringify(response));
            var state = response.getState();
            if (state === "SUCCESS") {
                if (true) {
                    console.log(QuoteId);
                    var action2 = component.get("c.forecastInvoice");
                    action2.setParams({ "QuoteId" : QuoteId });
                    action2.setCallback(this, function(response2){
                        /*navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": QuoteId,
                            "isredirect": true
                        });
                        navEvt.fire();*/
                        var object = {    
                            "type": "standard__recordPage",
                            "attributes": {
                                "recordId": QuoteId,
                                "objectApiName": "Quote",
                                "actionName": "view"
                            }
                        };
                        console.log("bart");
                        component.find("navService").navigate(object);
                    });
                    $A.enqueueAction(action2);
                } else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({"recordId": response.getResponseValue()});
                    navEvt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    CreateQuote : function(component) {
        var Curr = component.get("v.Currency");
        var QuoteId = component.get("v.QuoteId");
        var action = component.get("c.upsertQuote");
        var RunPreview = true;//component.get("v.Quote").Account.ZuoraId__c == null;
        var Opportunity = component.get("v.Opportunity");
        var Data = component.get("v.Data");
        if (Data.Details.PayByInstalment) Data.Details.WireFirstPayment = true;
        action.setParams({
            "JSONPayload": JSON.stringify(Data),
            "BundleMap": JSON.stringify(component.get("v.BundleMap")),
            "PriceMap": JSON.stringify(component.get("v.PriceMap")),
            "OpportunityName": Opportunity.Name,
            "OpportunityId": Opportunity.Id,
            "QuoteId": null,
            "curr": Curr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if (RunPreview) {
                    var respObj = JSON.parse(response.getReturnValue());
                    var action2 = component.get("c.forecastInvoice");
                    action2.setParams({ "QuoteId" : respObj.QuoteId });
                    action2.setCallback(this, function(response2){
                        if (respObj.QuoteId != null) {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": respObj.QuoteId,
                                "isredirect": true
                            });
                            navEvt.fire();
                        } else {
                            alert(respObj.ErrorMsg);
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": Opportunity.Id,
                                "isredirect": true
                            });
                            navEvt.fire();
                        }
                    });
                    $A.enqueueAction(action2);
                } else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({"recordId": response.getReturnValue()});
                    navEvt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    DateChanger : function(component) {
        try {
            var Data = component.get("v.Data");
            var todaycomp = new Date();
            var today30comp = new Date();
            today30comp.setDate(today30comp.getDate() + 30);
            if (Data.Details.ContractEffectiveDate == "") Data.Details.ContractEffectiveDate = new Date();
            if (Data.Details.ServiceActivationDate == "") Data.Details.ServiceActivationDate = new Date();
            if (Data.Details.ExpirationDate == "") Data.Details.ExpirationDate = new Date(today30comp);
            Data.Details.ContractEffectiveDate = new Date(Data.Details.ContractEffectiveDate);
            Data.Details.ServiceActivationDate = new Date(Data.Details.ServiceActivationDate);
            Data.Details.ExpirationDate = new Date(Data.Details.ExpirationDate);
            console.log("xISACCTMGMT: " + component.get("v.isAcctMgmt"));
            if (Data.Details.ContractEffectiveDate < todaycomp && !component.get("v.isAcctMgmt")) Data.Details.ContractEffectiveDate = new Date();
            if (Data.Details.ExpirationDate < todaycomp) Data.Details.ExpirationDate = new Date();
            if (Data.Details.ExpirationDate > today30comp) Data.Details.ExpirationDate = new Date(today30comp);
            if (Data.Details.ContractEffectiveDate > Data.Details.ServiceActivationDate) Data.Details.ServiceActivationDate = new Date(Data.Details.ContractEffectiveDate);
            /////
            Data.Details.ContractEffectiveDate = new Date(Data.Details.ContractEffectiveDate).toISOString().split("T")[0];
            Data.Details.ServiceActivationDate = new Date(Data.Details.ServiceActivationDate).toISOString().split("T")[0];
            Data.Details.ExpirationDate = new Date(Data.Details.ExpirationDate).toISOString().split("T")[0];
            component.set("v.Data", Data);
        } catch(err) {}
    },
    QuoteSetter : function(component, helper) {
        try {
            var Data = component.get("v.Data");
            var Quote = component.get("v.Quote");
            if (Quote != null) {
                Data.Details.WireFirstPayment = Quote.WireFirstPayment__c;
                Data.Details.PayByInstalment = Quote.Pay_by_Instalment__c;
                Data.Details.PaymentMethod = Quote.PaymentMethod__c;
                Data.Details.ContractEffectiveDate = Quote.ContractEffectiveDate__c;
                Data.Details.ServiceActivationDate = Quote.POS_Start_Date__c;
                Data.Details.ExpirationDate = Quote.ExpirationDate;
                Data.Details.PayPalLink = Quote.PayPalLink__c;
            }
            component.set("v.Data", Data);
        } catch(err) {}
        helper.DateChanger(component);
    }
})