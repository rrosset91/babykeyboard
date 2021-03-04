/**
 * 
 * Autor: Squad Evolutiva Canais Críticos - Sysmap Solutions
 * Data: 01/09/2020
 * Descrição: Unificação de canais Críticos
 * Classe para execução de validações da Unificação de Canais Críticos via trigger no Case
 * ---------------------------------------------------------------* 
 * Data: 30/09/2020   
 * Autor: Squad Canais Criticos
 * Alterações: Inclusão do record type CEC_CC_BackOffice_Atendimento no fluxo de validacao
 * ---------------------------------------------------------------
 * Data: 22/10/2020   
 * Autor: Squad Canais Criticos
 * Alterações: Inclusão de algumas consultas em todos singleton
 * ---------------------------------------------------------------
 */
public with sharing class CEC_CC_ValidationRuleCase {

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
    private static final String CEC_CC_CasoFilho = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CasoApoio = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_BackOffice_Atendimento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_BackOffice_Atendimento').getRecordTypeId();
    
    // Map de perfis e seus Ids
    private static Map<String, Profile> profileIds;
    
    // Names dos perfis que podem ser validados
    private static Set<String> profiles = new Set<String>{ 'Integracao SSO', 'RPA Canais Criticos', 'RPA_CEC_SF_0001', 'ZSF_CC_VALIDACAO_CONSUMIDORGOV', 'ZSF_CANAIS_CRITICOS_RPA', 'Staff Canais Criticos', 'Gerente Canais Criticos', 'Coordenador Consumidor Gov', 'Suporte Claro', 'Supervisor Gov', 'System Administrator', 'Administrador do sistema' };    

    /**
     * Obtem o profiles de forma singleton
     */
    private static Map<String, Profile> getProfileIds() {

        if(profileIds == null || profileIds.size() == 0) {

            profileIds = new Map<String, Profile>();
            for(Profile prof : [SELECT Id, Name from Profile WHERE Name IN :profiles]){
                profileIds.put(prof.Name, prof);
            }    

        }

        return profileIds;
    }

    /**
     * Método que executa as validações
     */
    public static void validationRules(List<Case> newCases){
        if(newCases == null){
            return;
        }

        // Construir lista de Subjects Ids
        Set<Id> outputSubjectsIds = new Set<Id>();        
        for(Case cs : newCases) {
            if(cs.Output_Subject__c != null && (cs.Output_Subject__r == null || cs.Output_Subject__r.Reason__c == null)){
                outputSubjectsIds.add(cs.Output_Subject__c);
            }
        }
        
        // Construir map de Ids e objetos de subjects
        if(outputSubjectsIds.size() > 0) {

            Map<Id, SubjectAdministration__c> outputSubjectMapId = new Map<Id, SubjectAdministration__c>([SELECT Id, Name, Reason__c FROM SubjectAdministration__c WHERE Id IN :outputSubjectsIds]);

            //Construit map de id de caso para seus subjects
            for(Case c : newCases){
                if(c.Output_Subject__c != null){
                    c.Output_Subject__r = outputSubjectMapId.get(c.Output_Subject__c);
                }
            }
        }


        CEC_CC_ValidaStatusEncerradoPS8 statusEncerradoPS8 = new CEC_CC_ValidaStatusEncerradoPS8(newCases);
        statusEncerradoPS8.validate();

        CEC_CC_Req_Encerramento_PreJec encerramentoPreJec = new CEC_CC_Req_Encerramento_PreJec(newCases);
        encerramentoPreJec.validate();

        CEC_CC_Req_CamposResolucao_Gov resolucaoGov = new CEC_CC_Req_CamposResolucao_Gov(newCases);
        resolucaoGov.validate();
    }

    private abstract class ValidationRule {
        public abstract void validate();
    }

    private class CEC_CC_ValidaStatusEncerradoPS8 extends ValidationRule{
        private Set<String> recordTypes = new Set<String>{ RT_CONSUMIDOR_GOV, CEC_CC_Anatel, CEC_CC_Canais_Eletronicos, CEC_CC_CanaisInternos, CEC_CC_JEC, CEC_CC_Ouvidoria, CEC_CC_Pre_JEC, CEC_CC_Procon, CEC_CC_ReaberturaAnatel , CEC_CC_BackOffice_Atendimento };
        private Set<String> profiles = new Set<String>{ 'ZSF_CANAIS_CRITICOS_RPA', 'Staff Canais Criticos', 'Gerente Canais Criticos', 'Coordenador Consumidor Gov', 'Suporte Claro', 'Supervisor Gov', 'System Administrator', 'Administrador do sistema' };
        private Map<ID, String> escapedProfileIds = new Map<ID, String>();
        private List<Case> cases;
        
        public CEC_CC_ValidaStatusEncerradoPS8(List<Case> cases){
            for(String prof : profiles) {
                if(getProfileIds().containsKey(prof)){
                    escapedProfileIds.put(getProfileIds().get(prof).Id , prof);
                }
            }
            this.cases = cases;
        }
        
        public override void validate(){

            for(Case newCase : this.cases){
                if( recordTypes.contains(newCase.RecordTypeId) && !escapedProfileIds.containsKey(UserInfo.getProfileId())){
                    if(
                        newCase.SubStatus__c == 'Encerrado'
                        && (newCase.Output_Subject__r == null || newCase.Output_Subject__r.Reason__c != 'CLASSE 900')
                        && ( newCase.BusinessUnit__c == 'Claro' || (newCase.BusinessUnit__c == 'Embratel' && newCase.Product__c == 'Grandes Empresas'))
                        && ( String.isBlank(newCase.Output_Subject__c) || String.isBlank(newCase.Resolution__c) || newCase.Relevant__c == '') 
                        ){
                            newCase.addError('Verificar se os campos da seção "Tipificação Motivo de Saída" foram preenchidos.');
                    }
                }
            }
        }
    }

    public class CEC_CC_Req_Encerramento_PreJec extends ValidationRule{
        private String recordType = CEC_CC_Pre_JEC;
        private Set<String> profiles = new Set<String>{ 'ZSF_CANAIS_CRITICOS_RPA', 'Integracao SSO', 'RPA Canais Criticos', 'RPA_CEC_SF_0001', 'ZSF_CC_VALIDACAO_CONSUMIDORGOV'};
        private Map<ID, String> escapedProfileIds = new Map<ID, String>();
        private List<Case> cases;
        
        public CEC_CC_Req_Encerramento_PreJec(List<Case> cases){
            for(String prof : profiles) {
                if(getProfileIds().containsKey(prof)){
                    this.escapedProfileIds.put(getProfileIds().get(prof).Id , prof);
                }
            }
            this.cases = cases;
        }
        
        public override void validate(){
            for(Case newCase : this.cases){
                System.debug(newCase.Output_Subject__r);
                if( recordType == newCase.RecordTypeId && !escapedProfileIds.containsKey(UserInfo.getProfileId())){
                    if(
                        !newCase.IsClosed
                        && newCase.SubStatus__c == 'Encerrado'
                        && (String.isBlank(newCase.Relevant__c) || String.isBlank(newCase.Resolution__c) || String.isBlank(newCase.PriorAgreement__c) || newCase.Output_Subject__r == null)
                        && (newCase.Output_Subject__r == null || newCase.Output_Subject__r.Reason__c != 'CLASSE 900')
                        ){
                            newCase.addError('Os campos "Reclamação é Procedente", "Resolução", "Houve acordo" e "Motivo de Saída" precisam ser informados.');
                    }
                }
            }
        }
    }

    public class CEC_CC_Req_CamposResolucao_Gov extends ValidationRule{
        private String recordType = RT_CONSUMIDOR_GOV;
        private Set<String> profiles = new Set<String>{ 'Integracao SSO' , 'RPA Canais Criticos' , 'RPA_CEC_SF_0001' , 'ZSF_CC_VALIDACAO_CONSUMIDORGOV' , 'ZSF_CANAIS_CRITICOS_RPA' , 'Suporte Claro' , 'System Administrator' , 'Administrador do sistema'};

        private Map<ID, String> escapedProfileIds = new Map<ID, String>();
        private List<Case> cases;

        public CEC_CC_Req_CamposResolucao_Gov(List<Case> cases){
            for(String prof : profiles) {
                if(getProfileIds().containsKey(prof)){
                    this.escapedProfileIds.put(getProfileIds().get(prof).Id , prof);
                }
            }
            this.cases = cases;
        }

        public override void validate(){
            for(Case newCase : this.cases){
                if( recordType == newCase.RecordTypeId && !escapedProfileIds.containsKey(UserInfo.getProfileId())){
                    if(
                        !newCase.IsClosed
                        && newCase.SubStatus__c == 'Respondido e Aguardando Avaliação'
                        && (String.isBlank(newCase.Relevant__c) || String.isBlank(newCase.Resolution__c) || String.isBlank(newCase.PriorAgreement__c) )
                        && (newCase.Output_Subject__r == null || newCase.Output_Subject__r.Reason__c != 'CLASSE 900')
                        ){
                            newCase.addError('Para alterar o sub-status para "Respondido e Aguardando Avaliação" é necessário '+
                                'informar se a "Reclamação é Procedente", a "Resolução" e se "Houve acordo".');
                    }
                }
            }
        }
    }

}