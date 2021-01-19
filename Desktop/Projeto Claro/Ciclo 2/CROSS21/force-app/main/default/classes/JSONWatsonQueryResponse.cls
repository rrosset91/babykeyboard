public class JSONWatsonQueryResponse{
    public long matchingResults { get; set; }
    public string sessionToken { get; set; }
    public List<Result> results { get; set; }
    public RetrievalDetails retrievalDetails { get; set; } 
    
    public class Result {
        public string id { get; set; }
        public ResultMetadata result_metadata { get; set; }
        public string text { get; set; }
        public EnrichedText enriched_text { get; set; }
        public ExtractedMetadata extracted_metadata { get; set; }
        public string title { get; set; }
        public string html { get; set; }
        public Metadata metadata { get; set; }
    }
    
    public class EnrichedText {
        public List<Keyword> keywords { get; set; }
        public List<Entity> entities { get; set; }
        public List<Concept> concepts { get; set; }
        public List<Category> categories { get; set; }
    }
    
    public class Category {
        public double score { get; set; }
        public String label { get; set; }
    }
    
    public class Concept {
        public String text { get; set; }
        public double relevance { get; set; }
        public String dbpediaResource { get; set; }
    }
    
    public class Entity {
        public long count { get; set; }
        public Category sentiment { get; set; }
        public string text { get; set; }
        public double relevance { get; set; }
        public string type { get; set; }
    }
    
    public class Keyword {
        public string text { get; set; }
        public double relevance { get; set; }
        public long count { get; set; }
    }
    
    public class ExtractedMetadata {
        public string sha1 { get; set; }
        public string filename { get; set; }
        public string fileType { get; set; }
        public string title { get; set; }
    }
    
    public class ResultMetadata {
        public double confidence { get; set; }
        public double score { get; set; }
    }
    
    public class RetrievalDetails {
        public string documentRetrievalStrategy { get; set; }
    }
    
    public class Metadata {
        public String tipo_artigo {get;set;}

        public String tipo_artigo_unico {get;set;}


        public String tipo_apoio {get;set;}


        public String titulo {get;set;}
        public String ultima_publicacao {get;set;}
        public String ultima_atualizacao {get;set;}
        public String numero_artigo {get;set;}
        public String url_artigo {get;set;}
        public String resumo {get;set;}
        public String termos_promovidos {get;set;}
        public String categoria_dados {get;set;}
        public String entenda {get;set;}
        public String como_funciona {get;set;}
        public String saiba_mais {get;set;}

        public String beneficios {get;set;}
        public String canais_sistemas {get;set;}
        public String valido_para {get;set;}
        public String valor {get;set;}

        public String ilha_celula {get;set;}
        public String idArtigoSf {get;set;}
    }
}