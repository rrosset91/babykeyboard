/*
* Autor: Diogo Braga - Deloitte
* Data: 18/10/19
* Descrição: CEC extesão + SQUAD PME: Classe controller back da solução de path customizado de pedido
*/
public class CEC_PME_OrderPathController {
    public class OrderPathControllerException extends Exception{}
    
    private final String STATUS_JORN_LEGADO = 'Status CPC'; // status onde acaba a jornada no Salesforce e começa a jornada no(s) legado(s)
    private static final String ORDER_PATH = 'CEC_PME_OrderPath';
    private Order varOrder;
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: Contrutor busca no banco e valida scopo de execução
	*/
    public CEC_PME_OrderPathController(String recordId) {
        if(String.isBlank(recordId)) {
            throw new OrderPathControllerException(Label.CEC_PME_OrderPathController_1);
        }
        
        List<Order> listOrders = [SELECT Id,
                                  Status,
                                  StatusQuote__c
                                  FROM Order
                                  WHERE Id = :recordId];
        
        if(listOrders.isEmpty()) {
            throw new OrderPathControllerException(Label.CEC_PME_OrderPathController_2);
        }
        
        varOrder = listOrders.get(0);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: método disponível para acesso no front, pega o path pelo id do registro
	*/
    @AuraEnabled
    public static String getPath(String recordId) {
        try {
            CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil(ORDER_PATH);
            CEC_PME_OrderPathController controller = new CEC_PME_OrderPathController(recordId);
            
            return JSON.serialize(pathUtil.getPathByMicroStatus(controller.getMicroStatus()));
        } catch(Exception e) {
            system.debug('Exception ' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getTypeName());
            return JSON.serialize(CEC_PME_PathUtil.builderErrorPath(e.getMessage()));
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: Implementação da regra de multiplas jornadas
	*/
    private String getMicroStatus() {
        if(STATUS_JORN_LEGADO.equals(varOrder.Status)) {
            return varOrder.StatusQuote__c;
        } else {
            return varOrder.Status;
        }
    }
    
}