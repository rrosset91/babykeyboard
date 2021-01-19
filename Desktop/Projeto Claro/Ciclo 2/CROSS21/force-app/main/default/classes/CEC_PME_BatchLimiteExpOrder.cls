global class CEC_PME_BatchLimiteExpOrder implements Database.Batchable<sObject>{  
    //construtor
    global CEC_PME_BatchLimiteExpOrder(){}
    
    //preparar dados para o batch
    global Database.QueryLocator start(Database.BatchableContext bc){
        String recTypeOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('PME_Order').getRecordTypeId();
        Set<String> setStatus = CEC_PME_UtilsLimiteExpiracao.getLimiteStatus('Pedido');
        Date expDate = Date.today();      
        
        return Database.getQueryLocator([SELECT Status, CreatorProfile__c, Segmento_Comercial__c,
                                         OrderCreationDate__c
                                         FROM Order
                                         WHERE RecordTypeId =: recTypeOrder
                                         AND (vlocity_cmt__ExpirationDate__c <= :expDate)
                                         AND Status NOT IN: setStatus]);
    }
                                        
    //processamento do batch
    global void execute(Database.BatchableContext bc, List<Order> order) {
        
        //Status do pedido
        final String NEW_ORDER_STATUS = 'Pedido Expirado';
        
        //lista para atualização
        List<Order> lstOrders = new List<Order>();
        for(Order ord: order) {
            ord.Status = NEW_ORDER_STATUS;
            lstOrders.add(ord);
        }

        update lstOrders;   
    }
    
    //ação pós processamento
    global void finish(Database.BatchableContext bc){}
}