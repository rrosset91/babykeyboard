/*
* Autor: Diego Lima - Deloitte
* Data: 15/11/2019
* Descrição: [Nome do projeto/ID: CEC EXTENSÃO F1 US-36096] + [Classe utilizada para tratativa de erros
* do objeto Site]
* 
*/
public class CEC_CTI_SyncObjectsReturns {

    /*
    
    public static List<CEC_CTI_SyncObjectsWrapper> getReturnTry(Database.UpsertResult [] cr){
        
        List<CEC_CTI_SyncObjectsWrapper> lstResultUpsert = new List<CEC_CTI_SyncObjectsWrapper>();
            
        System.debug('CR Antes do FOR = ' + cr );
        for (Database.UpsertResult sr : cr) {
            
            CEC_CTI_SyncObjectsWrapper wrapperSyncObjects = new CEC_CTI_SyncObjectsWrapper();
            
            System.debug('CR Dentro do FOR = ' + sr.getId());
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                
                System.debug('CR Dentro do IF SUCCCESS = ' + sr.getId());
                
                wrapperSyncObjects.idObject = sr.getId();
                wrapperSyncObjects.successOperation = true;
                wrapperSyncObjects.errorOperation = null;
                wrapperSyncObjects.descriptionError = null;
                lstResultUpsert.add(wrapperSyncObjects);
                
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                System.debug('Lista resultado = ' + lstResultUpsert);
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    
                    wrapperSyncObjects.idObject = sr.getId();
                    wrapperSyncObjects.successOperation = false;
                    wrapperSyncObjects.errorOperation = err.getStatusCode().name();
                    
                    if(err.getStatusCode() == StatusCode.STRING_TOO_LONG){
                        wrapperSyncObjects.descriptionError = 'Valor do campo [' + err.fields + '] ultrapassou o seu limite de tamanho!';
                    } else if(err.getStatusCode() == StatusCode.REQUIRED_FIELD_MISSING){
                        
                        System.debug(' err.fields = ' +  String.valueOf(err.fields));
                        
                        if(String.valueOf(err.fields) == String.valueOf('(Site__c)')){
                            System.debug('entrou if site');
                            wrapperSyncObjects.descriptionError = 'Campo [(Site__c)] inválido ou nulo.';
                        } else {
                            wrapperSyncObjects.descriptionError = 'Campo [' + err.fields + '] é obrigatorio!';
                        }
                        
                    } else {
                        wrapperSyncObjects.descriptionError = err.getMessage();
                    }
                    
                    lstResultUpsert.add(wrapperSyncObjects);
                    
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                    
                }
            } 	    
        }
        return lstResultUpsert;
    }
    
    
	*/    
    
    public static List<CEC_CTI_SyncObjectsWrapper> getReturnTry(CEC_CTI_SyncObjectsReturnsWrapper data){
        Database.UpsertResult [] cr = data.upsertResults;
        
        List<CEC_CTI_SyncObjectsWrapper> lstResultUpsert = new List<CEC_CTI_SyncObjectsWrapper>();
        
        /*
        List<CEC_CTI_SyncObjectsWrapper> lstJsonUpsertResult = new List<CEC_CTI_SyncObjectsWrapper>();
        for(Integer index = 0, size = this.lstUpsertLevel.size(); index < size; index++) 
        {
            CEC_CTI_SyncObjectsWrapper resultRow = new CEC_CTI_SyncObjectsWrapper();
            if (!this.lstUpsertLevel[index].isSuccess()) {
                resultRow.descriptionError = this.lstUpsertLevel[index].getErrors().get(0).getMessage();
            }
            
            resultRow.idObject = this.lstUpsertLevel[index].getId();
            resultRow.externalId = mapAllIdExternoTransfer[index];
            resultRow.successOperation = this.lstUpsertLevel[index].isSuccess();
            
            lstJsonUpsertResult.add(resultRow);
        }
		*/
            
        System.debug('CR Antes do FOR = ' + cr );
        //for (Database.UpsertResult sr : cr) {
        for(Integer index = 0, size = cr.size(); index < size; index++) {

			Database.UpsertResult sr = cr[index];          
            CEC_CTI_SyncObjectsWrapper wrapperSyncObjects = new CEC_CTI_SyncObjectsWrapper();
            
            System.debug('CR Dentro do FOR = ' + sr.getId());
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                
                System.debug('CR Dentro do IF SUCCCESS = ' + sr.getId());
                
                wrapperSyncObjects.idObject = sr.getId();
                wrapperSyncObjects.successOperation = true;
                wrapperSyncObjects.errorOperation = null;
                wrapperSyncObjects.descriptionError = null;
                lstResultUpsert.add(wrapperSyncObjects);
                
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                System.debug('Lista resultado = ' + lstResultUpsert);
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    
                    wrapperSyncObjects.idObject = sr.getId();
                    wrapperSyncObjects.successOperation = false;
                    wrapperSyncObjects.errorOperation = err.getStatusCode().name();
                    
                    if(err.getStatusCode() == StatusCode.STRING_TOO_LONG){
                        wrapperSyncObjects.descriptionError = 'Valor do campo [' + err.fields + '] ultrapassou o seu limite de tamanho!';
                    } else if(err.getStatusCode() == StatusCode.REQUIRED_FIELD_MISSING){
                        
                        System.debug(' err.fields = ' +  String.valueOf(err.fields));
                        
                        if(String.valueOf(err.fields) == String.valueOf('(Site__c)')){
                            System.debug('entrou if site');
                            wrapperSyncObjects.descriptionError = 'Campo [(Site__c)] inválido ou nulo.';
                        } else {
                            wrapperSyncObjects.descriptionError = 'Campo [' + err.fields + '] é obrigatorio!';
                        }
                        
                    } else {
                        wrapperSyncObjects.descriptionError = err.getMessage();
                    }
                    
                    lstResultUpsert.add(wrapperSyncObjects);
                    
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                    
                }
            }
            wrapperSyncObjects.externalId = data.listIdExterno[index];
        }
        return lstResultUpsert;
    }
    
    
    
    
    /**/
    public static List<CEC_CTI_SyncObjectsWrapper> getReturnException(Exception e){
    	List<CEC_CTI_SyncObjectsWrapper> upsertReturnExcetpion = new List<CEC_CTI_SyncObjectsWrapper>();
        List<CEC_CTI_SyncObjectsWrapper> lstResult = new List<CEC_CTI_SyncObjectsWrapper>();    
        CEC_CTI_SyncObjectsWrapper excetpion = new CEC_CTI_SyncObjectsWrapper();
                
        excetpion.idObject = null;
        excetpion.successOperation = false;
        excetpion.errorOperation = e.getTypeName();
        excetpion.descriptionError = e.getMessage();
        
        lstResult.add(excetpion);
        
        return lstResult;
    }

	
    
    
}