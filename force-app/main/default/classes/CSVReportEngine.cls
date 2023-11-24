public class CSVReportEngine {
    
    private Final CSVReport__c csvr = [
        SELECT Id, Name, FileName__c, Object__c, Filter__c, SOQL_Finish__c, (SELECT Id, Name, Aggregation__c, Header__c, IsDate__c, IsInteger__c FROM CSV_Report_Fields__r ORDER BY Order__c, CreatedDate) 
        FROM CSVReport__c WHERE Id=:apexpages.currentpage().getparameters().get('id') LIMIT 1
    ];
    
    public String getFileName() {
        return csvr.FileName__c;
    }
    
    public String getColumnHeaders() {
        String ColumnHeaders = '';
        Boolean FirstField = TRUE;
        for (CSVReportField__c csvrf : csvr.CSV_Report_Fields__r) {
            if (FirstField) {
                FirstField = FALSE;
            } else {
                ColumnHeaders += ',';
            }
            ColumnHeaders += csvrf.Header__c;
        }
        return ColumnHeaders;
    }
    
    public List<CSVReportField__c> getFields() {
        return csvr.CSV_Report_Fields__r;
    }
    
    public List<AggregateResult> getReportData() {

        String SelectStmt = '';
        String GroupStmt = '';
        Boolean FirstField = TRUE;
        Boolean FirstGroup = TRUE;
        String SOQLFinish = csvr.SOQL_Finish__c == null ? '' : ' ' + csvr.SOQL_Finish__c;
        for (CSVReportField__c csvrf : csvr.CSV_Report_Fields__r) {
            if (FirstField) {
                FirstField = FALSE;
            } else {
                SelectStmt += ', ';
            }
            if (csvrf.Aggregation__c != 'GROUP BY') {
                SelectStmt += csvrf.Aggregation__c + '(' + csvrf.Name + ') ' + csvrf.Id;
            } else {
                SelectStmt += csvrf.Name + ' ' + csvrf.Id;
                if (FirstGroup) {
                    FirstGroup = FALSE;
                } else {
                    GroupStmt += ', ';
                }
                GroupStmt += csvrf.Name;
            }
        }
        
        return Database.query('SELECT ' + SelectStmt + ' FROM ' + csvr.Object__c + ' WHERE ' + csvr.Filter__c + ' GROUP BY ' + GroupStmt + SOQLFinish);
    }
    
    public String getNewLine() {
        return '\n';
    }
}