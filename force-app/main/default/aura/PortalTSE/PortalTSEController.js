({
    doInit : function(component, event, helper) {
        component.set("v.IsMobile", helper.detectMob());
        var action = component.get("c.getTSE");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var Data = JSON.parse(action.getReturnValue()).Objects;
            component.set("v.token", Token);
            component.set("v.ShowSpinner", false);
            component.set("v.Data", Data);
        });
        $A.enqueueAction(action);
    },
    accept : function(component, event, helper) {
        component.set("v.TermsAccepted", true);
    },
    download : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Data = component.get("v.Data");
        var Wrapper = {"Venue": Data[0], "Finanzamt": Data[1]};
        var action = component.get("c.createP148Letter");
        action.setParams({
            "Token": component.get("v.token"),
            "Payload": JSON.stringify(Wrapper),
            "Download": true
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var subAction = component.get("c.downloadP148Letter");
            subAction.setParams({
                "Token": Token,
                "LetterId": JSON.parse(action.getReturnValue()).StringValue
            });
            subAction.setCallback(this, function(response){
                try {
                    console.log(subAction.getReturnValue());
                    var base64str = JSON.parse(subAction.getReturnValue()).StringValue;
                    
                    // create a download anchor tag
                    var downloadLink      = document.createElement('a');
                    downloadLink.target   = '_blank';
                    downloadLink.download = 'Antrag§148.pdf';
                    
                    // decode base64 string, remove space for IE compatibility
                    var binary = atob(base64str.replace(/\s/g, ''));
                    var len = binary.length;
                    var buffer = new ArrayBuffer(len);
                    var view = new Uint8Array(buffer);
                    for (var i = 0; i < len; i++) {
                        view[i] = binary.charCodeAt(i);
                    }
                    
                    // convert downloaded data to a Blob
                    var blob = new Blob([view], { type: 'application/pdf' });
                    
                    // create an object URL from the Blob
                    var URL = window.URL;
                    var downloadUrl = URL.createObjectURL(blob);
                    
                    // set object URL as the anchor's href
                    downloadLink.href = downloadUrl;
                    
                    // append the anchor to document body
                    document.body.appendChild(downloadLink);
                    
                    // fire a click event on the anchor
                    downloadLink.click();
                    
                    // cleanup: remove element and revoke object URL
                    document.body.removeChild(downloadLink);
                    URL.revokeObjectURL(downloadUrl);
                    
                    //current plan is that there is no redirect
                    //component.set("v.DownloadPage", true);
                    
                    component.set("v.ShowSpinner", false); 
                } catch(err) { 
                    alert('Something went wrong'); 
                    component.set("v.ShowSpinner", false); 
                }
            });
            $A.enqueueAction(subAction);
        });
        $A.enqueueAction(action);
    },
    redirectFisc : function(component, event, helper) {
        window.location.href = 'https://my.orderbird.com/fiscalization/';
    },
    refreshFin : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Data = component.get("v.Data");
        var action = component.get("c.getFinanzamt");
        action.setParams({
            "Token": component.get("v.token"),
            "PostalCode": Data[0].Account__r.VenuePostalCode__c
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            Data[1] = JSON.parse(action.getReturnValue()).xObject;
            component.set("v.Data", Data);
	        component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    email : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Data = component.get("v.Data");
        var Wrapper = {"Venue": Data[0], "Finanzamt": Data[1]};
        console.log(JSON.stringify(Wrapper));
        var action = component.get("c.createP148Letter");
        action.setParams({
            "Token": component.get("v.token"),
            "Payload": JSON.stringify(Wrapper),
            "Download": false
        });
        action.setCallback(this, function(response){
            //console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var subAction = component.get("c.createP148Email");
            subAction.setParams({
                "Token": Token,
                "LetterId": JSON.parse(action.getReturnValue()).StringValue
            });
            subAction.setCallback(this, function(response){
                var EmailInfo = JSON.parse(subAction.getReturnValue());
                if (component.get("v.IsMobile")) {
	                EmailInfo.StringValue = EmailInfo.StringValue.replaceAll('+','%20');
                	window.location.href = "mailto:" + Data[1].Email__c + "?bcc=148%40orderbird.com&subject=Antrag%20nach%20%C2%A7%20148%20AO%20%E2%80%93%20Verl%C3%A4ngerung%20der%20Frist%20zur%20vollst%C3%A4ndigen%20Implementierung%20einer%20Cloud-TSE&body=" + EmailInfo.StringValue;
                } else {
                    window.open("mailto:" + Data[1].Email__c + "?bcc=148%40orderbird.com&subject=Antrag%20nach%20%C2%A7%20148%20AO%20%E2%80%93%20Verl%C3%A4ngerung%20der%20Frist%20zur%20vollst%C3%A4ndigen%20Implementierung%20einer%20Cloud-TSE&body=" + EmailInfo.StringValue, "_blank");
                }
                
                //current plan is that there is no redirect
                //component.set("v.DownloadPage", true);
                
                component.set("v.ShowSpinner", false); 
            });
            $A.enqueueAction(subAction);
        });
        $A.enqueueAction(action);
    },
    back : function(component, event, helper) {
        helper.goBack(component);
    }
})