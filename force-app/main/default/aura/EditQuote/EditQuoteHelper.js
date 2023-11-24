({
    runInit : function(component, helper) {
        var action0 = component.get("c.getAcctMgmtPerm");
        action0.setCallback(this, function(response0){
            var AcctMgmtPerm = response0.getReturnValue();
            component.set("v.isAcctMgmt", AcctMgmtPerm);
            console.log("ISACCTMGMT/EDITQUOTE:" + AcctMgmtPerm);
            var Quote = component.get("v.Quote");
            component.set("v.IsAmendment", Quote.Opportunity.Account.ZuoraId__c != null);
            /*$A.createComponent("c:QuoteSubtotaler", {
                "Currency": Quote.Opportunity.Account.CurrencyIsoCode,
                "Opportunity": Quote.Opportunity,
                "isAcctMgmt": AcctMgmtPerm,
                "QuoteId": component.get("v.QuoteId"),
                "IsAmendment": (Quote.Opportunity.Account.ZuoraId__c != null)
            }, function(newSubtotaler, status, errorMessage){
                var body = component.get("v.body");
                body.push(newSubtotaler);
                component.set("v.body", body);
            });*/
            var action = component.get("c.getCatalog");
            action.setParams({
                "Curr": Quote.Opportunity.Account.CurrencyIsoCode,
                "AccountZId": Quote.Opportunity.AccountId
            });
            console.log(JSON.stringify(action.getParams()));
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    var Catalog = JSON.parse(response.getReturnValue()).Catalog;
                    var SLIs = JSON.parse(response.getReturnValue()).SLIs;
                    for (var x=0; x<Catalog.length; x++) {
                        Catalog[x]["Num"] = 0;
                        if (Catalog[x].Products__r != null) {
                            for (var bb=0; bb<Catalog[x].Products__r.records.length; bb++) {
                                var P = Catalog[x].Products__r.records[bb];
                                var ProdLoc = [];
                                if (P.LocalizedAvailability__c != null) ProdLoc = P.LocalizedAvailability__c.replace(" ","").split(",");
                                Catalog[x].Products__r.records[bb].Display = (
                                    P.IsActive 
                                    && (
                                        P.VisibleToAll__c
                                        || (
                                            P.VisibleToAcctMgmt__c
                                            && AcctMgmtPerm
                                        )
                                    )
                                    && (
                                        ProdLoc.includes(Quote.Opportunity.Account.BillingCountryCode)
                                        || ProdLoc.length == 0
                                        || (
                                            P.VisibleToAcctMgmt__c && AcctMgmtPerm
                                        )
                                    )
                                    && (
                                        P.Lead_Source_Restriction__c == null
                                        || P.Lead_Source_Restriction__c == Quote.Opportunity.DiscountEligible__c
                                    )
                                );
                            }
                        }
                    }
                    var numMapper = {};
                    var action2 = component.get("c.getQuoteLineItems");
                    action2.setParams({"QuoteId": component.get("v.QuoteId")});
                    action2.setCallback(this, function(response2){
                        var set = [];
                        var QLIs = JSON.parse(response2.getReturnValue());
                        for (var y=0; y<QLIs.length; y++) {
                            var QLI = QLIs[y];
                            var prod;
                            var willSend = true;
                            if (QLI.ProductBundle__c != null) {
                                prod = {
                                    "Id": QLI.ProductBundle__c, 
                                    "Num": QLI.Quantity,
                                    "isBundle": true,
                                    "Name": QLI.ProductBundle__r.Name
                                };
                                if (set.indexOf(JSON.stringify(prod)) < 0) {
                                    set.push(JSON.stringify(prod));
                                } else {
                                    willSend = false;
                                }
                            } else {
                                var CustomDiscount = null;
                                if(QLI.Product2.ManualDiscount__c) CustomDiscount = QLI.UnitPrice;
                                prod = {
                                    "Id": QLI.Product2Id, 
                                    "Num": QLI.Quantity, 
                                    "Name": QLI.Product2.Name,
                                    "Taxable__c": QLI.Product2.Taxable__c,
                                    "isBundle": false,
                                    "unitprice": QLI.UnitPrice,
                                    "CustomDiscount": CustomDiscount,
                                    "pricebookentryid": QLI.PricebookEntryId,
                                    "ZuoraId__c": QLI.Product2.ZuoraId__c,
                                    "Type__c": QLI.Product2.Type__c,
                                    "Model__c": QLI.Product2.Model__c
                                };                        
                            }
                            if (willSend) {
                                var appEvent = $A.get("e.c:NewQuoteItem");
                                appEvent.setParams({"message":JSON.stringify(prod)});
                                appEvent.fire();
                                numMapper[prod.Id] = prod.Num;
                            }
                            for (var aa=0; aa<Catalog.length; aa++) {
                                if (Catalog[aa].Products__r != null) {
                                    for (var bb=0; bb<Catalog[aa].Products__r.records.length; bb++) {
                                        var numToAdd = numMapper[Catalog[aa].Products__r.records[bb].Id];
                                        if (numToAdd != null) {
                                            Catalog[aa].Products__r.records[bb].Num = numToAdd;
                                            Catalog[aa].Num += numToAdd;
                                        }
                                    }
                                }
                                if (Catalog[aa].Product_Bundles__r != null) {
                                    for (var bb=0; bb<Catalog[aa].Product_Bundles__r.records.length; bb++) {
                                        var numToAdd = numMapper[Catalog[aa].Product_Bundles__r.records[bb].Id];
                                        if (numToAdd != null) {
                                            Catalog[aa].Product_Bundles__r.records[bb].Num = numToAdd;
                                            Catalog[aa].Num += numToAdd;
                                        }
                                    }
                                }
                            }
                        }
                        component.set("v.Catalog", Catalog);
                        component.set("v.ShowSpinner",false);
                        component.set("v.SLIs", SLIs);
                        //component.set("v.isAcctMgmt", JSON.parse(response.getReturnValue()).AcctMgmtPerm);
                    });
                    $A.enqueueAction(action2);
                }
            });
            $A.enqueueAction(action);
        });
        $A.enqueueAction(action0);
    }
})