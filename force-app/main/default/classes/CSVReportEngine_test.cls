@isTest public class CSVReportEngine_test {

    static TestMethod void test() {
        CSVReport__c csvr = new CSVReport__c(name='test',object__c='Account',filter__c='CreatedDate=today',emailto__c='test@test.com');
        insert csvr;
        insert new CSVReportField__c(CSVReport__c=csvr.Id, name='Name', Header__c='Name', Aggregation__c='GROUP BY');
        insert new CSVReportField__c(CSVReport__c=csvr.Id, name='Closed_Contract_Date__c', Header__c='CCD', Aggregation__c='MAX', isdate__c =true);
        apexpages.currentpage().getparameters().put('id',csvr.Id);
        CSVReportEngine csvre = new CSVReportEngine();
		String filename = csvre.getFileName();        
        String columnheaders = csvre.getColumnHeaders();
        system.debug(json.serialize(csvre.getFields()));
        system.debug(json.serialize(csvre.getReportData()));
        system.debug(json.serialize(csvre.getNewLine()));
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new CSVReportScheduler());
        List<CSVReportEmailer.CSVRequest> csvrs = new List<CSVReportEmailer.CSVRequest>();
        CSVReportEmailer.CSVRequest csvrr = new CSVReportEmailer.CSVRequest();
        csvrr.UserId = userInfo.getUserId();
        csvrr.CSVReportIds = csvr.id;
        csvrs.add(csvrr);
        CSVReportEmailer.CSVInvocableEmail(csvrs);
    }
    
}