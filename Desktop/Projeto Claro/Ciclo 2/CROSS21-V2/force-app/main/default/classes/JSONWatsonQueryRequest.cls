public class JSONWatsonQueryRequest {
	public String natural_language_query { get; set; } 
    public Integer count { get; set; } 
    
    public JSONWatsonQueryRequest(String query, Integer count){
        this.natural_language_query = query;
        this.count = count;
    }
}