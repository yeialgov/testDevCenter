({
    doInit : function(component, event, helper) {
		var Product = component.get("v.Product");
        if (Product.Num != null && Product.Num != 0) component.set("v.bgStyle", "background-color: #02A3E0;");
    },
    handlePayByInstalment : function(component, event, helper) {
		var Product = component.get("v.Product");
        console.log(Product.Name);
        console.log(JSON.stringify(event.getParams()));
        if (Product.Name == 'Payment by Instalments Setup Fee') {
            if (event.getParams().Num == 1) helper.hlpNumUp(component, helper);
            if (event.getParams().Num == 0) helper.hlpNumDn(component, helper);
        }
    },
    numUp : function(component, event, helper) {
        helper.hlpNumUp(component, helper);
	},
    numDn : function(component, event, helper) {
        helper.hlpNumDn(component, helper);
    }
})