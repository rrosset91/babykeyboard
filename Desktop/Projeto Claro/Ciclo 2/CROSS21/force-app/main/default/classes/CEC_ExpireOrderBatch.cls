/*
* Autor: Henrique Almeida
* Data: 08-mar-2018
* Descrição: Batch responsavel por cancelar ordens recebendo como parâmetro a CS CEC_OrderExpiration__c
*/

global class CEC_ExpireOrderBatch implements Database.Batchable<sObject>,Database.stateFul
{
    CEC_OrderExpiration__c orderExpiration = CEC_OrderExpiration__c.getInstance('CalculoExpiração');
    Id recTypeComercial = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Comercial').getRecordTypeId();


    public Database.QueryLocator start(Database.BatchableContext jobId)
    {   
		Integer numberOfDays = Integer.valueOf(orderExpiration.Dia__c - orderExpiration.Dia__c * 2);
		Date todayDate = date.today();       
        
        system.debug('numberOfDays: '+numberOfDays);
        system.debug('CONTA: '+todayDate.addDays(numberOfDays));
        
        
        return Database.getQueryLocator([SELECT
                                         Id,
                                         Status
                                         FROM Order
                                         WHERE CreatedDate__c <= :todayDate.addDays(numberOfDays)
                                         AND (Status = 'Em Andamento' OR Status = 'Rascunho' OR Status = 'Draft')
                                         AND RecordTypeId = :recTypeComercial]);
    }
    
    public void execute(Database.BatchableContext jobId, List<Order> scope) 
    {
     	for(Order varOrder : scope)
        {
            varOrder.Status = orderExpiration.Status__c;
        }
        
        Database.update(scope);
    }
    
    public void finish(Database.BatchableContext jobId)
    {

    }
}