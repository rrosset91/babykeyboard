/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Fase Extensão 1 - Sprint 15] - US475 (Atribuição automática de casos de clientes recorrentes)
* 
* Controle de Versão
* --------------------------------------------------------------- 
* Data: 06/03/2020   
* Autor: Squad Canais Criticos
* Alterações: Processamento dos casos de recorrencia de GOV, para atribuir automaticamente o status de 'Em Tratamento'
* ---------------------------------------------------------------
* Data: 09/07/2020   
* Autor: Squad Canais Criticos
* Alterações: Inclusão da condição de usuário estar ativo na busca do getOpenedCases
* ---------------------------------------------------------------
*/
public class CEC_CC_CustomBasedRouting 
{
    @testVisible private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    
    @InvocableMethod
    public static void routeUsingRecurrence(List<String> cases) 
    {        
        Map<Id, Id> mapOwnerCase = new Map<Id, Id>();
        List<String> lstCasesToRouteBySkill = new List<String>();
        List<Case> lstCasesToRouteManually = new List<Case>();
        Set<String> setGrouping = new Set<String>();
        Set<String> setChannel = new Set<String>();
        Set<String> setDocNumber = new Set<String>();
        Set<String> setRecordTypes = new Set<String>();
        
        //Validar se há alguma pendência de roteamento para os casos recebidos e se houver, excluir
        CEC_SkillsBasedRouting.deletePendingServiceRouting(cases);

        List<Case> lstCasesToRoute = [SELECT Id, 
                                      Grouping__c, 
                                      Channel__c, 
                                      Account.DocumentNumber__c,
                                      OwnerId,
                                      RecordTypeId, 
                                      Skill__c
                                      FROM Case WHERE Id IN : cases];
        
        system.debug('Casos para tratativa: ' + lstCasesToRoute);
        
        //Selecionar as chaves de combinação dos casos
        for(Case caseItem : lstCasesToRoute)
        {
            if(String.isNotBlank(caseItem.Channel__c))
                setChannel.add(caseItem.Channel__c);
            if(String.isNotBlank(caseItem.Grouping__c))
                setGrouping.add(caseItem.Grouping__c);
            if(String.isNotBlank(caseItem.Account.DocumentNumber__c))
                setDocNumber.add(caseItem.Account.DocumentNumber__c);
            //Filtrar somente pelo mesmo RT do caso para desconsiderar casos filhos e casos de apoio
            setRecordTypes.add(caseItem.RecordTypeId);
        }
        
        //Selecionar os casos fechados e seus respectivos proprietários
        Map<String, Map<String, Map<String, String>>> mapClosedCases = getClosedCases(setGrouping, setChannel, setDocNumber, lstCasesToRoute, setRecordTypes);
        if(mapClosedCases.size() > 0)
        {
        	system.debug('Casos fechados em ' + Label.CEC_CC_QtdDiasCasosFechados + ': ' + mapClosedCases);
            //Checar se o caso tem recorrencia e resgatar o Id do proprietario
            for(Case caseItem : lstCasesToRoute)
            {
                if(mapClosedCases.containsKey(caseItem.Account.DocumentNumber__c) && 
                   mapClosedCases.get(caseItem.Account.DocumentNumber__c).containsKey(caseItem.Grouping__c) &&
                   mapClosedCases.get(caseItem.Account.DocumentNumber__c).get(caseItem.Grouping__c).containsKey(caseItem.Channel__c))
                {
                    Id idOwner = mapClosedCases.get(caseItem.Account.DocumentNumber__c).get(caseItem.Grouping__c).get(caseItem.Channel__c);
                	mapOwnerCase.put(caseItem.Id, idOwner);
                }
            }
            
            //Validar se o usuário está ativo (tem algum caso em tratamento)
            Map<Id, Boolean> mapValidOwners = isValidOwners(mapOwnerCase.values(), lstCasesToRoute);
            
            //Atribuir proprietarios ativos para os casos recorrentes
            for(Case caseItem : lstCasesToRoute)
            {
                system.debug('Tem Owner recorrente: ' + mapOwnerCase.containsKey(caseItem.Id));
                system.debug('Owner está ativo: ' + mapValidOwners.containsKey(mapOwnerCase.get(caseItem.Id)));
                if(mapOwnerCase.containsKey(caseItem.Id) && 
                   mapValidOwners.containsKey(mapOwnerCase.get(caseItem.Id)) && 
                   mapValidOwners.get(mapOwnerCase.get(caseItem.Id)) == TRUE){
                    caseItem.OwnerId = mapOwnerCase.get(caseItem.Id);
                    lstCasesToRouteManually.add(caseItem); 
                }
                else 
                    lstCasesToRouteBySkill.add(caseItem.Id);
            }
        }
        else //Selecionar os casos em tratamento e seus respectivos proprietários
        {
            Map<String, Map<String, Map<String, String>>> mapOpenedCases = getOpenedCases(setGrouping, setChannel, setDocNumber, lstCasesToRoute, setRecordTypes);
            if(mapOpenedCases.size() > 0)
            {
                system.debug('Casos abertos recorrentes: ' + mapOpenedCases);
                //Checar se o caso tem recorrencia e resgatar o Id do proprietario
                for(Case caseItem : lstCasesToRoute)
                {
                    if(mapOpenedCases.containsKey(caseItem.Account.DocumentNumber__c) && 
                       mapOpenedCases.get(caseItem.Account.DocumentNumber__c).containsKey(caseItem.Grouping__c) &&
                       mapOpenedCases.get(caseItem.Account.DocumentNumber__c).get(caseItem.Grouping__c).containsKey(caseItem.Channel__c))
                    {
                        Id idOwner = mapOpenedCases.get(caseItem.Account.DocumentNumber__c).get(caseItem.Grouping__c).get(caseItem.Channel__c);
                        mapOwnerCase.put(caseItem.Id, idOwner);
                    }
                }
                
                //Não precisa validar se o usuário está ativo pois todos os casos nesta listagem estão em tratamento, é só atribuir ao caso              
                for(Case caseItem : lstCasesToRoute)
                {
                    system.debug('Tem Owner recorrente: ' + mapOwnerCase.containsKey(caseItem.Id));
                    if(mapOwnerCase.containsKey(caseItem.Id)) { 
                        caseItem.OwnerId = mapOwnerCase.get(caseItem.Id);
                        lstCasesToRouteManually.add(caseItem); 
                    }
                    else 
                        lstCasesToRouteBySkill.add(caseItem.Id);
                }
            }
            else {
                    for(Case varCase : lstCasesToRoute){
                        lstCasesToRouteBySkill.add(varCase.Id); 
                    }
            }
        }
        
        for(Case varCase :lstCasesToRouteManually){
            if(varCase.RecordTypeId == RT_CONSUMIDOR_GOV)
                varCase.SubStatus__c = 'Em tratamento';
        }
        
        system.debug('Casos para rotear Manual: ' + lstCasesToRouteManually);
        system.debug('Casos para rotear p/ Skill: ' + lstCasesToRouteBySkill);
        
        //Se houve recorrência, atualizar caso com o Id do proprietário passado
        if(lstCasesToRouteManually.size() > 0)
            Database.update(lstCasesToRouteManually);
            
        //Se nenhuma regra de aplicar, rotear normalmente por Skill do caso
        if(lstCasesToRouteBySkill.size() > 0)
        	CEC_SkillsBasedRouting.routeUsingSkills(lstCasesToRouteBySkill);
    }

    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descrição: Método que seleciona todos os casos fechados e tratados no periodo de dias para o grupo de
     *            Unidade de Negócio, Canal e CPF do Cliente
     */    
    public static Map<String, Map<String, Map<String, String>>> getClosedCases(Set<String> setGrouping, Set<String> setChannel, 
                                                                               Set<String> setDocNumber, List<Case> lstCasesToRoute, Set<String> setRecordTypesId)
    {
        Integer CEC_CC_QtdDiasCasosFechados = Integer.valueOf(Label.CEC_CC_QtdDiasCasosFechados);
        Map<String, Map<String, Map<String, Datetime>>> mapFilter = new Map<String, Map<String, Map<String, Datetime>>>();
        Map<String, Map<String, Map<String, String>>> mapOwnerByGroup = new Map<String, Map<String, Map<String, String>>>();
                
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, Account.DocumentNumber__c DocumentId, Grouping__c, Channel__c, MAX(ClosedDate) RecentClosedDate FROM Case 
             WHERE Channel__c IN: setChannel 
             AND Grouping__c IN: setGrouping 
             AND Account.DocumentNumber__c IN: setDocNumber 
             AND IsClosed = true AND ClosedDate >= : System.today().addDays(- CEC_CC_QtdDiasCasosFechados) 
             AND Id NOT IN : lstCasesToRoute
             AND RecordTypeId IN: setRecordTypesId
             AND Owner.IsActive = true
             GROUP BY OwnerId, Account.DocumentNumber__c, Grouping__c, Channel__c
            ]
        );
        
        return parseAggregateResult(lstAggResult, 'RecentClosedDate');
    }
    
    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descrição: Método que seleciona todos os casos em tratamento para o grupo de Unidade de Negócio, Canal e CPF do Cliente
     */    
    public static Map<String, Map<String, Map<String, String>>> getOpenedCases(Set<String> setGrouping, Set<String> setChannel, Set<String> setDocNumber, 
                                                                               List<Case> lstCasesToRoute, Set<String> setRecordTypesId)
    {
        Map<String, Map<String, Map<String, Datetime>>> mapFilter = new Map<String, Map<String, Map<String, Datetime>>>();
        Map<String, Map<String, Map<String, String>>> mapOwnerByGroup = new Map<String, Map<String, Map<String, String>>>();
                
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, Account.DocumentNumber__c DocumentId, Grouping__c, Channel__c, MAX(CreatedDate) RecentCreatedDate FROM Case 
             WHERE Channel__c IN: setChannel 
             AND Grouping__c IN: setGrouping
             AND Account.DocumentNumber__c IN: setDocNumber 
             AND IsClosed = false
             AND Id NOT IN : lstCasesToRoute
             AND RecordTypeId IN: setRecordTypesId
             AND Owner.IsActive = true
             GROUP BY OwnerId, Account.DocumentNumber__c, Grouping__c, Channel__c
            ]
        );
        
        return parseAggregateResult(lstAggResult, 'RecentCreatedDate');
    }
    
    /*
    * Autor: Squad Canais Criticos - Deloitte
    * Data: 21/11/2019 
    * Descrição: Método que agrupa as informações do select por grupo de Unidade de Negócio, Canal e CPF do Cliente
    */   
    @TestVisible
    private static Map<String, Map<String, Map<String, String>>> parseAggregateResult(List<AggregateResult> lstAggResult, String typeOfDate)
    {
        Map<String, Map<String, Map<String, Datetime>>> mapFilter = new Map<String, Map<String, Map<String, Datetime>>>();
        Map<String, Map<String, Map<String, String>>> mapOwnerByGroup = new Map<String, Map<String, Map<String, String>>>();
        
        for(AggregateResult result : lstAggResult)
        {    
            String ownerId = String.valueOf(result.get('OwnerId'));
            String accIdentifier = String.valueOf(result.get('DocumentId'));
            String grouping = String.valueOf(result.get('Grouping__c'));
            String channel = String.valueOf(result.get('Channel__c'));
            Datetime dateOfCase = (Datetime)result.get(typeOfDate);
                
            system.debug(ownerId + '|' + accIdentifier + '|' + grouping + '|' + channel + '|' + dateOfCase);
            
            if(!mapFilter.containsKey(accIdentifier)) {
                mapFilter.put(accIdentifier, new Map<String, Map<String, Datetime>>());
                mapOwnerByGroup.put(accIdentifier, new Map<String, Map<String, String>>());
            }            
            if(!mapFilter.get(accIdentifier).containsKey(grouping)) {
                mapFilter.get(accIdentifier).put(grouping, new Map<String, Datetime>());
                mapOwnerByGroup.get(accIdentifier).put(grouping, new Map<String, String>());
            }            
            if(!mapFilter.get(accIdentifier).get(grouping).containsKey(channel)) {
                mapFilter.get(accIdentifier).get(grouping).put(channel, dateOfCase);
                mapOwnerByGroup.get(accIdentifier).get(grouping).put(channel, ownerId);
            }
            if (mapFilter.get(accIdentifier).get(grouping).get(channel) < dateOfCase) {
                mapFilter.get(accIdentifier).get(grouping).put(channel, dateOfCase);
                mapOwnerByGroup.get(accIdentifier).get(grouping).put(channel, ownerId);
            }                
        }
        
       return mapOwnerByGroup;
    }
    
    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descrição: Método que valida se o usuário tem ao menos um caso em aberto ou em tratamento, 
     *            isso determina se o mesmo encontra-se ativo para roteamento de novos casos
     */
    public static Map<Id, Boolean> isValidOwners(List<Id> setOwnerId, List<Case> lstCasesToRoute)
    {
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, COUNT(Id) caseQuantity FROM Case WHERE Status <> 'Closed' AND Status <> 'Cancel' 
             AND OwnerId IN: setOwnerId AND Id NOT IN: lstCasesToRoute Group By OwnerId]);

		Map<Id, Boolean> mapIsValidOwner = new Map<Id, Boolean>();
        for(AggregateResult result : lstAggResult)
        {
            Boolean isValid = Integer.valueOf(result.get('caseQuantity')) > 0 ? true : false;
            mapIsValidOwner.put(String.valueOf(result.get('OwnerId')), isValid);
        }
        return mapIsValidOwner;
    }
}