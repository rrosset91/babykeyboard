/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [28/05/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 6] +
*[Classe controller para a chamada via integração de objetos.]
*/

public class CEC_360_ProtocolsResidentialController {
    Static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    
    @AuraEnabled
    public static List<String> getContracts (string recordId){
        
        List<Account> lstAccount = [Select ID,
                                    ContractNumber__c from
                                    Account where 
                                    ParentId =: recordId
                                    And
                                    RecordTypeId =: recTypeBillingAccount
                                    And 
                                    CityCode__c != null];
        
        return formatAccount(lstAccount);
    }
    
    public static List<CEC_RestObjects.attendences> formatData(List<CEC_RestObjects.attendences> lst){
        
        List<Cec_RestObjects.attendences> lstAggrouped = new List<Cec_RestObjects.attendences> ();
        String numProtocol;
        
        for(integer i=0;i<lst.size();i++){
            if(lst[i].order == '1'){
                string dateOpening = lst[i].solicitationDateOpening;
                string dateClosing = lst[i].solicitationDateClosing;
                CEC_RestObjects.attendences atd = new CEC_RestObjects.attendences();
                atd.protocolNumber = lst[i].protocolNumber;
                atd.solicitationDateOpening = dateOpening.substring(8,10) + '/' + dateOpening.subString(5,7)+ '/'+
                    dateOpening.substring(0,4) +' as ' + dateOpening.substring(12,19);
                atd.solicitationDateClosing = dateClosing.substring(8,10) + '/' + dateClosing.subString(5,7)+ '/'+
                    dateClosing.substring(0,4) +' as ' + dateClosing.substring(12,19);
                atd.solicitationStatus = lst[i].solicitationStatus;
                atd.solicitationType = lst[i].solicitationType;
                lstAggrouped.add(atd);
            }    
        }
        
        return lstAggrouped;
    }
    
    
    public static List<String> formatAccount (List<Account> acc){
        List<String> accTList = new List<String> ();
        
        for(integer i = 0; i < acc.size();i++){
            String contract = acc[i].ContractNumber__c;
            accTList.add(contract);
        }
        return accTList;
    }
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocols(string contractFormatted, 
                                                                 String startDate, String endDate)
    {
        List<CEC_RestObjects.attendences> lstAttendences = new List<Cec_RestObjects.attendences> ();
        String contractNumber = contractFormatted.substringAfter('/');
        String operatorCode = contractFormatted.substringBefore('/');
        lstAttendences  = CEC_360_Integration_ProtocolsResidential.getProtocols(contractNumber,operatorCode,startDate, endDate);
        return formatData(lstAttendences);
    }
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocolsNumber(string contractFormatted, 
                                                                       String protocolNumber)
    {
        List<CEC_RestObjects.attendences> lstAttendences = new List<Cec_RestObjects.attendences> ();
        String contractNumber = contractFormatted.substringAfter('/');
        String operatorCode = contractFormatted.substringBefore('/');
        lstAttendences  = CEC_360_Integration_ProtocolsResidential.getProtocolsNumber(operatorCode,protocolNumber);
        return formatData(lstAttendences);
    }
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> generateMock (){
        
        List< CEC_RestObjects.attendences> lstAttendences = new List<CEC_RestObjects.attendences>();
        
        for(integer i =0; i < 5;i++){
            CEC_RestObjects.attendences objAttendences = new CEC_RestObjects.attendences();
            objAttendences.order = '1';
            objAttendences.protocolNumber = String.valueOf(i+100);
            objAttendences.interactionNumber = '322722520';
            objAttendences.action = 'C';
            objAttendences.solicitationType = 'REGISTRO SISTEMICO';
            objAttendences.solicitationDateClosing = '2019-05-10T15:43:44';
            objAttendences.solicitationDateOpening = '2019-05-10T15:43:44';
            objAttendences.solicitationStatus = 'Executada';
            lstAttendences.add(objAttendences);
        }
        
        return lstAttendences;
        
    }
    
    
    @AuraEnabled
    public static List <CEC_RestObjects.attendences> getDetails (string protocolNumber,string contract){
        system.debug('Contract'+contract);
        string contractNumber = contract.substringAfter('/');
        String operatorCode = contract.substringBefore('/');
        List <CEC_RestObjects.attendences> fullProtocols = new List <CEC_RestObjects.attendences> ();
        fullProtocols = CEC_360_Integration_ProtocolsResidential.getProtocolsNumber(operatorCode, protocolNumber);
        return formatDetails(protocolNumber,fullProtocols);
    } 
    
    @AuraEnabled
    public static List <CEC_RestObjects.attendences> formatDetails (String protocolNumber, List<CEC_RestObjects.attendences> lstAttendences){
        List <CEC_RestObjects.attendences> lstFormatted = new List <CEC_RestObjects.attendences> ();
        
        for(integer i =0; i<lstAttendences.size();i++){
            
            if(lstAttendences[i].protocolNumber == protocolNumber){
                CEC_RestObjects.attendences obj = new CEC_RestObjects.attendences ();
                string dateOpening = lstAttendences[i].solicitationDateOpening;
                string dateClosing = lstAttendences[i].solicitationDateClosing;
                
                CEC_RestObjects.attendences atd = new CEC_RestObjects.attendences();
                obj.order = lstAttendences[i].order;
                obj.protocolNumber = lstAttendences[i].protocolNumber;
                obj.solicitationDateOpening = dateOpening.substring(8,10) + '/' + dateOpening.subString(5,7)+ '/'+
                    dateOpening.substring(0,4) +' as ' + dateOpening.substring(12,19);
                obj.solicitationDateClosing = dateClosing.substring(8,10) + '/' + dateClosing.subString(5,7)+ '/'+
                    dateClosing.substring(0,4) +' as ' + dateClosing.substring(12,19);
                obj.solicitationStatus = lstAttendences[i].solicitationStatus;
                obj.solicitationType = lstAttendences[i].solicitationType; 
                lstFormatted.add(obj);
            }
        }
        return lstFormatted;
    }
    
    public class accountTable{
        @auraEnabled public String idAcc;
        @auraEnabled public String contractNumber;
        @auraEnabled public String line;
    }
    
    
    
}