/*      
* Autor: Bruno Felix- IBM
* Data: 30/07/2020
* Descrição: SOLAR FASE 2 + SQUAD KB: Classe helper da trigger do objeto KNOWLEDGE.
*/
public without sharing class KB_KnowledgeTriggerHelper {
    
    //Método para atribuir as categorias no campo customizado categories__c
    public static void getArticleCategory(Map<Id, Knowledge__kav> triggerOldMapKB,  
                                          Map<Id, Knowledge__kav> triggerNewMapKB, 
                                          List<Knowledge__kav> articles){
        Map<String, String> mapCategories = new Map<String, String>();
        List<String> articleIds = new List<String>();
        for(Knowledge__kav article : triggerNewMapKB.values()){
            if((triggerOldMapKB.get(article.Id).PublishStatus == 'Draft' && 
                triggerNewMapKB.get(article.Id).PublishStatus == 'Online')||
                triggerOldMapKB.get(article.Id).PublishStatus == 'Draft' && 
                triggerNewMapKB.get(article.Id).PublishStatus == 'Draft'){
                   articleIds.add(article.Id);
               }
        }
        for(Knowledge__kav article : [SELECT Id, (SELECT toLabel(DataCategoryName) FROM DataCategorySelections) 
                                        FROM Knowledge__kav 
                                       WHERE Id IN: articleIds])
        {
            String categories = '';
            for(Knowledge__DataCategorySelection dcs: article.DataCategorySelections){
                categories += dcs.DataCategoryName + '; ';
            }
            mapCategories.put(article.Id, categories);
        }
        
        for(Knowledge__kav article : articles){
            String categories = mapCategories.get(article.Id);
            if(categories != null){
                categories = categories.removeEnd('; ');
                article.Categories__c = categories;
            }
        }
    }
}