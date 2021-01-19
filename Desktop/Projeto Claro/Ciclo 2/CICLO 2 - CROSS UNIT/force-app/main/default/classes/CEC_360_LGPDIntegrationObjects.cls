/* 	Autor: Rennê Silva - Sysmap
   	Criação: 21/08/2020
   	Descrição: Classe controller para o componente Aura CEC_360_LGPDConsentsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular / Consentimento
    Alterado por: Guilherme Cuencas 02/09/2020 - 15:11pm
	Time: SQUAD CEC */

    global class CEC_360_LGPDIntegrationObjects {
    
    public class getRightsHistory {
         @AuraEnabled public list <customerOrders> customerOrders;       
    }
   
    global class customerOrders{
        @AuraEnabled public String id;
        @AuraEnabled public String orderDate;
        @AuraEnabled public String orderDateOld;
        @AuraEnabled public String completionDate;
        @AuraEnabled public String completionDateOld;
        @AuraEnabled public string orderType;
        @AuraEnabled public String status;
        @AuraEnabled public String email;
        @AuraEnabled public String protocolnumber;
        @AuraEnabled public List<String>  subjectType;
        @AuraEnabled public boolean extractAvailable;
        
    }
    
    public class GetHistoricRightsDetails {
        @AuraEnabled public HistoricRightsDetails data;
    }
    
    global class historicRightsDetails{
        //detalhes
        @AuraEnabled public String requestDetails;
        //canal
        @AuraEnabled public String formField29;
    }
        public class getHistoryRightsExtract {
        @AuraEnabled public data data;
    }
    
    global class data{
        
        @AuraEnabled public  dataDiscoveryResultsV2Dtos dataDiscoveryResultsV2Dtos;
        
    } 

     global class dataDiscoveryResultsV2Dtos{
        @AuraEnabled  public list <content> content;
          
     }
        global class content{
        @AuraEnabled public String fieldName;
        @AuraEnabled public String value;
    } 
    
    
    public class GetConsentsHistory {
        @AuraEnabled public List<Purpose> data;       
    }
   
    global class Purpose{
        @AuraEnabled public String id;
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String notes;
        @AuraEnabled public String consentCreationDate;
        @AuraEnabled public string purposeType;
        @AuraEnabled public String status;
        @AuraEnabled public List<Agreement> agreements;
    }
    
    public class Agreement {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public List<Option> options;
    }
    
    public class Option {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        //@AuraEnabled public Boolean checked;
    }

    //<--DSAR Start -->
    public class GetDsarByStatus {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public List<DataGetDsarByStatus> customerOrders;
        @AuraEnabled public DsarError error;
    }
    
    public class PostDsar {
        @AuraEnabled public String apiVersion;
        @AuraEnabled public String transactionId;
        @AuraEnabled public DataPostDsar data;
        @AuraEnabled public DsarError error;
    }
    
    public class DataGetDsarByStatus {
        @AuraEnabled public String  id;
        @AuraEnabled public String  orderDate;
        @AuraEnabled public String  completionDate;
        @AuraEnabled public String  orderType;
        @AuraEnabled public String  status;
        @AuraEnabled public List<String>  subjectType;
    }
    
    public class DataPostDsar {
        @AuraEnabled public String  requestQueueRefId;
        @AuraEnabled public String  status;
        //@AuraEnabled public List<String> requestTypes;
        //@AuraEnabled public List<String> subjectTypes;
    }
    
    public class DsarError{
        @AuraEnabled public String httpCode;
        @AuraEnabled public String errorCode;
        @AuraEnabled public String message;
        @AuraEnabled public String detailedMessage;
    }
        
    //<--DSAR End -->
}