public class JSONWatsonDocUpload {
    public class Request{
        public Credentials credentials {get;set;}
        public String html {get;set;}
        public Metadata metadata {get;set;} 
        public String document_id {get;set;}
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
    
    public class Credentials {
        public String apikey {get;set;}
        public String url {get;set;}
        public String environment_id {get;set;}
        public String collection_id {get;set;}
    }
    
    public class Response{
        public String message {get;set;}
        public String document_id {get;set;}
        public Integer status_code {get;set;}
    }
}