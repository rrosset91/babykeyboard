/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe de Integração para o servicos de Memorandos.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*-------------------- Versão ------------------------*
* [19/07] - Letícia Freitas - Alteração para credencial nomeada. 
*/

public class CEC_360_IntegrationMemos {
    
    public static CEC_RestObjects.memosMain getMemos(string msisdn,string startDate, string endDate){
        Cec_RestObjects.memosMain memosObj = new CEC_RestObjects.memosMain();
        String mobileSubscriberId;
        if(!test.isRunningTest()){
            mobileSubscriberId   = CEC_360_IntegrationsSubscriberHistory.getMobileId(msisdn);
        }else{
            mobileSubscriberId = '1';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ + CEC_ServiceName__c.getValues('Memos').ServiceName__c 
                                +'?memoLevel=ASSINANTE'+'&mobileSubscriberId='+mobileSubscriberId+
                                '&startDate=' + startDate + '&endDate=' + endDate);
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBodyaha'+responseBody.replace('/n',''));
            if(response.getStatusCode() == 200){
                memosObj = (CEC_RestObjects.memosMain)JSON.deserialize(responseBody, CEC_RestObjects.memosMain.class);
                system.debug('memosObj'+memosObj);
            }
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return memosObj;
    }
    
     public static CEC_RestObjects.memosMain getMemosContract(string mobileBan,string startDate, string endDate){
        Cec_RestObjects.memosMain memosObj = new CEC_RestObjects.memosMain();
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ + CEC_ServiceName__c.getValues('Memos').ServiceName__c +
                                '?memoLevel=CLIENTE'+'&mobileBan='+mobileBan+
                                '&startDate=' + startDate + '&endDate=' + endDate);
            request.setMethod('GET');
            request.setTimeout(12000);
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBody2'+responseBody.replace('/n',''));
            if(response.getStatusCode() == 200){
                memosObj = (CEC_RestObjects.memosMain)JSON.deserialize(responseBody, CEC_RestObjects.memosMain.class);
                system.debug('memosObj'+memosObj);
            }
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return memosObj;
    }
    
    public static CEC_RestObjects.memosMain generateMockMemosAssinante(){
        List<CEC_RestObjects.memos> memoList = new List <CEC_RestObjects.memos> ();
        for(integer i = 0; i < 20;i++)
        {
            CEC_RestObjects.memos memoData = new CEC_RestObjects.memos();
            memoData.memoDate = '2019-06-14T13:35:08.000-03:00';
            memoData.memoType = 'ABC' + i ;
            memoData.memoCategoryDesc = 'Descrição da Categoria';
            memoData.memoText = 'Memo Text';
            memoList.add(memoData);
        }
        CEC_RestObjects.memosMain memoObj = new CEC_RestObjects.memosMain();
        CEC_RestObjects.dataMemo dataMemo = new CEC_RestObjects.dataMemo();
        dataMemo.memoObj = memoList;
        memoObj.data = dataMemo;
        return memoObj;
    }
}