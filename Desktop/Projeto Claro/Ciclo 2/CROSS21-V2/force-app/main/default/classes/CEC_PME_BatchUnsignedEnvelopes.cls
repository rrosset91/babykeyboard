/*
* Autor: Diogo Braga - Deloitte
* Data: 23/05/2019
* Batch para atualizar os pedidos enviados e não assinados
*  ---------------------------------------------------------------
*/
public class CEC_PME_BatchUnsignedEnvelopes implements Database.Batchable<SObject> {

    public CEC_PME_BatchUnsignedEnvelopes() {

    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {

        Datetime nowLessOneDay = System.now().addDays(-1);
        String selectStr = 		'SELECT Id, DocuSignReenviarAssinatura__c';
        selectStr = selectStr + ' FROM Order WHERE DocuSignStatusDatetime__c < :nowLessOneDay';
        selectStr = selectStr + ' AND Status = \'Aguardando Assinatura\'';
        selectStr = selectStr + ' AND DocuSignEnvelopeID__c != null';
        selectStr = selectStr + ' AND DocuSignReenviarAssinatura__c = false';
        return Database.getQueryLocator(selectStr);
    }

    public void execute(Database.BatchableContext batchableContext, List<Order> listOrders) {

        for(Order varOrder : listOrders) {
            varOrder.DocuSignReenviarAssinatura__c = true;
        }
        update listOrders;
    }
    
    public void finish(Database.BatchableContext batchableContext) {

    }
}