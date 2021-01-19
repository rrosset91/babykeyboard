/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 24/07/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 10] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 24/07/2019  
* Autor: Squad Canais Criticos
* Alterações: Utilização de TriggerHandler atualização do campo unidade de  negocio e produto do case
* ---------------------------------------------------------------
*/
public class CEC_SubjectAdministrationHandler  {
	
    //## Atributes
    public 	Map<Id,SubjectAdministration__c> 	newRecordMap;
    public 	Map<Id,SubjectAdministration__c> 	oldRecordMap;
    public 	List<SubjectAdministration__c> 		newRecordList;
    public 	List<SubjectAdministration__c> 		oldRecordList;
    
    //## Constructor
    public CEC_SubjectAdministrationHandler()
    {
        this.newRecordMap 	= new Map<Id,SubjectAdministration__c>();
        this.oldRecordMap 	= new Map<Id,SubjectAdministration__c>();
        this.newRecordList 	= new List<SubjectAdministration__c>();
        this.oldRecordList 	= new List<SubjectAdministration__c>();
    }
    
    public void onBeforeInsert()
    {
        definirProdutoAoInserir();
    }
    
    public void onBeforeUpdate()
    {
        definirProdutoAoInserir();
    } 
    
    private void definirProdutoAoInserir()
    {
        for(SubjectAdministration__c a : newRecordList)
        {
            String produto = a.Classification__c;
            String unidadeDeNegocio = a.BusinessUnit__c;            
            a.Product__c = produto;
            a.BusinessUnitText__c = unidadeDeNegocio;
        }
    }
    
}