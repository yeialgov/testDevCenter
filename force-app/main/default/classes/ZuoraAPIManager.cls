public class ZuoraAPIManager {
    private class JsonFileResponse {
        String file;
        Boolean success;
    }

    private static HttpRequest getZuoraHttpRequest(String method, String route, String enviro) {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('callout:' + enviro + '/' + route);
        req.setTimeout(120000);
        req.setHeader('apiaccesskeyid', '{!$Credential.Username}');
        req.setHeader('apisecretaccesskey', '{!$Credential.Password}');
        req.setHeader('content-type', 'application/json');
        req.setHeader('zuora-version', '211.0');
        return req;
    }

    public static String callZuoraAPI(String route, String method, String bodyJson) {
        if ([Select IsSandbox from Organization limit 1].IsSandbox) {
            return callZuoraAPI(route, method, bodyJson, 'ZuoraSandbox');
        } else {
            return callZuoraAPI(route, method, bodyJson, 'Zuora');
        }
    }
    
    public static String callZuoraAPI(String route, String method, String bodyJson, String enviro) {
        Boolean success;
        system.debug(bodyJson);
        HttpRequest req = getZuoraHttpRequest(method, route, enviro);
        if (bodyJson != null) req.setBody(bodyJson);
        Http http = new Http();
        if (Test.isRunningTest()) {
            system.debug(route);
            system.debug(method);
            if (route == 'catalog/products?pageSize=40') return '{"products":[{"name":"test","id":"id1","productRatePlans":'
                + '[{"name":"test","id":"id2","productRatePlanCharges":[{"id":"id3","name":"test","pricing":[{"currency":"EUR","price":1}],'
                + '"taxable":false}]}]},{"name":"test","id":"i4","productRatePlans":[{"name":"test","id":"id5",'
                + '"productRatePlanCharges":[{"id":"id6","name":"test","pricing":[{"currency":"EUR","price":1}],"taxable":false}]}]}]}';
            if (route == 'action/subscribe') return '[{"Success":true,"AccountId":"AccountId","SubscriptionId":"SubscriptionId",'
                + '"InvoiceId":"InvoiceId"}]';
            if (route == 'action/query') return '{"done":false,"queryLocator":"test","records":[{"id":"test"}]}';
            if (route == 'subscriptions/SubscriptionId') {
                if (method == 'GET') return '{"id":"SubscriptionId","status":"Active","subscriptionId":"SubscriptionId",'
                    + '"subscriptionNumber":"test","success":true,"ratePlans":[{"id":"rpId","ratePlanCharges":[{"id":"rpcId",'
                    + '"productRatePlanChargeId":"id3","quantity":1,"price":1}]}]}';
                if (method == 'PUT') return '{"success":"success","subscriptionId":"SubscriptionId2"}';
            }
            if (route == 'subscriptions/SubscriptionId2') {
                if (method == 'GET') return '{"id":"SubscriptionId2","status":"Active","subscriptionId":"SubscriptionId2",'
                    + '"subscriptionNumber":"test","success":true,"ratePlans":[{"id":"rpId2","ratePlanCharges":[{"id":"rpcId2",'
                    + '"productRatePlanChargeId":"id3","quantity":2,"price":1}]}]}';
            }
            if (route == 'action/queryMore') {
                return '{"done":true}';
            }
            if (route == 'action/amend') {
                return '{"results":[{"SubscriptionId":"test","success":true}]}';
            }
            if (route == 'subscriptions') {
                return '{"subscriptionId":"test","success":true}';
            }
            if (route == 'object/account' || route == 'object/invoice/test') {
                return '{"Id":"test"}';
            }
            if (route == 'subscriptions/accounts/test') {
                return '{"Subscriptions":[{"id":"test2","accountId":"test","invoiceSeparately":false,"invoiceOwnerAccountId":"test","ratePlans":[{"id":"test","ratePlanCharges":[{"id":"test","quantity":1,"productRatePlanChargeId":"id3"}]}]}]}';
            }
            if (route == 'subscriptions/test?charge-detail=all-segments') {
                return '{"id":"test","accountId":"test","invoiceSeparately":false,"invoiceOwnerAccountId":"test","ratePlans":[{"id":"test","ratePlanCharges":[{"id":"test","quantity":1,"productRatePlanChargeId":"id3"}]}]}';
            }
            if (route == 'action/generate') {
                return '[{"Id":"test","Success":true}]';
            }
            if (route == 'subscriptions/test/cancel') {
                return '{"subscriptionId":"test"}';
            }
            if (route == 'subscriptions/test') {
                return '{"success":true}';
            }
            if (route == 'action/update') {
                return '[]';
            }
            if (route == 'subscriptions/preview') {
                return '{"invoice":{"taxAmount":0,"amount":0}}';
            }
            return '{}';
        }
        try {
            HTTPResponse res = http.send(req);
            system.debug(res.getBody());
            return res.getBody();
        } catch (System.CalloutException e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return null;
    }
}