/* 	Autor: Rennê Silva - Sysmap
Criação: 21/08/2020
Descrição: Classe controller para o componente Aura CEC_360_LGPDConsentsHistory.
Nome do projeto/ID: LGPD - Direito do Titular / Consentimento
Alterado por: Guilherme Cuencas 02/09/2020 - 15:11pm
Time: SQUAD CEC
* ---------------------------------------------------------------
--- Controle de Versão
-------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: rename da classe de CEC_360_LGPDIntegrationObjects para SOLAR_LGPDIntegrationObjects
--- Date: 21/01/2021
--- Alterado por : Fabio Sato Suenaga
*/

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
        @AuraEnabled public String  subjectTypeStr;
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
    
    // DSAR Start 
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
    
    Public class PutManagement{
        @AuraEnabled public DataManagement  data;
    }
    
    Public class DataManagement{
        @AuraEnabled public String message;
    }
    Public class PutOrdersStage{
        @AuraEnabled public DataOrdersStage  data;
    }
    
    Public class DataOrdersStage{
        @AuraEnabled public string currentStage;
        @AuraEnabled public string requestQueueId;
        @AuraEnabled public integer statusCode;
        
    }
    // DSAR End

    // Consents Start
    public class GetConsents {
        @AuraEnabled public String preferenceCenterId;
        @AuraEnabled public String protocolNumber;
        @AuraEnabled public ConsentError error;
        @AuraEnabled public List<Purpose> purposes;
    }

    public class Purpose{
        @AuraEnabled public String  id;
        @AuraEnabled public String  status;
        @AuraEnabled public String consentCreationDate;
    //    @AuraEnabled public String consentCreationDateStr;
        @AuraEnabled public String notes;
        @AuraEnabled public List<Consent> agreements;
    }

    public class Consent {
        @AuraEnabled public String  id;
        @AuraEnabled public String  title;
        @AuraEnabled public String  name;
        @AuraEnabled public String  description;
        @AuraEnabled public Boolean checked;
        @AuraEnabled public List<Option> options;
    }

    public class Option {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean checked;
    }

    
    public class PutConsents {
        //@AuraEnabled public String transactionId;
        //@AuraEnabled public String consentCreationDate;
        //@AuraEnabled public String origin;
        @AuraEnabled public ConsentError error;
        //@AuraEnabled public List<Consent> agreements;  

        @AuraEnabled public String protocolNumber 		    {get; set;}
        @AuraEnabled public String channel                  {get; set;}
        @AuraEnabled public String collectionPointId 	    {get; set;}
        @AuraEnabled public List< Purposes > purposes = new List< CEC_360_LGPDIntegrationObjects.Purposes >();
    }

    public class Purposes{
        //@AuraEnabled public String defaultConsentStatus   {get; set;}
        //@AuraEnabled public String description			{get; set;}
        @AuraEnabled public String id					    {get; set;}
        //@AuraEnabled public String label				    {get; set;}
        //@AuraEnabled public String purposeType			{get; set;}
        //@AuraEnabled public String status				    {get; set;}
        
        @AuraEnabled public List< Agreements > agreements = new List< CEC_360_LGPDIntegrationObjects.Agreements >();   
    }

    public class Agreements{
        //@AuraEnabled public String description	        {get; set;}
        //@AuraEnabled public String displayAs	            {get; set;}
        @AuraEnabled public String id			            {get; set;}
        //@AuraEnabled public String name			        {get; set;}
        //@AuraEnabled public String selectionType          {get; set;}
        //@AuraEnabled public Boolean required	            {get; set;}
        
        @AuraEnabled public List< Options > options = new List< CEC_360_LGPDIntegrationObjects.Options >();
    }

    public class Options{
        @AuraEnabled public String id		                {get; set;}
        //@AuraEnabled public String label	                {get; set;}
        //@AuraEnabled public Boolean checked	            {get; set;}
    } 

    public class ConsentError{
        @AuraEnabled public String httpCode;
        @AuraEnabled public String errorCode;
        @AuraEnabled public String message;
        @AuraEnabled public String detailedMessage;
        //@AuraEnabled public Link link;
    }
     public class GetCodeResolution{
        @AuraEnabled public GetCodeResolutionData data;
        
    } 
      public class GetCodeResolutionData{
        @AuraEnabled public list <GetCodeResolutionList> occurrenceResolutionList;
        
    }
       public class GetCodeResolutionList{
       @AuraEnabled public integer resolutionTypeId;
       @AuraEnabled public string resolutionTypeDescription;
        
    } 
}