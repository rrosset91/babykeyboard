/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Controlador do Aura Component Solar_Cross_CustomerActivity
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-14      Jean Sganzerla          class created 
**************************************************************************************************************/
public class Solar_Cross_CustomerActivityController {
    
    @AuraEnabled
    public static ActivityWrapper getActivity(String aRecordId){
        system.debug('aRecordId ' + aRecordId);
        Date lStartDate = system.today().addDays(-30);
        Date lEndDate = system.today();

        Solar_Cross_ProtocolHistoryController.ComponentDataWrapper lHistory = Solar_Cross_ProtocolHistoryController.getHistory(aRecordId, String.valueOf(lStartDate), String.valueOf(lEndDate));
        /*-------------------------------------------------- mock --------------------------------------------------*/
            // Solar_Cross_ProtocolHistoryController.ComponentDataWrapper lHistory = new  Solar_Cross_ProtocolHistoryController.ComponentDataWrapper();
            // for(Integer i = 0; i < 10; i ++){
            //     Solar_Cross_ProtocolHistoryController.DataFields lData = new Solar_Cross_ProtocolHistoryController.DataFields();                               
            //     lData.comparableStartDate = system.today().addDays(-20 - i);
            //     lHistory.dataFieldsLst.add(lData);
            // }
            // lHistory.StatusCode = 200;
        /*------------------------------------------------ fim mock ------------------------------------------------*/
        ActivityWrapper lReturn = new ActivityWrapper();
        
        Date lActivityDate;
        String lBusinessUnit;
        if(aRecordId.startsWithIgnoreCase('500')){// Componente do caso
            Case lContextCase = [SELECT Id, Account.AccountActiveSince__c, ContractBillingAccount__r.BusinessUnit__c FROM Case WHERE Id =:aRecordId];
            lActivityDate = lContextCase.Account.AccountActiveSince__c;
            lBusinessUnit = lContextCase.ContractBillingAccount__r.BusinessUnit__c;
            system.debug('Method called by a Case Record');
        }
        else{// Componente da conta
            Account lContextAccount = [SELECT Id, AccountActiveSince__c, BusinessUnit__c FROM Account WHERE Id =:aRecordId];        
            lActivityDate = lContextAccount.AccountActiveSince__c;        
            lBusinessUnit = lContextAccount.BusinessUnit__c;        
            system.debug('Method called by an Account Record');
        }
        
        if(!lHistory.dataFieldsLst.isEmpty()){
            lReturn.LastContact = lHistory.dataFieldsLst[0].comparableStartDate;      
            lReturn.LastContactBetween = lHistory.dataFieldsLst[0].comparableStartDate != null ? lHistory.dataFieldsLst[0].comparableStartDate.daysBetween(system.today()) : null;
            lReturn.ContactFrequency =  lHistory.dataFieldsLst.size();
        }
        lReturn.ActivityDate = lActivityDate;
        lReturn.BusinessUnit = lBusinessUnit;
        lReturn.StatusCode = lHistory.StatusCode;
        
        //verifica se lReturn.ContactFrequency é null, o que significa que não há nenhum histórico na demanda e passa o valor zero nesse caso, para exibir a mensagem no componente
        lReturn.ContactFrequency = lReturn.ContactFrequency == null ? 0 : lReturn.ContactFrequency;

        return lReturn;
    }

    @AuraEnabled
    public static Boolean getContractType(String recordId){
        System.debug('Get Contract Type: '+recordId);
        Boolean bolReturn;
        Case objCase = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c FROM Case WHERE Id = :recordId LIMIT 1];
        List<String> lstMobileContracts = Label.Solar_Cross_MobileContract.split(';');
        List<String> residentialContracts = Label.Solar_Cross_ResidentialContract.split(';');

        if(lstMobileContracts.contains(objCase.ContractBillingAccount__r.BusinessUnit__c)){
            bolReturn = false;
        }else{
            bolReturn = true;
        }
        System.debug('Get Contract Type Return: '+bolReturn);
        return bolReturn;
    }

    @AuraEnabled
    public static Map<String,Object> getOutages(String recordId, String strStartDate, String strEndDate, Boolean isResidential){
        System.debug('isResidential: ' + isResidential);
        if(isResidential){
            return Solar_Cross_OutageResidential.getOutages(recordId,strStartDate, strEndDate);
        }else{
            System.debug('Entrou aqui');
            return Solar_Cross_OutageMovel.getOutagesMobile(recordId);
        }
    }

    public class ActivityWrapper{
        @AuraEnabled public Date ActivityDate;
        @AuraEnabled public Date LastContact;
        @AuraEnabled public Integer ContactFrequency;
        @AuraEnabled public Integer LastContactBetween;
        @AuraEnabled public Integer StatusCode;

        @AuraEnabled public String BusinessUnit;
    }
}