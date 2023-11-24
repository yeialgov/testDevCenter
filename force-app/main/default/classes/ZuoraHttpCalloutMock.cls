/**
 * @author keylight
 */
@isTest
global class ZuoraHttpCalloutMock implements HttpCalloutMock {
    private boolean shouldReturnError;

    global ZuoraHttpCalloutMock() {
        this.shouldReturnError = false;
    }

    global ZuoraHttpCalloutMock(boolean shouldReturnError) {
        this.shouldReturnError = shouldReturnError;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if (shouldReturnError) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Success": false,"processId": "3F7EA3FD706C7E7C","reasons":  [{"code": 53100020,"message": " {com.zuora.constraints.either_or_both}"},{"code": 53100320,"message": "\'termType\' value should be one of: TERMED, EVERGREEN"}]}');
            res.setStatusCode(200);
            res.setStatus('success');
            return res;
        }
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Success":true,"Id":"3845hfsd7fsik4594a43", "Body": "Test"}');
        res.setStatusCode(200);
        res.setStatus('success');
        return res;
    }
}