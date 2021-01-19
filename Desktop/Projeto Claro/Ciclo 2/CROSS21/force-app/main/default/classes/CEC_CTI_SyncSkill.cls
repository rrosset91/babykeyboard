/*
* Autor: Diego Lima - Deloitte
* Data: 14/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para integração de upsert
* do objeto Skill]
* 
*/

@RestResource(urlMapping='/CEC_CTI_SyncObjects/upsertSkill')
global class CEC_CTI_SyncSkill {

    @HttpPost
    global static List<CEC_CTI_SyncObjectsWrapper> upsertSkill()
    {
        try{
            System.debug('entrou no upsertSkill');
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            System.debug('body == ' + body.toString());
            
            List<requestSkill> lstRequest = (List<requestSkill>)JSON.deserialize(body.toString(), List<requestSkill>.class); 
            System.debug('lstRequest == ' + lstRequest);
            
            Set<String> setSiteName = new set<String>();
            
            for(requestSkill lstSet : lstRequest){
                setSiteName.add(lstSet.Site);
            }
            System.debug('Set criado => ' + setSiteName);
            
            Map<String, Id> mapSiteId = new Map<String, Id>();
            
            for(Site__c forSite : [SELECT Id, CodSite__c FROM Site__c WHERE CodSite__c IN :setSiteName]){
                mapSiteId.put(forSite.CodSite__c, forSite.Id);
            }
            System.debug('Map criado => ' + mapSiteId);
            
            List<Skill__c> lstSkillpsert = new List<Skill__c>();
            for(requestSkill rqs : lstRequest)
            {
                System.debug('Debug rqs =' + rqs);
                Skill__c sObjSkill = new Skill__c();
                sObjSkill.Name = rqs.Nome;
                sObjSkill.CodSkill__c = rqs.CodigoSkill;
                sObjSkill.Conferencia__c = Boolean.valueOf(rqs.Conferencia);
                sObjSkill.Desliga__c = Boolean.valueOf(rqs.Desliga);
                sObjSkill.Espera__c = Boolean.valueOf(rqs.Espera);
                sObjSkill.IdExterno__c = rqs.IdPortal;
                sObjSkill.Site__c = mapSiteId.get(rqs.Site);
                sObjSkill.IsActive__c = Boolean.valueOf(rqs.Ativo);
                    
                System.debug('Site__c = ' + sObjSkill.Site__c);
                lstSkillpsert.add(sObjSkill);
    
            }
    
            Schema.SObjectField f = Skill__c.Fields.IdExterno__c;        
            Database.UpsertResult [] lstUpsert = Database.upsert(lstSkillpsert , f, false);
            
            List<String> listAllIdExternoSkill = assemblyExternalId(lstRequest);
            
            CEC_CTI_SyncObjectsReturnsWrapper dataReturn = new CEC_CTI_SyncObjectsReturnsWrapper();            
            dataReturn.listIdExterno = listAllIdExternoSkill;
            dataReturn.upsertResults = lstUpsert;

            return CEC_CTI_SyncObjectsReturns.getReturnTry(dataReturn);
           
        } catch (Exception e){
            System.debug('Erro do catch E = ' + e);
            
            Return CEC_CTI_SyncObjectsReturns.getReturnException(e);         
        }
                 
    }
    
    
    private static List<String> assemblyExternalId(List<requestSkill> lstPausas)
    {
        
        List<String> lstExternalIds = new List<String>();
        
        for(requestSkill iSkill : lstPausas)
        {
            lstExternalIds.add(iSkill.IdPortal);
        }
        
        return lstExternalIds;
    }

    
    public class requestSkill
    {
        public String Nome {get; set;} 
        public String CodigoSkill {get; set;}
        Public String Conferencia {get; set;}
        Public String Desliga {get; set;}
        public String Espera {get; set;}
        public String IdPortal {get; set;}
        public String Site {get; set;}
        public String Ativo {get; set;}
    }
    
}