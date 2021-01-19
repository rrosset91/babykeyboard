@isTest
public without sharing class Solar_Cross_PriorityRoutingTest {

    @TestSetup
    static void makeData(){
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        cs.Resolution__c = 'Resolução da Resolução';
        cs.LegacyProtocol__c = '72645152';
        cs.InteractionNumber__c = '37856723673';
        cs.Channel__c = 'Atendimento Pessoal (ATP)';
        cs.Origin = 'Telefone';
        cs.Subject = 'Resolução da Resolução';
        cs.Description = 'Resolução da Resolução';
        cs.Status = 'Novo';
        cs.EntryReason__c = 'Validação de Contestação de Valores';
        cs.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        cs.Type = 'Pergunta';
        cs.CallReason__c = 'Produto';
        cs.RequestSupport__c = 'Descrição';	
        insert cs;

    }

    @isTest
    static void callBatchClassTest(){
        List<Case> lstCase = [SELECT Id FROM Case WHERE Status = 'Novo' ];
        Solar_SkillsBasedRouting.routUsingSkills(lstCase);
        Date dataInicio = Date.today();
        Date dataFim = Date.today().addDays(1);
        String datIn = dataInicio.year() + '-'+ dataInicio.month() + '-' + dataInicio.day();
        String datFi = dataFim.year() + '-'+ dataFim.month() + '-' + dataFim.day();
        String prio = '10';
        Boolean testa = Solar_Cross_PriorityRoutingController.verifyAssinc();
        Test.startTest();
            Solar_Cross_PriorityRoutingController.callBatchClass(datIn,datFi,prio);
        Test.StopTest();
        Boolean testa2 = Solar_Cross_PriorityRoutingController.verifyAssinc();


    }

    @isTest
    static void callBatchClassErrorTest(){
        List<Case> lstCase = [SELECT Id FROM Case WHERE Status = 'Novo' ];
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = false,
            RoutingPriority = 100,
            RoutingModel  = 'MostAvailable',
            RoutingType = 'SkillsBased',
            ServiceChannelId  = getChannelId('CaseCC'),
            WorkItemId = lstCase[0].Id
        );
        insert psrObj;
        Date dataInicio = Date.today();
        Date dataFim = Date.today().addDays(1);
        String datIn = dataInicio.year() + '-'+ dataInicio.month() + '-' + dataInicio.day();
        String datFi = dataFim.year() + '-'+ dataFim.month() + '-' + dataFim.day();
        String prio = '10';
        Test.startTest();
            Solar_Cross_PriorityRoutingController.callBatchClass(datIn,datFi,prio);
        Test.StopTest();
        Boolean testa2 = Solar_Cross_PriorityRoutingController.verifyAssinc();

    }

        
    public static String getChannelId(String channelName) {
        ServiceChannel channel = [SELECT Id 
                                  FROM ServiceChannel 
                                  WHERE DeveloperName = :channelName];
        
        return channel.Id;
    }

}