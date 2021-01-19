/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Release 1]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 08/11/2019  
* Autor: Squad Canais Criticos
* Alterações: Tratativa para quando já existir uma pendencia de roteamento do caso (containsPendingServiceRouting)
* ---------------------------------------------------------------
* Data: 15/01/2019  
* Autor: Squad Canais Criticos
* Alterações: Tratativa para quando atrelar a pendencia correta do caso ao SkillRequirement pois estava apresentando erro quando inserido em lote
			  Melhorias para execução em lote, utilização de MAP e retirada de SELECTs em momentos incorretos
* ---------------------------------------------------------------
*/

global class CEC_SkillsBasedRouting 
{    
    @InvocableMethod
    public static void routeUsingSkills(List<String> cases) 
    {    
        system.debug('cases: ' + cases);
        //Selecionar os casos dos Ids recebidos por parâmetro
        List<Case> lstCases = [SELECT Id, Description, Skill__c FROM Case WHERE Id in :cases];
        
        Set<String> setSkillsId = new Set<String>();
        List<PendingServiceRouting> lstPendingServiceRouting = new List<PendingServiceRouting>();
        List<SkillRequirement> lstSkillRequirement = new List<SkillRequirement>();
        
        String varChannelId = getChannelId('CaseCC');
        
        //Excluir as pendências de roteamento dos casos caso tenha alguma criada
        deletePendingServiceRouting(cases);
        
        //Selecionar as skill e criar as novas pendências 
        for(Case caseItem : lstCases)
        {
            lstPendingServiceRouting.add(getPendingServiceRouting(caseItem, varChannelId));
            setSkillsId.add(caseItem.Skill__c);
        }
        
        insert lstPendingServiceRouting;
        
        //Selecionar o Id das Novas Skills
        Map<String, Id> mapSkillByName = getSkillId(setSkillsId);
        
        //Selecionar os roteamentos por caso para melhor identificação
        Map<Id, PendingServiceRouting> mapPendingServiceRoutingByCase = new Map<Id, PendingServiceRouting>();
        for(PendingServiceRouting routing : [SELECT Id, IsReadyForRouting, WorkItemId FROM PendingServiceRouting WHERE Id IN: lstPendingServiceRouting])
        {
            if(!mapPendingServiceRoutingByCase.containsKey(routing.WorkItemId))
                mapPendingServiceRoutingByCase.put(routing.WorkItemId, routing);
        }
             
        //Criar um registro de skillRequirement de Pendencia x Skill para o Agente responsável e atualizar a pendência como 'Ready' para roteamento
        for(Case caseItem : lstCases)
        {
            system.debug('Skill ( ' + caseItem.Skill__c + '): ' + mapSkillByName.containsKey(caseItem.Skill__c));
            PendingServiceRouting varPendingServiceRouting = mapPendingServiceRoutingByCase.get(caseItem.Id);
            lstSkillRequirement.add(getSkillRequirement(caseItem, varPendingServiceRouting.id, mapSkillByName.get(caseItem.Skill__c)));
            mapPendingServiceRoutingByCase.get(caseItem.Id).IsReadyForRouting = TRUE;
        }
        
        insert lstSkillRequirement;
        
        update mapPendingServiceRoutingByCase.values();        
    }
    
    public static void deletePendingServiceRouting(List<String> lstCases)
    {
        String varChannelId = getChannelId('CaseCC');
        list<PendingServiceRouting> lstPendingServiceRouting = [SELECT Id 
                                                                FROM PendingServiceRouting 
                                                                WHERE ServiceChannelId =: varChannelId 
                                                                AND WorkItemId IN: lstCases];
        
        if(lstPendingServiceRouting.size() > 0)
            Database.delete(lstPendingServiceRouting);
    }
    
    private static PendingServiceRouting getPendingServiceRouting(Case pCase, String pChannelId)
    {
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = false,
            RoutingModel  = 'MostAvailable',
            RoutingPriority = 1,
            RoutingType = 'SkillsBased',
            ServiceChannelId = pChannelId,
            WorkItemId = pCase.Id
        );
        
        return psrObj;
    }
    
    private static SkillRequirement getSkillRequirement(Case pCase, String pPendingServiceRouting, String skillId)
    {
        SkillRequirement srObj = new SkillRequirement(
            RelatedRecordId = pPendingServiceRouting,
            SkillId = skillId,
            SkillLevel = 5
        );    
        return srObj;    
    }
    
    public static String getChannelId(String channelName) 
    {
        ServiceChannel channel = [SELECT Id 
                                  FROM ServiceChannel 
                                  WHERE DeveloperName = :channelName];
        
        return channel.Id;
    }
    
    public static Map<String, Id> getSkillId(Set<String> setSkillsId)
    {
        Map<String, Id> mapSkillByName = new Map<String, Id>();
        
        for(Skill skillItem : [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN: setSkillsId]){
            if(!mapSkillByName.containsKey(skillItem.DeveloperName))
                mapSkillByName.put(skillItem.DeveloperName, skillItem.Id);
        }
        
        return mapSkillByName;
    }

}