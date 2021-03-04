/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Controlador do Aura Component CEC_CallCenter_Alerts
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-04      Jean Sganzerla          class created 
* @version   2.0    2020-11-06      Jean Sganzerla          new logic to support general alerts 
* @version   2.1    2020-11-17      Jean Sganzerla          exclusion record type from Cust.Int.Topic. Using master rectype 
* @version   2.3    2020-12-03      Jean Sganzerla          considering GeneralAlertType__c to Alert Box Logic
**************************************************************************************************************/
public class CEC_CallCenter_Alerts_Controller {

    private static final Id SEGMENTED_ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Alerts').getRecordTypeId();
    private static final Id GENERAL_ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('GeneralAlerts').getRecordTypeId();
    private static final Id JUNCTION_RECTYPE = SObjectType.ParametersJunction__c.getRecordTypeInfosByDeveloperName().get('Parameters_Account').getRecordTypeId();    
    // private static final Id TOPIC_RECTYPE = SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('AlertsInteraction').getRecordTypeId();    
    
    // método que busca os 3 tipos de alertas e devolve-os para o componente, caso exista
    @AuraEnabled(cacheable=true)
    public static AlertsToReturnWrapper getAlerts(String aCaseId){
  
        Case lCase = [SELECT AccountId, ContractBillingAccount__c, ContractBillingAccount__r.BusinessUnit__c, ContractBillingAccount__r.Name, ContractBillingAccount__r.ShippingCity, ContractBillingAccount__r.ShippingState FROM Case WHERE Id = :aCaseId];
        String lCleannedCity = lCase.ContractBillingAccount__r.ShippingCity != null ? DataProcessing.removeDiacritics(lCase.ContractBillingAccount__r.ShippingCity) : '';
        system.debug('lCleannedCity ' + lCleannedCity);
        Set<Id> lParametersSet = new Set<Id>();
        
        for(ParametersJunction__c lJunction :[SELECT Account__c, Alert__c FROM ParametersJunction__c WHERE RecordTypeId = :JUNCTION_RECTYPE AND (Account__c = :lCase.AccountId OR Account__c = :lCase.ContractBillingAccount__c)]){
            lParametersSet.add(lJunction.Alert__c);
        }
        system.debug('lParametersSet' + lParametersSet);
        // if(lParametersSet.isEmpty()) return null;

        Set<String> lRelatedAssetsNameSet = new Set<String>();
        Set<String> lDDDSet;
        if(lCase.AccountId != null){
            if(lCase.ContractBillingAccount__r.BusinessUnit__c == 'Claro' || lCase.ContractBillingAccount__r.BusinessUnit__c == 'Claro - Pré' || lCase.ContractBillingAccount__r.BusinessUnit__c == 'Claro - Pós' || lCase.ContractBillingAccount__r.BusinessUnit__c == 'Claro - Pós' ){
                if(lDDDSet == null) lDDDSet = new Set<String>();
                for(Asset lAsset :[SELECT Id, RecordType.Name, MSISDN__c FROM Asset WHERE AccountId = :lCase.AccountId AND Status = 'Ativo']){
                    lRelatedAssetsNameSet.add(lAsset.RecordType.Name);
                    system.debug('Registro que usará o DDD ' + lAsset);
                    String lDDD = lAsset.MSISDN__c != null ? lAsset.MSISDN__c.left(2) : '';
                    lDDDSet.add(lDDD);
                }
            }
            else{


                for(Asset lAsset :[SELECT Id, RecordType.Name FROM Asset WHERE AccountId = :lCase.AccountId AND Status = 'Ativo' AND SpotType__c != 'INDIFERENTE']){


                    lRelatedAssetsNameSet.add(lAsset.RecordType.Name);
                }
            }
        }
        Set<Id> lGeneralAlertsConcludedSet = new Set<Id>();
        for(vlocity_cmt__CustomerInteractionTopic__c lTopic :[SELECT Alert__c FROM vlocity_cmt__CustomerInteractionTopic__c WHERE vlocity_cmt__AccountId__c = :lCase.AccountId]){
            lGeneralAlertsConcludedSet.add(lTopic.Alert__c);
        }

        Date lToday = system.today();
        String lQuery = 'SELECT Id, StartDate__c, EndDate__c, Reason__c, FeedbackToCustomer__c, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,CreatedBy.Name, LastModifiedBy.Name, Description__c, Resolution__c, GeneralAlertType__c, SolarCross_Categorization__c, ProductType__c';
        lQuery += ' FROM Parameters__c WHERE';
        lQuery += ' ((Id IN :lParametersSet AND RecordTypeId = :SEGMENTED_ALERTS_RECTYPE) '; /*Condições para os Alertas Segmentados*/
        lQuery += ' OR';
        lQuery += ' (RecordTypeId = :GENERAL_ALERTS_RECTYPE AND Id NOT IN :lGeneralAlertsConcludedSet AND (Business_Unit__c = ' + '\'' + lCase.ContractBillingAccount__r.BusinessUnit__c + '\'' + ' OR ProductType__c IN :lRelatedAssetsNameSet OR City__r.CityName__c = :lCleannedCity OR City__r.CityName__c = ' + '\'' + lCase.ContractBillingAccount__r.ShippingCity + '\'' + ' OR UF__c = ' + '\'' + lCase.ContractBillingAccount__r.ShippingState + '\''; /*Condições para os Alertas Gerais*/
        lQuery = lDDDSet != null ? lQuery + ' OR BAN__c = ' + '\'' +lCase.ContractBillingAccount__r.Name  + '\'' + ' OR DDD__c IN :lDDDSet' : lQuery; //condições apenas para MOVEL
        lQuery += ')))';
        lQuery += ' AND (StartDate__c <= :lToday AND EndDate__c >= :lToday) ORDER BY EndDate__c DESC'; /*Condições para TODOS OS ALERTAS*/
        
        system.debug('lQuery ' + lQuery);   
        List<Parameters__c> lAlertsLst = Database.query(lQuery);
        
        AlertsToReturnWrapper lAlertsToReturn = new AlertsToReturnWrapper();
        for(Parameters__c lParam :lAlertsLst){
            
            AlertsWrapper lAlert = new AlertsWrapper();
            lAlert.lId = lParam.Id;
            lAlert.lFeedbackToCustomer = lParam.FeedbackToCustomer__c;
            lAlert.lFeedbackToCustomerLimited = lAlert.lFeedbackToCustomer != null ? lAlert.lFeedbackToCustomer.stripHtmlTags().abbreviate(50) : null;
            lAlert.lReason = lParam.Reason__c;
            lAlert.lRecordTypeDeveloperName = lParam.RecordTypeId == SEGMENTED_ALERTS_RECTYPE ? 'Alerts' : 'GeneralAlerts';
            lAlert.lShow = false;



            lAlert.lCreatedById = '/' + lParam.CreatedById;
            lAlert.lModifiedById = '/' + lParam.LastModifiedById;
            lAlert.lCreatedByName = lParam.CreatedBy.Name;
            lAlert.lModifiedByName = lParam.LastModifiedBy.Name;
            lAlert.lCreatedDate = lParam.CreatedDate;
            lAlert.lModifiedDate = lParam.LastModifiedDate;

            lAlert.lDescription = lParam.Description__c;
            lAlert.lResolution = lParam.Resolution__c;
            lAlert.lGeneralAlertType = lParam.GeneralAlertType__c;    
            lAlert.lStartDate = lParam.StartDate__c;     
            lAlert.lEndDate = lParam.EndDate__c;
            lAlert.lCategorization = lParam.SolarCross_Categorization__c;
            lAlert.lProductType = lParam.ProductType__c;



            if(lParam.GeneralAlertType__c == 'Problemas de Rede'){
                lAlertsToReturn.signalAlerts.add(lAlert);            
            }
            else if(lParam.RecordTypeId == SEGMENTED_ALERTS_RECTYPE){
                lAlertsToReturn.segmentedAlerts.add(lAlert);
            }
            else{
                lAlertsToReturn.generalAlerts.add(lAlert);                            
            }
        }
        return lAlertsToReturn;
    }

    // método que conclui o alerta e cria o registro de CustomerInteractionTopic
    @AuraEnabled
    public static void concludeAlertApex( String aCaseId, String aAlertWrapper){
        AlertsWrapper lAlert = (AlertsWrapper) System.JSON.deserialize(aAlertWrapper, AlertsWrapper.class);
        system.debug('lAlert ' + lAlert);
        List<User> lCommunityFieldLst = [SELECT CommunityNickname FROM User WHERE Id = : UserInfo.getUserId()];
        List<Case> lCaseLst = [SELECT LegacyProtocol__c, AccountId, ContractBillingAccount__c FROM Case WHERE Id = :aCaseId];
        List<vlocity_cmt__CustomerInteraction__c> lInteractionLst = [SELECT Id FROM vlocity_cmt__CustomerInteraction__c WHERE ProtocolNumber__c = :lCaseLst[0].LegacyProtocol__c];


        
        if(lInteractionLst.isEmpty()) {
            throw new AuraHandledException('Não foi possível concluir o Alerta, pois não foi encontrado nenhum registro de Interação (CustomerInteraction__c) para esse Caso. Entre em contato com um admnistrador do sistema');
        }

        vlocity_cmt__CustomerInteractionTopic__c lTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        lTopic.vlocity_cmt__CaseId__c = aCaseId;
        lTopic.Solar_Cross_DoneByClaro__c = !lCommunityFieldLst.isEmpty() ? lCommunityFieldLst[0].CommunityNickname : null;
        lTopic.Alert__c = lAlert.lId;
        lTopic.vlocity_cmt__CustomerInteractionId__c = lInteractionLst[0].Id;
        lTopic.vlocity_cmt__AccountId__c = lCaseLst[0].AccountId;
        lTopic.Solar_Cross_Type__c = 'Alerta';
        // lTopic.RecordTypeId = TOPIC_RECTYPE;

        Savepoint lSp = Database.setSavepoint();
        if(lAlert.lRecordTypeDeveloperName == 'Alerts'){
            delete [SELECT Id FROM ParametersJunction__c WHERE (Account__c = :lCaseLst[0].ContractBillingAccount__c OR Account__c = :lCaseLst[0].AccountId) AND Alert__c = :lAlert.lId AND RecordTypeId = :JUNCTION_RECTYPE];
        }


        try{
            insert lTopic;
            system.debug('insert succefull ' + lTopic.Id);
        }
        catch(exception ex){
            system.debug('Erro ao inserir vlocity_cmt__CustomerInteractionTopic__c ' + ex);
            Database.rollback(lSp);
        }        
    }

    public class AlertsToReturnWrapper{
        @AuraEnabled public List<AlertsWrapper> segmentedAlerts;
        @AuraEnabled public List<AlertsWrapper> generalAlerts;
        @AuraEnabled public List<AlertsWrapper> signalAlerts;

        public AlertsToReturnWrapper(){
            segmentedAlerts = new List<AlertsWrapper>();
            generalAlerts = new List<AlertsWrapper>();
            signalAlerts = new List<AlertsWrapper>();
        }
    }  


    public class AlertsWrapper{
        @AuraEnabled public String lId;
        @AuraEnabled public String lReason;
        @AuraEnabled public String lFeedbackToCustomer;
        @AuraEnabled public String lFeedbackToCustomerLimited;
        @AuraEnabled public String lRecordTypeDeveloperName;
        @AuraEnabled public Boolean lShow;
        @AuraEnabled public String lCreatedByName;
        @AuraEnabled public String lModifiedByName;
        @AuraEnabled public String lCreatedById;
        @AuraEnabled public String lModifiedById;
        @AuraEnabled public DateTime lCreatedDate;
        @AuraEnabled public DateTime lModifiedDate;
        @AuraEnabled public String lDescription;
        @AuraEnabled public String lResolution;
        @AuraEnabled public String lGeneralAlertType;
        @AuraEnabled public Date lStartDate;
        @AuraEnabled public Date lEndDate;
        @AuraEnabled public String lCategorization;
        @AuraEnabled public String lProductType;
    }
}