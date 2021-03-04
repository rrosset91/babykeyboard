/*
* Autor: Diego Lima - Deloitte
* Data: 08/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para integração de upsert
* do objeto Pausa]
* 
*/


@RestResource(urlMapping='/CEC_CTI_SyncObjects/upsertPause')
global class CEC_CTI_SyncPausa {

    @HttpPost
    global static List<CEC_CTI_SyncObjectsWrapper> upsertPausa()
    {
        try{
            System.debug('entrou no upsertPausa');
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            System.debug('body == ' + body.toString());
            
            List<requestPausa> lstRequest = (List<requestPausa>)JSON.deserialize(body.toString(), List<requestPausa>.class); 
            System.debug('lstRequest == ' + lstRequest);
            
            Set<String> setSiteName = new set<String>();
            
            for(requestPausa lstSet : lstRequest){
                setSiteName.add(lstSet.Site);
            }
            System.debug('Set criado => ' + setSiteName);
            
            Map<String, Id> mapSiteId = new Map<String, Id>();
            
            for(Site__c forSite : [SELECT Id, CodSite__c FROM Site__c WHERE CodSite__c IN :setSiteName]){
                mapSiteId.put(forSite.CodSite__c, forSite.Id);
            }
            System.debug('Map criado => ' + mapSiteId);
            
            List<Pausa__c> lstPausaUpsert = new List<Pausa__c>();
            for(requestPausa rqs : lstRequest)
            {
                System.debug('Debug rqs =' + rqs);
                
                Pausa__c sObjPausa = new Pausa__c();
                sObjPausa.Name = rqs.Nome;
                sObjPausa.IdPausaDAC__c = rqs.IdPausaDAC;
                sObjPausa.TempoMin__c = rqs.TempoMin;
                sObjPausa.CodPausa__c = rqs.codPausa;
                sObjPausa.Site__c = mapSiteId.get(rqs.Site);
                sObjPausa.IsActive__c = Boolean.ValueOf(rqs.Ativo);
                
                System.debug('Site__c = ' + sObjPausa.Site__c);
                lstPausaUpsert.add(sObjPausa);
            }
    
            Schema.SObjectField f = Pausa__c.Fields.CodPausa__c;
            Database.UpsertResult [] lstUpsert = Database.upsert(lstPausaUpsert , f, false);
            
            List<String> listAllIdExternoPausa = assemblyExternalId(lstRequest);
            
            CEC_CTI_SyncObjectsReturnsWrapper dataReturn = new CEC_CTI_SyncObjectsReturnsWrapper();            
            dataReturn.listIdExterno = listAllIdExternoPausa;
            dataReturn.upsertResults = lstUpsert;

            return CEC_CTI_SyncObjectsReturns.getReturnTry(dataReturn);
           
        } catch (Exception e){
            System.debug('Erro do catch E = ' + e);
            
            Return CEC_CTI_SyncObjectsReturns.getReturnException(e);         
        }
                 
    }
    
    
    private static List<String> assemblyExternalId(List<requestPausa> lstPausas)
    {
        
        List<String> lstExternalIds = new List<String>();
        
        for(requestPausa iPausa : lstPausas)
        {
            lstExternalIds.add(iPausa.CodPausa);
        }
        
        return lstExternalIds;
    }

    
    public class requestPausa
    {
        public String Nome {get; set;} 
        public String CodPausa {get; set;}
        Public String IdPausaDAC {get; set;}
        Public String Site {get; set;}
        public Integer TempoMin {get; set;}
        public String Ativo {get; set;}
    }
}