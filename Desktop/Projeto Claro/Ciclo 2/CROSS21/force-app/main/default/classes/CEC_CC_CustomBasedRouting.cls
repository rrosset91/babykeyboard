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
* Data: 16/11/2020   
* Autor: Squad Canais Criticos
* Alterações: Tratamento de unificacao de canais para na regra de recorrencia considerar canais agrupados.
* ---------------------------------------------------------------
*/
public class CEC_CC_CustomBasedRouting 
{
    @testVisible private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();

    /**
     * Perfis que devem ser considerados na regra de recorrencia
     */
    private static Set<String> PERFIS_CONSIDERADOS;

    private static Set<String> STATUS_DESCONSIDERADOS_ROTEAMENTO = new Set<String> {'Cancel','Closed','Cancelado','Encerrado'};
    
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

        //Grupo para buscar os casos em cenario especial
        Set<String> setGroupingSpecial = new Set<String>();
        Set<String> setChannelSpecial = new Set<String>();
        Set<String> setRecordTypesSpecial = new Set<String>();                

        //Mapa do numero do documento do clientecom a configuracao especial
        Map<String, CEC_CC_Util.UnifiedChannel> mapSpecialClients = new Map<String, CEC_CC_Util.UnifiedChannel>();
        Map<String, Id> mapSpecialCases = new Map<String, Id>();
        Set<Id> setSpecialCases = new Set<Id>();

        if(PERFIS_CONSIDERADOS == null || !PERFIS_CONSIDERADOS.isEmpty()) 
        {
            PERFIS_CONSIDERADOS = new Set<String>();
            for(Solar_ProfilesRecurrence__mdt Profile : [SELECT ProfileRecurrence__c FROM Solar_ProfilesRecurrence__mdt])
            {
                PERFIS_CONSIDERADOS.add(Profile.ProfileRecurrence__c);
            }
        }

        //Validar se há alguma pendência de roteamento para os casos recebidos e se houver, excluir
        CEC_SkillsBasedRouting.deletePendingServiceRouting(cases);

        List<Case> lstCasesToRoute = [SELECT Id, 
                                      Grouping__c, 
                                      Channel__c, 
                                      Account.DocumentNumber__c,
                                      OwnerId,
                                      RecordTypeId, 
                                      BusinessUnit__c,
                                      Skill__c
                                      FROM Case WHERE Id IN : cases AND
                                      Status NOT IN :STATUS_DESCONSIDERADOS_ROTEAMENTO AND
                                      AccountId != null];
        
        system.debug('Casos para tratativa: ' + lstCasesToRoute);

        if(lstCasesToRoute != null && lstCasesToRoute.size() > 0) 
        {
            //Selecionar as chaves de combinação dos casos
            for(Case caseItem : lstCasesToRoute)
            {
                //Documento é tratado em separado
                if(String.isNotBlank(caseItem.Account.DocumentNumber__c)) {
                    setDocNumber.add(caseItem.Account.DocumentNumber__c);
                }                

                //Regra de recorrencia considerando unificacao de canais. como nesse ponto é processado cada caso que vem na thread, precisa testar cada canal. Se repetir, o addAll considera apenas uma ocorrencia por ser
                //um set
                CEC_CC_Util.UnifiedChannel unifiedChannel = CEC_CC_Util.getUnifiedChannelByCase(caseItem);
                if(unifiedChannel != null) 
                {
                    System.debug('Existe unificacao para o Caso de ' + caseItem.Channel__c + ',' + caseItem.Grouping__c);
                    setChannel.addAll(unifiedChannel.channels);                
                    setGrouping.addAll(unifiedChannel.groupings);                
                    setRecordTypes.addAll(unifiedChannel.recordTypeIds);                  

                    //Verifica se essa configuracao possui parametros de mapeamento de caso especial
                    if(String.isNotBlank(unifiedChannel.specialQueue) && caseItem.Account != null && String.isNotBlank(caseItem.Account.DocumentNumber__c)) 
                    {
                        mapSpecialClients.put(caseItem.Account.DocumentNumber__c, unifiedChannel);
                        mapSpecialCases.put(caseItem.Account.DocumentNumber__c, caseItem.id);
                        setSpecialCases.add(caseItem.id);

                        setChannelSpecial.addAll(unifiedChannel.channels);                
                        setGroupingSpecial.addAll(unifiedChannel.groupings);                
                        setRecordTypesSpecial.addAll(unifiedChannel.recordTypeIds);                                 
                    }
                } 
                else 
                {
                    if(String.isNotBlank(caseItem.Channel__c)) 
                    {
                        setChannel.add(caseItem.Channel__c);
                    }
                        
                    if(String.isNotBlank(caseItem.Grouping__c)) 
                    {
                        setGrouping.add(caseItem.Grouping__c);
                    }

                    //Filtrar somente pelo mesmo RT do caso para desconsiderar casos filhos e casos de apoio
                    setRecordTypes.add(caseItem.RecordTypeId);
                }
            }
            
            //Antes de verificar os casos abertos e os casos fechados, é necessário verificar se existem casos especiais para tratar.
            if(setSpecialCases.size() > 0)
            {
                Map<Id,String> specialCasesToRoute = getSpecialCases(setGroupingSpecial, setChannelSpecial, setDocNumber, setRecordTypesSpecial, setSpecialCases, mapSpecialCases, mapSpecialClients, cases);
                if(specialCasesToRoute != null && specialCasesToRoute.size() > 0)
                {
                    System.debug('Casos especias encontrados: ' + specialCasesToRoute);
                    Map<String, Id> queues = CEC_CC_Util.getQueue(new Set<String>(specialCasesToRoute.values()));
                    if(queues != null && !queues.isEmpty())
                    {
                        List<Case> tmpLstCasesToRoute = new List<Case>();
                        for(Case caseItem : lstCasesToRoute)
                        {
                            if(specialCasesToRoute.containsKey(caseItem.Id) && queues.containsKey(specialCasesToRoute.get(caseItem.Id)))
                            {
                                //Sera atribuido para a fila 
                                caseItem.OwnerId = queues.get(specialCasesToRoute.get(caseItem.Id));
                                lstCasesToRouteManually.add(caseItem);
                            }
                            else 
                            {
                                tmpLstCasesToRoute.add(caseItem);
                            }
                        }
                        lstCasesToRoute = tmpLstCasesToRoute;
                    }
                }
            }

            //Selecionar os casos fechados e seus respectivos proprietários
            Map<String, Map<String, Map<String, Map<String, String>>>> mapClosedCases = getClosedCases(setGrouping, setChannel, setDocNumber, cases, setRecordTypes);
            if(mapClosedCases.size() > 0)
            {
                system.debug('Casos fechados em ' + Label.CEC_CC_QtdDiasCasosFechados + ': ' + mapClosedCases);
                for(Case caseItem : lstCasesToRoute)
                {
                    checkMapOwnerUnificado(mapClosedCases, mapOwnerCase, caseItem);
                }

                //Validar se o usuario esta ativo (tem algum caso em tratamento)
                Map<Id, Boolean> mapValidOwners = isValidOwners(mapOwnerCase.values(), cases);
                
                //Atribuir proprietarios ativos para os casos recorrentes
                for(Case caseItem : lstCasesToRoute)
                {
                    system.debug('Tem Owner recorrente: ' + mapOwnerCase.containsKey(caseItem.Id));
                    system.debug('Owner esta ativo: ' + mapValidOwners.containsKey(mapOwnerCase.get(caseItem.Id)));
                    if(mapOwnerCase.containsKey(caseItem.Id) && 
                       mapValidOwners.containsKey(mapOwnerCase.get(caseItem.Id)) && 
                       mapValidOwners.get(mapOwnerCase.get(caseItem.Id)) == TRUE)
                    {
                        caseItem.OwnerId = mapOwnerCase.get(caseItem.Id);
                        lstCasesToRouteManually.add(caseItem); 
                    }
                    else 
                    {
                        lstCasesToRouteBySkill.add(caseItem.Id);
                    }
                }
            }
            else //Selecionar os casos em tratamento e seus respectivos proprietários
            {
                Map<String, Map<String, Map<String, Map<String, String>>>> mapOpenedCases = getOpenedCases(setGrouping, setChannel, setDocNumber, cases, setRecordTypes);
                if(mapOpenedCases.size() > 0)
                {
                    system.debug('Casos abertos recorrentes: ' + mapOpenedCases);
                    //Checar se o caso tem recorrencia e resgatar o Id do proprietario
                    for(Case caseItem : lstCasesToRoute)
                    {
                        checkMapOwnerUnificado(mapOpenedCases, mapOwnerCase, caseItem);
                    }
                    
                    //Não precisa validar se o usuário está ativo pois todos os casos nesta listagem estão em tratamento, é só atribuir ao caso              
                    for(Case caseItem : lstCasesToRoute)
                    {
                        system.debug('Tem Owner recorrente: ' + mapOwnerCase.containsKey(caseItem.Id));
                        if(mapOwnerCase.containsKey(caseItem.Id)) 
                        { 
                            caseItem.OwnerId = mapOwnerCase.get(caseItem.Id);
                            lstCasesToRouteManually.add(caseItem); 
                        }
                        else 
                        {
                            lstCasesToRouteBySkill.add(caseItem.Id);
                        }
                    }
                }
                else 
                {
                    for(Case varCase : lstCasesToRoute)
                    {
                        lstCasesToRouteBySkill.add(varCase.Id); 
                    }
                }
            }
            
            for(Case varCase :lstCasesToRouteManually) {
                if(varCase.RecordTypeId == RT_CONSUMIDOR_GOV)
                    varCase.SubStatus__c = 'Em tratamento';
            }
            
            system.debug('Casos para rotear Manual: ' + lstCasesToRouteManually);
            system.debug('Casos para rotear p/ Skill: ' + lstCasesToRouteBySkill);
            
            //Se houve recorrência, atualizar caso com o Id do proprietário passado
            if(lstCasesToRouteManually.size() > 0) {
                Database.update(lstCasesToRouteManually);
            }
                
            //Se nenhuma regra de aplicar, rotear normalmente por Skill do caso
            if(lstCasesToRouteBySkill.size() > 0) {
                CEC_SkillsBasedRouting.routeUsingSkills(lstCasesToRouteBySkill);
            }
        }        
    }

    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descrição: Método que seleciona todos os casos fechados e tratados no periodo de dias para o grupo de
     *            Unidade de Negócio, Canal e CPF do Cliente
     */    
    public static Map<String, Map<String, Map<String, Map<String, String>>>> getClosedCases(Set<String> setGrouping, Set<String> setChannel, 
                                                                               Set<String> setDocNumber, List<String> cases, Set<String> setRecordTypesId)
    {
        Integer CEC_CC_QtdDiasCasosFechados = Integer.valueOf(Label.CEC_CC_QtdDiasCasosFechados);
        Map<String, Map<String, Map<String, Datetime>>> mapFilter = new Map<String, Map<String, Map<String, Datetime>>>();
        Map<String, Map<String, Map<String, String>>> mapOwnerByGroup = new Map<String, Map<String, Map<String, String>>>();
                
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, Account.DocumentNumber__c DocumentId, Grouping__c, Channel__c, BusinessUnit__c, MAX(ClosedDate) RecentClosedDate FROM Case 
             WHERE Channel__c IN :setChannel 
             AND Grouping__c IN :setGrouping 
             AND BusinessUnit__c != null
             AND Account.DocumentNumber__c IN :setDocNumber 
             AND IsClosed = true AND ClosedDate >= :System.today().addDays(- CEC_CC_QtdDiasCasosFechados) 
             AND Id NOT IN :cases
             AND RecordTypeId IN :setRecordTypesId
             AND Owner.IsActive = true
             AND Owner.Profile.Name IN :PERFIS_CONSIDERADOS
             GROUP BY OwnerId, Account.DocumentNumber__c, Grouping__c, Channel__c, BusinessUnit__c
            ]
        );
        
        return parseAggregateResult(lstAggResult, 'RecentClosedDate');
    }
    
    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descrição: Método que seleciona todos os casos em tratamento para o grupo de Unidade de Negócio, Canal e CPF do Cliente
     */    
    public static Map<String, Map<String, Map<String, Map<String, String>>>> getOpenedCases(Set<String> setGrouping, Set<String> setChannel, Set<String> setDocNumber, 
                                                                               List<String> cases, Set<String> setRecordTypesId)
    {
        Map<String, Map<String, Map<String, Datetime>>> mapFilter = new Map<String, Map<String, Map<String, Datetime>>>();
        Map<String, Map<String, Map<String, String>>> mapOwnerByGroup = new Map<String, Map<String, Map<String, String>>>();
                
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, Account.DocumentNumber__c DocumentId, Grouping__c, Channel__c, BusinessUnit__c, MAX(CreatedDate) RecentCreatedDate FROM Case 
             WHERE Channel__c IN :setChannel 
             AND Grouping__c IN :setGrouping
             AND BusinessUnit__c != null
             AND Account.DocumentNumber__c IN :setDocNumber 
             AND IsClosed = false
             AND Id NOT IN :cases
             AND RecordTypeId IN :setRecordTypesId
             AND Owner.IsActive = true
             AND Owner.Profile.Name IN :PERFIS_CONSIDERADOS
             GROUP BY OwnerId, Account.DocumentNumber__c, Grouping__c, Channel__c, BusinessUnit__c
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
    private static Map<String, Map<String, Map<String, Map<String, String>>>> parseAggregateResult(List<AggregateResult> lstAggResult, String typeOfDate)
    {
        //O nivel é -> documento, grupo, canal e unidade de negocio
        Map<String, Map<String, Map<String,Map<String, Datetime>>>> mapFilter = new Map<String, Map<String, Map<String,Map<String, Datetime>>>>();
        Map<String, Map<String, Map<String,Map<String, String>>>> mapOwnerByGroup = new Map<String, Map<String, Map<String,Map<String, String>>>>();
        
        for(AggregateResult result : lstAggResult)
        {    
            String ownerId = String.valueOf(result.get('OwnerId'));
            String accIdentifier = String.valueOf(result.get('DocumentId'));
            String grouping = String.valueOf(result.get('Grouping__c'));
            String channel = String.valueOf(result.get('Channel__c'));
            String businessUnit = String.valueOf(result.get('BusinessUnit__c'));

            Datetime dateOfCase = (Datetime)result.get(typeOfDate);
                
            system.debug(ownerId + '|' + accIdentifier + '|' + grouping + '|' + channel + '|' + businessUnit + '|' + dateOfCase);
            
            if(!mapFilter.containsKey(accIdentifier)) {
                mapFilter.put(accIdentifier, new Map<String, Map<String,Map<String, Datetime>>>());
                mapOwnerByGroup.put(accIdentifier, new Map<String, Map<String,Map<String, String>>>());
            }            
            if(!mapFilter.get(accIdentifier).containsKey(grouping)) {
                mapFilter.get(accIdentifier).put(grouping, new Map<String,Map<String, Datetime>>());
                mapOwnerByGroup.get(accIdentifier).put(grouping, new Map<String,Map<String, String>>());
            }                        
            if(!mapFilter.get(accIdentifier).get(grouping).containsKey(channel)) {
                mapFilter.get(accIdentifier).get(grouping).put(channel, new Map<String, Datetime>());
                mapOwnerByGroup.get(accIdentifier).get(grouping).put(channel, new Map<String, String>());
            }            
            if(!mapFilter.get(accIdentifier).get(grouping).get(channel).containsKey(businessUnit)) {
                mapFilter.get(accIdentifier).get(grouping).get(channel).put(businessUnit, dateOfCase);
                mapOwnerByGroup.get(accIdentifier).get(grouping).get(channel).put(businessUnit, ownerId);
            }            
            if (mapFilter.get(accIdentifier).get(grouping).get(channel).get(businessUnit) < dateOfCase) {
                mapFilter.get(accIdentifier).get(grouping).get(channel).put(businessUnit, dateOfCase);
                mapOwnerByGroup.get(accIdentifier).get(grouping).get(channel).put(businessUnit, ownerId);
            }                
        }
        
       return mapOwnerByGroup;
    }
    
    /*
     * Autor: Squad Canais Criticos - Deloitte
     * Data: 21/11/2019 
     * Descriacao: Metodo que valida se o usuÃ¡rio tem ao menos um caso em aberto ou em tratamento, 
     *            isso determina se o mesmo encontra-se ativo para roteamento de novos casos
     */
    public static Map<Id, Boolean> isValidOwners(List<Id> setOwnerId, List<String> cases)
    {
        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT OwnerId, COUNT(Id) caseQuantity FROM Case WHERE Status <> 'Closed' AND Status <> 'Cancel' 
             AND OwnerId IN :setOwnerId AND Id NOT IN :cases Group By OwnerId]);

		Map<Id, Boolean> mapIsValidOwner = new Map<Id, Boolean>();
        for(AggregateResult result : lstAggResult)
        {
            Boolean isValid = Integer.valueOf(result.get('caseQuantity')) > 0 ? true : false;
            mapIsValidOwner.put(String.valueOf(result.get('OwnerId')), isValid);
        }
        return mapIsValidOwner;
    }

    /**
     * Checa o map de casos fechados ou abertos do cliente em busca do owner de recorrencia
     */
    private static Boolean checkMapOwner(Map<String, Map<String, Map<String, Map<String, String>>>> mapCases, Map<Id, Id> mapOwnerCase, String caseId, String documentNumber, String grouping, String channel, String excludedBusinessUnit)
    {
        Boolean containsBaseKeys = mapCases.containsKey(documentNumber) && 
                                   mapCases.get(documentNumber).containsKey(grouping) &&
                                   mapCases.get(documentNumber).get(grouping).containsKey(channel);

        if(containsBaseKeys)
        {
            Map<String,String> mapBusinessUnitOwner = mapCases.get(documentNumber).get(grouping).get(channel);
            if(!mapBusinessUnitOwner.isEmpty())
            {
                //Se nao tiver unidade de negocio a desconsiderar, pega o primeiro owner do map de businessUnit com owner
                if(String.isBlank(excludedBusinessUnit))
                {
                    mapOwnerCase.put(caseId, mapBusinessUnitOwner.values().get(0));
                    return true;
                }
                else 
                {
                    //Tendo uniade a desconsiderar, precisa percorrer e pegar a primeira que for diferente
                    Set<String> businessUnitsMap = mapBusinessUnitOwner.keySet();
                    for(String businessUnitMap : businessUnitsMap)
                    {
                        if(businessUnitMap != null && !businessUnitMap.equals(excludedBusinessUnit))
                        {
                            mapOwnerCase.put(caseId, mapBusinessUnitOwner.get(businessUnitMap));
                            return true;
                        }
                    }
                }
            }
        }               
        return false;
    }

    /**
     * Checa o map de casos fechados ou abertos do cliente em busca do owner de recorrencia - considera os canais unificados
     */
    private static Boolean checkMapOwnerUnificado(Map<String, Map<String, Map<String, Map<String, String>>>> mapCases, Map<Id, Id> mapOwnerCase, Case caseItem)
    {
        String caseId = caseItem.Id;
        String documentNumber = caseItem.Account.DocumentNumber__c;
        String grouping = caseItem.Grouping__c;
        String channel = caseItem.Channel__c;

        //Busca o canal unificado para o caso corrente
        CEC_CC_Util.UnifiedChannel unifiedChannel = CEC_CC_Util.getUnifiedChannelByCase(caseItem);
        if(unifiedChannel != null && 
           unifiedChannel.channels != null && !unifiedChannel.channels.isEmpty() && 
           unifiedChannel.groupings != null && !unifiedChannel.groupings.isEmpty() && 
           unifiedChannel.excludedBusinessUnits != null && !unifiedChannel.excludedBusinessUnits.isEmpty()) 
        {
            for(String groupingUnified : unifiedChannel.groupings) 
            {
                for(String channelUnified : unifiedChannel.channels)
                {
                    if(unifiedChannel.excludedBusinessUnits != null && !unifiedChannel.excludedBusinessUnits.isEmpty())
                    {
                        for(String excludedBusinessUnitUnified : unifiedChannel.excludedBusinessUnits)
                        {
                            //Somente pode considera a unidade de negocio na exclusao se forem canais diferentes, senao nao vai funcionar a regra antiga
                            Boolean diferenteChannelGrouping = channel != null && !channel.equals(channelUnified) && grouping != null && !grouping.equals(groupingUnified);
                            System.debug('Diferente agrupamento: ' + diferenteChannelGrouping + ' - Para: ' + channel + ' - ' + grouping);
                            Boolean ownerEncontrado = checkMapOwner(mapCases, mapOwnerCase, caseId, documentNumber, groupingUnified, channelUnified, diferenteChannelGrouping ? excludedBusinessUnitUnified : null);
                            if(ownerEncontrado)
                            {
                                return true;
                            }
                        }
                    }
                    else 
                    {
                        Boolean ownerEncontrado = checkMapOwner(mapCases, mapOwnerCase, caseId, documentNumber, groupingUnified, channelUnified, null);
                        if(ownerEncontrado)
                        {
                            return true;
                        }                    
                    }
                }
            }

            return false;
        }
        else
        {
            return checkMapOwner(mapCases, mapOwnerCase, caseId, documentNumber, grouping, channel, null);
        }
    }    

    /**
     * Obtem a relação de casos que tem casos abertos ou fechados em até 60 dias
     * Retorna a lista de casos com o id do caso e nome da fila para o qual ele vai
     */
    public static Map<Id, String> getSpecialCases(Set<String> setGroupingSpecial, Set<String> setChannelSpecial, Set<String> setDocNumber, Set<String> setRecordTypesSpecial, Set<Id> setSpecialCases,
                                                  Map<String, Id> mapSpecialCases, Map<String, CEC_CC_Util.UnifiedChannel> mapSpecialClients, List<String> cases)
    {
        Integer Solar_QtdDiasCasosFechadosEspecial = Integer.valueOf(Label.Solar_QtdDiasCasosFechadosEspecial);
        Integer Solar_QtdRecorrenciasEspecial = Integer.valueOf(Label.Solar_QtdRecorrenciasEspecial);

        //Id do caso do processo junto com a fila para ser roteada. Retorno do método
        Map<Id,String> specialCasesToRoute = new Map<Id,String>();

        //Mapara com o numero do documento e a quantidade de casos, sejam abertos ou fechados
        Map<String,Integer> numberOfCases = new Map<String,Integer>();

        List<AggregateResult> lstAggResult = new List<AggregateResult>(
            [SELECT Account.DocumentNumber__c DocumentId
             FROM Case 
             WHERE Channel__c IN :setChannelSpecial 
             AND Grouping__c IN :setGroupingSpecial 
             AND Account.DocumentNumber__c IN :setDocNumber 
             AND Id NOT IN :setSpecialCases
             AND Id NOT IN :cases
             AND RecordTypeId IN :setRecordTypesSpecial
             AND Owner.Profile.Name IN :PERFIS_CONSIDERADOS
             AND (ClosedDate = null OR ClosedDate >= :(System.today().addDays(- Solar_QtdDiasCasosFechadosEspecial))) 
             GROUP BY Account.DocumentNumber__c
             HAVING COUNT(Id) >= :Solar_QtdRecorrenciasEspecial 
            ]
        );

        if(lstAggResult != null && lstAggResult.size() > 0)
        {
            for(AggregateResult result : lstAggResult)
            {
                String documentId = String.valueOf(result.get('DocumentId'));
                CEC_CC_Util.UnifiedChannel unifiedChannel = mapSpecialClients.get(documentId);

                //Se ja passou do limite maximo, considera que o caso tem que ir para a fila especial
                if(unifiedChannel != null && mapSpecialCases.containsKey(documentId))
                {
                    specialCasesToRoute.put(mapSpecialCases.get(documentId), unifiedChannel.specialQueue);
                }
            }       
        }

        System.debug('specialCasesToRoute: ' + specialCasesToRoute);
        
        return specialCasesToRoute; 
    }
}