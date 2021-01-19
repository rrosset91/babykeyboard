/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto pedido, contextualizado com a tipo de registro.
*/
public class CEC_PME_OrderTriggerHandler extends TriggerHandler {
    private final String RECORD_TYPE_PME = 'PME_Order';
    List<Order> triggerNewPME; 
    List<Order> triggerOldPME;
    Map<Id, Order> triggerOldMapPME;
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Construtor, pega os registros contextualizados
    */ 
    public CEC_PME_OrderTriggerHandler() {
        triggerNewPME = (List<Order>) getTriggerNewByRecordTypeDeveloperName(RECORD_TYPE_PME);
        triggerOldPME = (List<Order>) getTriggerOldByRecordTypeDeveloperName(RECORD_TYPE_PME);
        triggerOldMapPME = new Map<Id, Order>();
        triggerOldMapPME.putAll(triggerOldPME);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterInsert() {
        system.debug('afterInsert ');
        if(!triggerNewPME.isEmpty()) {
            system.debug('!triggerNewPME.isEmpty() ');
            new CEC_PME_SharerRecord().sharingRecordOrder(triggerNewPME);
            CEC_PME_OrderExpirationDate.getExpirationDate(triggerOldMapPME.keySet());
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void beforeUpdate() {
        
        if(!triggerNewPME.isEmpty()) {
            List<Order> listOnChangeStatus = getListOnChangeStatus();
            
            if(!listOnChangeStatus.isEmpty()) {
                CEC_PME_OrderExpirationDate.updExpirationDate(listOnChangeStatus);                 
            }
            
            onChangeStatusCPC();
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Quando status da cotação é alterado para “CNAE não encontrado” o status é alterado para “CNAE não encontrado”.
    */ 
    private void onChangeStatusCPC() {
        for(Order order : triggerNewPME) {
            Order orderOld = triggerOldMapPME.get(order.Id);
            
            Boolean isChangeStatusQuote = String.isNotBlank(order.Status) && !order.Status.equalsIgnoreCase(orderOld.Status);
            
            if(isChangeStatusQuote && 'CNAE não encontrado'.equalsIgnoreCase(order.Status)) {
                order.Status = 'Executando Input Manual';
                if(String.isBlank(order.ErroMsg__c)) {
                    order.ErroMsg__c = 'CNAE não encontrado';
                }
            }
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Lista os registros que tiveram o status atualizados
    */ 
    private List<Order> getListOnChangeStatus() {
        List<Order> listOnChangeStatus = new List<Order>();
        for(Order iOrder : triggerNewPME) {
            String oldStatus = triggerOldMapPME.get(iOrder.Id).Status;
            
            if (oldStatus != iOrder.Status) {
                listOnChangeStatus.add(iOrder);                   
            }
        }
        
        return listOnChangeStatus;
    }
}