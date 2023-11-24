({
    create : function(component, helper) {
        var Quote = component.get("v.Quote");
        var InvoiceItems = [];
        var action;
        action = component.get("c.PreviewAmendment");
        action.setParams({"QuoteId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var res = "[" + action.getReturnValue().replace("}{","},{") + "]";
            var Subtotal = 0;
            var Tax = 0;
            var Total = 0;
            console.log(res);
            var Data = JSON.parse(res);
            for (var a=0; a<Data.length; a++) {
                for (var b=0; b<Data[a].results.length; b++) {
                    try {
                        for (var c=0; c<Data[a].results[b].InvoiceDatas.length; c++) {
                            for (var d=0; d<Data[a].results[b].InvoiceDatas[c].InvoiceItem.length; d++) {
                                var Item = Data[a].results[b].InvoiceDatas[c].InvoiceItem[d];
                                if (Item.ChargeAmount < 0) Item.Quantity *= -1;
                                Subtotal += Item.ChargeAmount;
                                Tax += Item.TaxAmount;
                                Total += Item.ChargeAmount;
                                Total += Item.TaxAmount;
                                InvoiceItems.push(Item);
                            }                    
                        }         
                    }catch(err){}
                }
            }
            component.set("v.InvoiceItems", InvoiceItems);
            component.set("v.Subtotal", Subtotal);
            component.set("v.Tax", Tax);
            component.set("v.Total", Total);
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    }
})