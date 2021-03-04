/**
 * @description       : 
 * @author            : Lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-29-2020   Lucas.soldi@ibm.com   Initial Version
**/
public class Solar_Cross_ContestationController {
    
    /**
    * @description 
    * @author Lucas Soldi | 10-29-2020 
    * @param recordId 
    * @return List<contestationWrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<contestationWrapper> getContestations(String recordId){
		String BillingRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        String rtItensContestados = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get('Itens_Contestados').getRecordTypeId();
        String rtFinanceiro = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        List<vlocity_cmt__PaymentAdjustment__c> lstContestations = new List<vlocity_cmt__PaymentAdjustment__c>();
        List<contestationWrapper> lstReturn = new List<ContestationWrapper>();
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        Map<String,List<Contestations>> mapCaseIdListContest = new Map<String,List<Contestations>>();
        if(recordId.startsWith('500')){
            Case objCase = [SELECT Id,AccountId, ContractBillingAccount__c FROM Case WHERE Id = :recordId LIMIT 1];
            groupedResults = [SELECT vlocity_cmt__DisputeId__c, SUM(ContestationAmount__c) FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__AccountId__c =: objCase.ContractBillingAccount__c AND RecordTypeId =: rtItensContestados AND vlocity_cmt__DisputeId__r.RecordTypeId= :rtFinanceiro  Group By vlocity_cmt__DisputeId__c];
            lstContestations = [SELECT Id, Name, vlocity_cmt__DisputeId__c, vlocity_cmt__DisputeId__r.LegacyProtocol__c,toLabel(vlocity_cmt__Status__c), vlocity_cmt__Amount__c, vlocity_cmt__Date__c, vlocity_cmt__Notes__c, vlocity_cmt__DisputeId__r.CreatedDate, toLabel(vlocity_cmt__DisputeId__r.Status), Reason__c, ContestationAmount__c, ContestedAmount__c FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__AccountId__c =: objCase.ContractBillingAccount__c AND RecordTypeId =: rtItensContestados AND vlocity_cmt__DisputeId__r.RecordTypeId =: rtFinanceiro Order By vlocity_cmt__DisputeId__r.CreatedDate DESC];
        }else{
            List<Account> lstBillingAccount = [SELECT Id FROM Account WHERE ParentId =: recordId AND RecordTypeId =: BillingRT];
            groupedResults = [SELECT vlocity_cmt__DisputeId__c, SUM(ContestationAmount__c) FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__AccountId__c IN :lstBillingAccount AND RecordTypeId =: rtItensContestados AND vlocity_cmt__DisputeId__r.RecordTypeId= :rtFinanceiro  Group By vlocity_cmt__DisputeId__c ];
            lstContestations = [SELECT Id, Name, vlocity_cmt__DisputeId__c, vlocity_cmt__DisputeId__r.LegacyProtocol__c,toLabel(vlocity_cmt__Status__c), vlocity_cmt__Amount__c, vlocity_cmt__Date__c, vlocity_cmt__Notes__c, vlocity_cmt__DisputeId__r.CreatedDate, toLabel(vlocity_cmt__DisputeId__r.Status), Reason__c, ContestationAmount__c,  ContestedAmount__c FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__AccountId__c IN :lstBillingAccount AND RecordTypeId =: rtItensContestados AND vlocity_cmt__DisputeId__r.RecordTypeId =: rtFinanceiro Order By vlocity_cmt__DisputeId__r.CreatedDate DESC];

        }
        Map<Object,Object> mapCaseIdSum = new Map<Object,Object>();
        for(AggregateResult groupRes : groupedResults){
            mapCaseIdSum.put(groupRes.get('vlocity_cmt__DisputeId__c'), groupRes.get('expr0'));
        }

        for(vlocity_cmt__PaymentAdjustment__c objVlocity : lstContestations){
            contestationWrapper objCont = new ContestationWrapper();
            Contestations objContestation = new Contestations();
            objCont.caseId = objVlocity.vlocity_cmt__DisputeId__c;
            objCont.protocolNumber = objVlocity.vlocity_cmt__DisputeId__r.LegacyProtocol__c;
            objCont.URL = URL.getSalesforceBaseUrl().toExternalForm() +'/'+objVlocity.vlocity_cmt__DisputeId__c;
            objCont.status = objVlocity.vlocity_cmt__DisputeId__r.Status;
            objCont.creationDate = objVlocity.vlocity_cmt__DisputeId__r.CreatedDate.date();
            objCont.creationTime = formatHour(objVlocity.vlocity_cmt__DisputeId__r.CreatedDate);
            objCont.value = (Decimal) mapCaseIdSum.get(objVlocity.vlocity_cmt__DisputeId__c);

            objContestation.reason = objVlocity.Reason__c;
            objContestation.contestentationAmount = objVlocity.ContestationAmount__c == null? 0 : objVlocity.ContestationAmount__c;
            objContestation.contestedAmount = objVlocity.ContestedAmount__c == null? 0 : objVlocity.ContestedAmount__c;
            objContestation.contestationStatus = objVlocity.vlocity_cmt__Status__c;
            objContestation.notes = objVlocity.vlocity_cmt__Notes__c;
            objContestation.contestationDate = objVlocity.vlocity_cmt__Date__c;
            objContestation.protocol = objVlocity.vlocity_cmt__DisputeId__r.LegacyProtocol__c;
            objContestation.contestentationId = 'Item de contestação: '+ objVlocity.Name;

            if(mapCaseIdListContest.get(objVlocity.vlocity_cmt__DisputeId__c) != null){
                mapCaseIdListContest.get(objVlocity.vlocity_cmt__DisputeId__c).add(objContestation);
            }else{
                System.debug('Entrou no else');
                mapCaseIdListContest.put(objVlocity.vlocity_cmt__DisputeId__c,new List<Contestations>{objContestation});
                lstReturn.add(objCont);
            }
        }


        for(contestationWrapper objReturn : lstReturn){
            objReturn.Contestations = mapCaseIdListContest.get(objReturn.caseId);
        }
        System.debug('lstReturn: ' + lstReturn);
        return lstReturn;
        
        
    }

    public static String formatHour(Datetime dateEntered){
        String strReturn;
        String hour = String.valueOf(dateEntered.hour()).length() == 1? '0'+String.valueOf(dateEntered.hour()):String.valueOf(dateEntered.hour());
        strReturn = hour + ':' + String.valueOf(dateEntered.minute());
        return strReturn;
    }

    public class ContestationWrapper{
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String protocolNumber;
        @AuraEnabled
        public String URL;
        @AuraEnabled
        public Date creationDate;
        @AuraEnabled
        public String creationTime;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Decimal value;
        @AuraEnabled
        public List<Contestations> contestations;
    }

    public class Contestations{
        @AuraEnabled
        public String contestentationId;
        @AuraEnabled
        public Decimal contestentationAmount;
        @AuraEnabled
        public Decimal contestedAmount;
        @AuraEnabled
        public String contestationStatus;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String protocol;
        @AuraEnabled
        public Date contestationDate;
    }
}