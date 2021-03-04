/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 04/09/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 12] 
* 
* Controle de Versão
* --------------------------------------------------------------- */
public class CEC_CC_ContentDocumentLinkHandler extends TriggerHandler 	
{
    public override void beforeInsert() {
        validateDocument(Trigger.new);
    }	
    
    /*-------------------------------------------------------------------------------------------------------
    --- Company: Deloitte Brazil
    --- Creation Date: 4/09/2019
    --- Author: Squad Canais Críticos
    --- Description: Método que valida se os casos CEC estão encerrado impossibilitando o acrescimo de anexos
    -------------------------------------------------------------------------------------------------------*/
    public static void validateDocument(list<ContentDocumentLink> lstContentDocumentLink)
    {
        Set<Id> setIdRecCECTypes = new Set<Id>{ RT_CONSUMIDOR_GOV, CEC_CC_Anatel, CEC_CC_AtendimentoPessoal, CEC_CC_CanaisInternos, CEC_CC_Canais_Eletronicos,
            									CEC_CC_JEC, CEC_CC_Ouvidoria, CEC_CC_Pre_JEC, CEC_CC_Procon, CEC_CC_ReaberturaAnatel, CEC_CC_ChildrenCase, CEC_CC_SupportCase};
        Set<Id> setIds = new Set<Id>();
        for(ContentDocumentLink contentDocumentLink : lstContentDocumentLink) {
            //Selecionar os Ids dos pais dos anexos criados
            setIds.add(contentDocumentLink.LinkedEntityId);
        }
        
        Map<Id, Case> mapCasesById = new Map<Id, Case>([SELECT Id, RecordTypeId, Status, SubStatus__c 
                                                        FROM Case 
                                                        WHERE Id IN: setIds 
                                                        AND Status IN ('Encerrado', 'Closed')
                                                        AND RecordTypeId IN: setIdRecCECTypes]);
        
        for(ContentDocumentLink contentDocumentLink : lstContentDocumentLink) {
            //O anexo é referente a algum caso CEC com status de Encerrado
            if(mapCasesById.containsKey(contentDocumentLink.LinkedEntityId))
            {
                contentDocumentLink.addError('Não é possível inserir anexo para caso encerrado');
            }
        }
    }
    
    @testVisible 
    private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Anatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_AtendimentoPessoal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_AtendimentoPessoal').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CanaisInternos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Canais_Eletronicos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Canais_Eletronicos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_ReaberturaAnatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_ReaberturaAnatel').getRecordTypeId();
    @testVisible
    private static final String CEC_CC_ChildrenCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
    @testVisible
    private static final String CEC_CC_SupportCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId();

}