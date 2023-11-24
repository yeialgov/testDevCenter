public class queryToolController {
	
    public Boolean displayResults { get; set; }
    public String queryString { get; set; }
    public String jsonStr { get; set; }
    
    public queryToolController() {
        displayResults = false;
        queryString = '';
    }
    
    public void executeQuery() {
        jsonStr = JSON.serializePretty(database.query(queryString));
        displayResults = true;
    }
    
}