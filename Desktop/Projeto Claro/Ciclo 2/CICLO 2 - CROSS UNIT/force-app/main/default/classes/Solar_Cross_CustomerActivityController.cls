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
        if(aRecordId.startsWithIgnoreCase('500')){// Componente do caso
            lActivityDate = [SELECT Id, Account.AccountActiveSince__c FROM Case WHERE Id =:aRecordId].Account.AccountActiveSince__c;
            system.debug('Method called by a Case Record');
        }
        else{// Componente da conta
            lActivityDate = [SELECT Id, AccountActiveSince__c FROM Account WHERE Id =:aRecordId].AccountActiveSince__c;        
            system.debug('Method called by an Account Record');
        }
        
        if(!lHistory.dataFieldsLst.isEmpty()){
            lReturn.LastContact = lHistory.dataFieldsLst[0].comparableStartDate;      
            lReturn.LastContactBetween = lHistory.dataFieldsLst[0].comparableStartDate != null ? lHistory.dataFieldsLst[0].comparableStartDate.daysBetween(system.today()) : null;
            lReturn.ContactFrequency =  lHistory.dataFieldsLst.size();
        }
        lReturn.ActivityDate = lActivityDate;
        lReturn.StatusCode = lHistory.StatusCode;
        
        //verifica se lReturn.ContactFrequency é null, o que significa que não há nenhum histórico na demanda e passa o valor zero nesse caso, para exibir a mensagem no componente
        lReturn.ContactFrequency = lReturn.ContactFrequency == null ? 0 : lReturn.ContactFrequency;

        return lReturn;
    }

    public class ActivityWrapper{
        @AuraEnabled public Date ActivityDate;
        @AuraEnabled public Date LastContact;
        @AuraEnabled public Integer ContactFrequency;
        @AuraEnabled public Integer LastContactBetween;
        @AuraEnabled public Integer StatusCode;
    }
}