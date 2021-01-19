public with sharing class CEC_KB_NewsFooterController {
    
    @AuraEnabled(cacheable=true)
    public static List<ArticleWrapper> getRecentArticles(Integer artToShow) {
            List<ArticleWrapper> wrapperList = new List <ArticleWrapper>();
            List<Knowledge__kav> articles = articleQuery();
            Integer count = 0;
            for(Knowledge__kav art: articles){
                ArticleWrapper artW = new ArticleWrapper();
                artW.articleId = art.Id;
                artW.titulo = art.Title;
                artW.resumo = art.Summary;
                artW.categorias = art.Categories__c;
                artW.tema = art.Theme__c;
                artW.tipoDeApoio = art.Support_Type__c;
                artW.dataUltimaPubli = art.LastPublishedDate;
                wrapperList.add(artW);
                count++;
                if(count == artToShow){
                    break;
                }
            }
            return wrapperList;
        }

        public static List<Knowledge__kav> articleQuery(){
            String query = 'SELECT Id, Summary, Title, Categories__c, Theme__c, Support_Type__c, FORMAT (LastPublishedDate) ';
            query += 'FROM Knowledge__kav ';
            query += 'WHERE RecordType.Name = \'Notícias\' AND PublishStatus = \'Online\' ORDER BY LastPublishedDate DESC';
            return Database.query(query);
        }
        
        @AuraEnabled(cacheable=true)
    	public static String getListViewId(){
            return [SELECT Id FROM ListView WHERE DeveloperName = 'Noticias'].Id;
        }	
    
        /*public static List<Knowledge__kav> listViewQuery(){
            String query = 'SELECT Id FROM ListView WHERE DeveloperName = \'Noticias\' ';
            return Database.query(query);
        }*/

        public class ArticleWrapper{
            @AuraEnabled
            public String articleId {get;set;}
            @AuraEnabled
            public String titulo {get;set;}
            @AuraEnabled
            public String resumo {get;set;}
            @AuraEnabled
            public String categorias {get;set;}
            @AuraEnabled
            public String tema {get;set;}
            @AuraEnabled
            public String tipoDeApoio {get;set;}
            @AuraEnabled
            public Datetime dataUltimaPubli {get;set;}
        }
    }