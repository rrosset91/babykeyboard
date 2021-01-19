/*
* Autor: Diego Lima - Deloitte
* Data: 14/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para integração de upsert
* do objeto Transferencia__c]
* 
*/

@RestResource(urlMapping='/CEC_CTI_SyncObjects/upsertTransfer')
global class CEC_CTI_SyncTransfer  {

    @HttpPost
    global static List<CEC_CTI_SyncObjectsWrapper> upsertTransfer() {
        try{
            CEC_CTI_SyncTransferBO syncTransfer = new CEC_CTI_SyncTransferBO();
            return CEC_CTI_SyncObjectsReturns.getReturnTry(syncTransfer.proccessRequest());
        } catch (Exception e){    
            Return CEC_CTI_SyncObjectsReturns.getReturnException(e);          
        }               
    }
}