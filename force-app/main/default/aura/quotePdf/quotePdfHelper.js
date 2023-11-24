({
    initialize : function(component, event, helper) {
        try {
            var w = component.find("div1").getElement().offsetWidth;
            var h = 1.3 * w;
            component.set("v.height", h + "px");
            var pageName = component.get("v.sObjectName").replace("__c","");
            $A.createComponent(
                "iframe",
                {
                    "src": "/apex/" + pageName + "?id=" + component.get("v.recordId"),
                    "width": "100%",
                    "height": h + "px"
                },
                function(iframe, status, errorMessage){
                    //var body = component.get("v.body");
                    //body.push(iframe);
                    component.set("v.body", iframe);
                }
            );
        } catch(err) {}
    }
})