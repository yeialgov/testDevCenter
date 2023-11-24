({
    viewInvoice : function(component, event, helper) {
        var action = component.get("c.getInvoice");
        console.log(JSON.stringify(component.get("v.Invoice")));
        action.setParams({
            "Token": component.get("v.Token"),
            "InvoiceId": component.get("v.Invoice").Id
        });
        action.setCallback(this, function(response){
            try {
                console.log(action.getReturnValue());
                var Invoice = JSON.parse(action.getReturnValue()).xObject;
                var base64str = Invoice.Base64Pdf__c;
                
                // create a download anchor tag
                var downloadLink      = document.createElement('a');
                downloadLink.target   = '_blank';
                downloadLink.download = Invoice.Name + '.pdf';
                
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
                //window.open("data:application/pdf;base64," + component.get("v.Invoice").Base64Pdf__c, "_blank");
                //window.open("http://www.google.com", "_blank");
                /*var object = {
                    "type": "comm__namedPage",
                    "attributes": {
                        "pageName": "invoicepdf"
                    },    
                    "state": {
                        "token": component.get("v.Token"),
                        "data": component.get("v.Invoice").Base64Pdf__c  
                    }
                };
                component.find("navService2").navigate(object);*/
            } catch(err) {}
        });
        $A.enqueueAction(action);
    }
})