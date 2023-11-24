({
	qtyEvent : function(prod) {
        var appEvent = $A.get("e.c:NewQuoteItem");
        appEvent.setParams({"message":JSON.stringify(prod)});
        appEvent.fire();
	},
    hlpNumUp : function(component, helper) {
		var Product = component.get("v.Product");
        var IsAmendment = component.get("v.IsAmendment");
        if (Product.Num == null) Product.Num = 0;
        if (Product.cDelta == null) Product.cDelta = 0;
        if (Product.ManualDiscount__c) {
            if (Product.Num != 1) {
                Product["Delta"] = Product.Num;
                if (Product.Model__c == "DiscountFixedAmount") {
                    var CustomDiscount = parseFloat(prompt("Enter discount amount."));
                    var MaxDisc = Product.Maximum_Discount__c;
                    if (MaxDisc == 319 && component.get("v.Currency") == "CHF") MaxDisc = 352;
                    if (MaxDisc != null && MaxDisc < CustomDiscount) {
                        CustomDiscount = MaxDisc;
                        alert("That is more than the maximum allowed discount. " + MaxDisc + " will be used.");
                    }
                    Product.CustomDiscount = Math.abs(CustomDiscount) * -1;
                    if (component.get("v.isAcctMgmt")) {
                        Product.DiscountPeriods = parseInt(prompt("Enter number of billing periods for discount."));
                    }
                } else {
                    Product.CustomDiscount = parseFloat(prompt("Enter charge amount."));
                }
                Product.Num = 1;
                Product.cDelta = Product.Num;
                Product.bDelta = 0;
                component.set("v.Product", Product);
                component.set("v.bgStyle", "background-color: #02A3E0;");
                helper.qtyEvent(Product);
            }
        } else if (Product.Model__c != "FlatFee" || Product.Num == 0) {
            Product.Num ++;
            Product.cDelta ++;
            Product.bDelta = Product.Num - Product.cDelta;
            component.set("v.Product", Product);
            Product["Delta"] = 1;
            if (IsAmendment) {
                if(Product.cDelta == 0) component.set("v.bgStyle", "background-color: #02A3E0;");
                if(Product.cDelta == 1) component.set("v.bgStyle", "background-color: #14ED0A;");
            } else {
                component.set("v.bgStyle", "background-color: #02A3E0;");
            }
            helper.qtyEvent(Product);
        }
    },
    hlpNumDn : function(component, helper) {
		var Product = component.get("v.Product");
        var IsAmendment = component.get("v.IsAmendment");
        if (Product.cDelta == null) Product.cDelta = 0;
        if (Product.Num != null && Product.Num != 0) {
            Product.Num --;
            Product.cDelta --;
            Product.bDelta = Product.Num - Product.cDelta;
            if (Product.Num == 0 && !IsAmendment) Product.Num = null;
            component.set("v.Product", Product);
            Product["Delta"] = -1;
            if (IsAmendment) {
                if(Product.cDelta == 0) component.set("v.bgStyle", "background-color: #02A3E0;");
                if(Product.cDelta == -1) component.set("v.bgStyle", "background-color: #F75F3E;");
            } else if(Product.Num == null) {
                component.set("v.bgStyle", ""); 
            }
            helper.qtyEvent(Product);
        }
    }
})