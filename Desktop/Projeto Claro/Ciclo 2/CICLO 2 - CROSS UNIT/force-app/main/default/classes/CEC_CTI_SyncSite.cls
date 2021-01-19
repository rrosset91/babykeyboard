/*
* Autor: Diego Lima - Deloitte
* Data: 31/10/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para integração de upsert
* do objeto Site]
* 
*/


@RestResource(urlMapping='/CEC_CTI_SyncObjects/upsertSite')
global class CEC_CTI_SyncSite {
	
    
    @HttpPost
    global static List<CEC_CTI_SyncObjectsWrapper> upsertSite()
    {
        System.debug('entrou no upsertSite');
        try {
            RestRequest req = RestContext.request;
            //System.debug(RestContext.request);
            Blob body = req.requestBody;
            //System.debug('body = ' + req.requestBody);
            System.debug('body == ' + body.toString());
            
            
            List<requestSite> lstRequest = (List<requestSite>)JSON.deserialize(body.toString(), List<requestSite>.class); 
            System.debug('lstRequest == ' + lstRequest);
                    
            List<Site__c> lstSiteUpsert = new List<Site__c>();
            for(requestSite rqs : lstRequest)
            {
                System.debug('Debug rqs =' + rqs);
                Site__c sObjSite = new Site__c();
                sObjSite.Name = rqs.Name;
                sObjSite.CodSite__c = rqs.Localizador;
                sObjSite.LigacaoExterna__c = Boolean.valueOf(rqs.LigacaoExterna);
                sObjSite.Tecnologia__c = rqs.Tecnologia;
                sObjSite.Unidade__c = rqs.Unidade;
                sObjSite.IsActive__c = Boolean.valueOf(rqs.Ativo);
                
                lstSiteUpsert.add(sObjSite);
            }
            
            Schema.SObjectField externalIdUpsert = Site__c.Fields.CodSite__c;
            Database.UpsertResult [] lstUpsert = Database.upsert(lstSiteUpsert , externalIdUpsert, false);
            
            List<String> listAllIdExternoSkill = assemblyExternalId(lstRequest);
            
            CEC_CTI_SyncObjectsReturnsWrapper dataReturn = new CEC_CTI_SyncObjectsReturnsWrapper();            
            dataReturn.listIdExterno = listAllIdExternoSkill;
            dataReturn.upsertResults = lstUpsert;

            return CEC_CTI_SyncObjectsReturns.getReturnTry(dataReturn);
            
        } catch (Exception e){    
            Return CEC_CTI_SyncObjectsReturns.getReturnException(e);          
        }              
    }

    private static List<String> assemblyExternalId(List<requestSite> lstSites)
    {
        
        List<String> lstExternalIds = new List<String>();
        
        for(requestSite iSite : lstSites)
        {
            lstExternalIds.add(iSite.Localizador);
        }
        
        return lstExternalIds;
    }
    
    
    public class requestSite
    {
        public String Name {get; set;} //Nome da empresa parceira
        public String Localizador {get; set;}
        Public String LigacaoExterna {get; set;}
        public String Tecnologia {get; set;}
        public String Unidade {get; set;}
        public String Ativo {get; set;}
    }
    
    
    
}