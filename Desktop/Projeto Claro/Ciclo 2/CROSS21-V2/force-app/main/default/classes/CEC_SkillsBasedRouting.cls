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
--- Author: Squad LGPD - Sysmap Solutions
--- Description: Desvio de fluxo para direitos roteados via omni-channel baseado em habilidade.
--- Date: 06/01/2021
--- Alterado por : Fabio Sato Suenaga
-------------------------------------------------------------------------------------------------------*/

global class CEC_SkillsBasedRouting {  
    private static final Id RECORDTYPE_ID_LGPD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId();  
    
    @InvocableMethod
    public static void routeUsingSkills(List<String> cases) {    
        //Selecionar os casos dos Ids recebidos por parâmetro
        List<Case> lstCases = [SELECT Id, Description, Skill__c, RecordTypeId, Subject, Status FROM Case WHERE Id in :cases];
        
        Set<String> setSkillsId = new Set<String>();
        List<PendingServiceRouting> lstPendingServiceRouting = new List<PendingServiceRouting>();
        List<SkillRequirement> skillRequirements = new List<SkillRequirement>();
        
        String varChannelId = getChannelId('CaseCC');
        
        //Excluir as pendências de roteamento dos casos caso tenha alguma criada
        deletePendingServiceRouting(cases);
        
        //Selecionar as skill e criar as novas pendências 
        for(Case caseItem : lstCases) {
            lstPendingServiceRouting.add(getPendingServiceRouting(caseItem, varChannelId));
            setSkillsId.add(caseItem.Skill__c);
        }
        
        System.debug('*** lstCases: ' + lstCases);
        System.debug('*** lstPendingServiceRouting: ' + lstPendingServiceRouting);
        insert lstPendingServiceRouting;
        
        //Selecionar o Id das Novas Skills
        Map<String, Id> mapSkillByName = getSkillId(setSkillsId);
        
        //Selecionar os roteamentos por caso para melhor identificação
        Map<Id, PendingServiceRouting> mapPendingServiceRoutingByCase = new Map<Id, PendingServiceRouting>();
        for(PendingServiceRouting routing : [SELECT Id, IsReadyForRouting, WorkItemId FROM PendingServiceRouting WHERE Id IN: lstPendingServiceRouting]) {
            if(!mapPendingServiceRoutingByCase.containsKey(routing.WorkItemId))
                mapPendingServiceRoutingByCase.put(routing.WorkItemId, routing);
        }

        List<Case> lgpdCases = new List<Case>();

        //Criar um registro de skillRequirement de Pendencia x Skill para o Agente responsável e atualizar a pendência como 'Ready' para roteamento
        for(Case caseItem : lstCases) {
            mapPendingServiceRoutingByCase.get(caseItem.Id).IsReadyForRouting = TRUE;

            if (caseItem.RecordTypeId == RECORDTYPE_ID_LGPD) {

                lgpdCases.add(caseItem);
                continue;

            } 

            PendingServiceRouting varPendingServiceRouting = mapPendingServiceRoutingByCase.get(caseItem.Id);
            skillRequirements.add(getSkillRequirement(caseItem, varPendingServiceRouting.id, mapSkillByName.get(caseItem.Skill__c)));
        }

        Map<String, List<Case>> casesBySubject = getCasesBySubject(lgpdCases);
        Map<String, CEC_LGPDdsar__mdt> configBySubject = getConfigBySubject(casesBySubject.keySet());
        List<SkillRequirement> skillRequirementsGLPD = buildSkillForLGPDCases(casesBySubject, configBySubject, mapPendingServiceRoutingByCase); 

        skillRequirements.addAll(skillRequirementsGLPD);

        insert skillRequirements;
        update mapPendingServiceRoutingByCase.values();        
    }

    @testVisible
    private static Map<String, List<Case>> getCasesBySubject(List<Case> cases) {
        Map<String, List<Case>> casesBySubject = new Map<String, List<Case>>();

        for (Case caze : cases) {
            if (casesBySubject.containsKey(caze.Subject)) {

                casesBySubject.get(caze.Subject).add(caze);
                continue;

            }

            casesBySubject.put(caze.Subject, new List<Case>{caze});
        }

        return casesBySubject;
    }

    @testVisible
    private static Map<String, CEC_LGPDdsar__mdt> getConfigBySubject(Set<String> subjects) {
        Map<String, CEC_LGPDdsar__mdt> configBySubject = new Map<String, CEC_LGPDdsar__mdt>();

        List<CEC_LGPDdsar__mdt> configs = [SELECT PerfilOuvidoria__c, HasOmniChannel__c, Skills__c, rightName__c FROM CEC_LGPDdsar__mdt WHERE rightName__c IN :subjects];

        for (CEC_LGPDdsar__mdt config : configs) {
            configBySubject.put(config.rightName__c, config);
        }

        return configBySubject;
    }

    @testVisible
    private static Map<String, Skill> getSkillByDeveloperName(List<CEC_LGPDdsar__mdt> configs) {
        Map<String, Skill> skillByDeveloperName = new Map<String, Skill>();

        Set<String> skillDeveloperNames = new Set<String>();
        for (CEC_LGPDdsar__mdt config : configs) {

            if (String.isEmpty(config.Skills__c)) continue;
            
            config.Skills__c = config.Skills__c.replaceAll('\\n', '');
            config.Skills__c = config.Skills__c.replaceAll('\\r', '');
            
            List<String> tokens = config.Skills__c.split(';');
            
            skillDeveloperNames.addAll(tokens);
        }

        List<Skill> skills = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN: skillDeveloperNames];

        for (Skill skill : skills) {
            skillByDeveloperName.put(skill.DeveloperName, skill);
        }

        return skillByDeveloperName;
    }

    @testVisible
    private static List<SkillRequirement> buildSkillForLGPDCases(Map<String, List<Case>> casesBySubject, Map<String, CEC_LGPDdsar__mdt> configBySubject, Map<Id, PendingServiceRouting> pendingServiceRoutingByCaseId) {
        List<SkillRequirement> skillRequirements = new List<SkillRequirement>();

        Map<String, Skill> skillByDeveloperName = getSkillByDeveloperName(configBySubject.values());
        
        String lgpdQueueStr = UserInfo.getUserId();
        Profile[] profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
      
        for (String subject : casesBySubject.keySet()) {
            
            CEC_LGPDdsar__mdt config = configBySubject.get(subject);
            System.debug('config >>> ' + config);
            if (!config.HasOmniChannel__c) continue;
            
            List<String> tokens = config.Skills__c.split(';');
            Skill skillItem ;
            
            if(String.isNotBlank(config.PerfilOuvidoria__c) && config.PerfilOuvidoria__c.contains(profile[0].name + ';')){
                skillItem = skillByDeveloperName.get(tokens[0]); 
            }
            else{
                skillItem = skillByDeveloperName.get(tokens[1]); 
            }
            
            for (Case caze : casesBySubject.get(subject)) {
                
                PendingServiceRouting pendingServiceRouting = pendingServiceRoutingByCaseId.get(caze.Id);
                
                SkillRequirement skillRequirement = getSkillRequirement(caze, pendingServiceRouting.Id, skillItem.Id);
                skillRequirements.add(skillRequirement);
            }
        }

        return skillRequirements;
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
            // CapacityWeight = 1,
            IsReadyForRouting = false,
            RoutingModel  = 'MostAvailable',
            // RoutingPriority = 1,
            RoutingType = 'SkillsBased',
            ServiceChannelId = pChannelId,
            WorkItemId = pCase.Id,

            PushTimeout = 10,
            RoutingPriority = 3,
            CapacityWeight = 2
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