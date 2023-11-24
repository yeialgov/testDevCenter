/**
 * @author keylight
 */
@isTest
global class ZuoraFileCalloutMock implements HttpCalloutMock {
    private boolean shouldReturnError;

    global ZuoraFileCalloutMock() {
        this.shouldReturnError = false;
    }

    global ZuoraFileCalloutMock(boolean shouldReturnError) {
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
        System.debug(req.getEndpoint());
        if (req.getEndpoint() == 'callout:Zuora/quotes/document') {
            res.setBody('{"Success":true,"file":"https://test/3845hfsd7fsik4594a43"}');
        }
        if (req.getEndpoint() == 'callout:Zuora/file/3845hfsd7fsik4594a43') {
            res.setBodyAsBlob(Blob.valueOf('Test'));
        }
        res.setStatusCode(200);
        res.setStatus('success');
        return res;
    }
}