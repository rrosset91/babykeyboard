/* 	Autor: Danilo Fucuhara - Deloitte
Criação: 07/06/2019
Descrição: Classe controller para o componente CEC_360_IntegrationAggregators.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

public class CEC_360_AggregatorsController {
    @AuraEnabled
    public static CEC_RestObjects.SubscriberVasMain getAggregators(String recordId, String startDate, String endDate, String status) {
        CEC_RestObjects.SubscriberVasMain agg = new CEC_RestObjects.SubscriberVasMain();
        String msisdn = [SELECT MSISDN__c FROM Asset WHERE Id =: recordId].MSISDN__c;
        if(msisdn != null) {
            //agg = CEC_360_IntegrationAggregators.generateMock();
            agg = CEC_360_IntegrationAggregators.getAggregators(msisdn, startDate, endDate, status);
        }
        return agg;
    }
}