/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe controller para o componente de busca para Memorandos de Assinantes.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*/

public class CEC_360_MemoController {
      static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    @AuraEnabled 
    public static CEC_RestObjects.memosMain getMemosAsset (string recordId,string startDate, string endDate){
        Cec_RestObjects.memosMain memosObj = new CEC_RestObjects.memosMain();
        String msisdn = getMsisdn(recordId);
        //memosObj = CEC_360_IntegrationMemos.generateMockMemosAssinante();
       memosObj = CEC_360_IntegrationMemos.getMemos(msisdn,startDate,endDate);  
       if(memosObj.data.memoObj != null){
            memosObj.data.memoObj = formatData(memosObj.data.memoObj);
            memosObj.data.memoObj = formatTextMemo(memosObj.data.memoObj);
        }
        system.debug('memos'+memosObj);
        return memosObj;
    }
 
    @AuraEnabled
  public static CEC_RestObjects.memosMain getMemosContract (string recordId,string startDate, string endDate){
        Cec_RestObjects.memosMain memosObj = new CEC_RestObjects.memosMain();
        String mobileBan = getBan(recordId);
        system.debug('MobileBan'+mobileBan);
        //memosObj = CEC_360_IntegrationMemos.generateMockMemosAssinante();
        memosObj = CEC_360_IntegrationMemos.getMemosContract(mobileBan,startDate,endDate);  
        
      if(memosObj.data.memoObj != null){
          memosObj.data.memoObj = formatData(memosObj.data.memoObj);
          memosObj.data.memoObj = formatTextMemo(memosObj.data.memoObj);
      }
        return memosObj;
    }   
    
    public static List<CEC_RestObjects.memos> formatData (List<CEC_RestObjects.memos> memoList){
        
        for(CEC_RestObjects.memos memoObj : memoList){
            memoObj.memoDate = memoObj.memoDate.substring(8,10)+'/'+ memoObj.memoDate.substring(5,7) +
                               '/' + memoObj.memoDate.substring(0,4) + ' as ' + memoObj.memoDate.substring(11,19);
        }
        
        
        return memoList;
    }
    
    public static List<CEC_RestObjects.memos> formatTextMemo (List<CEC_RestObjects.memos> memoList){
        
        for(CEC_RestObjects.memos memoObj : memoList){
            memoObj.memoText = memoObj.memoText.replace('TEXTO DO','');
        }
        return memoList;
    }
    
    public static String getBan(string recordId){
        Account acc = [Select ContractReferenceNumber__c from Account where id=: recordId];
        return acc.ContractReferenceNumber__c;
    }
    
    
    public static String getMsisdn(string recordId){
        Asset ativo = [SELECT msisdn__c from Asset where ID=:recordId];
        return ativo.msisdn__c;
    }
    
}