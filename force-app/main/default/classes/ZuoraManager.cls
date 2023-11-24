/**
 * @author keylight
 * @humansacrifice bcollins
 */
public class ZuoraManager {
    private class JsonFileResponse {
        String file;
        Boolean success;
    }

    private static HttpRequest getZuoraHttpRequest(String method, String route) {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('callout:Zuora/' + route);
        req.setHeader('apiaccesskeyid', '{!$Credential.Username}');
        req.setHeader('apisecretaccesskey', '{!$Credential.Password}');
        req.setHeader('content-type', 'application/json');
        req.setHeader('zuora-version', '196.0');
        return req;
    }

    public static String callZuoraAPI(String route, String method, String bodyJson) {
        Boolean success;
        HttpRequest req = getZuoraHttpRequest(method, route);
        if (bodyJson != null) req.setBody(bodyJson);
        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(resBody);        
            success = (Boolean) resMap.get('Success');
            if (success == null) {
                // if success is upper case or not depends on ZUORA REST resource ... WTF
                success = (Boolean) resMap.get('success');
            }
            if (success == null) {
                success = (resMap.get('Body') != null);
            }
            if (success != null && success) {
                return resBody;
            } else {
                System.debug(LoggingLevel.ERROR, resBody);
                return null;
            }

        } catch (System.CalloutException e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return null;
    }

    /*public static Blob getQuotePDF(String quoteId) {
        String serverUrl = SalesforceUrlManager.getSalesforceInstanceUrl() + '/services/Soap/u/10.0/' + UserInfo.getOrganizationId();
        zqu__Quote__c quote = [SELECT zqu__QuoteTemplate__r.zqu__Template_Id__c FROM zqu__Quote__c WHERE Id = :quoteId LIMIT 1];
        String templateId = quote.zqu__QuoteTemplate__r.zqu__Template_Id__c;
        String resJson = callZuoraAPI('quotes/document', 'POST', '{"locale":"de_DE_EURO","documentType":"PDF","quoteId":"' + quoteId + '", "serverUrl":"' + serverUrl + '","username":"' + UserInfo.getUserName() + '","templateId":"' + templateId + '","zquotesMajorVersion":"7","zquotesMinorVersion":"43"}');
        if (resJson == null) return null;

        JsonFileResponse response = (JsonFileResponse) JSON.deserialize(resJson, JsonFileResponse.class);
        System.debug(response);

        if (response == null || !response.success) return null;

        return getPDF(response.file.substring(response.file.lastIndexof('/')));
    }*/

    public static Blob getPDF(String fileRoute) {
        Blob data = callZuoraAPIWithBlobResponse('file' + fileRoute, 'GET', null);
        return data;
    }

    private static Blob callZuoraAPIWithBlobResponse(String route, String method, String bodyJson) {
        HttpRequest req = getZuoraHttpRequest(method, route);
        if (bodyJson != null) req.setBody(bodyJson);

        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug('STATUS:' + res.getStatus());
            System.debug('STATUS_CODE:' + res.getStatusCode());

            if (res.getStatusCode() != 200) return null;

            return res.getBodyAsBlob();
        } catch (System.CalloutException e) {
            System.debug(e.getMessage());
        }
        return null;
    }
}