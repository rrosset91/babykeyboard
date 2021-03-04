global without sharing class CEC_SSO_BatchInactiveUser implements Schedulable, Database.Stateful, Database.Batchable<SObject>, Database.AllowsCallouts
{
    global static Boolean isTestingError = false;
    global list<LogUser__c> lLstLogUsr;

    //Id's dos usuarios que foram desativados
    private Set<ID> inactiveUserIds;
    
    public static final String NOME_AGENDAMENTO = 'Inativar usuarios';
    public static final String EXPRESSAO = '0 16 11 ? * MON,TUE,WED,THU,FRI,SAT,SUN *'; //Diariamente as 11h e 16m
    
    public String startDate;
    public String endDate;  
    
    //AGENDAMENTO DIARIO:
    /*
        CEC_SSO_BatchInactiveUser.startJob();
    */ 
    
    //EXECUCAO COM DATA ESPECIFICA
    /*
     	Passando como parametro data inicial e final no formato YYYY-MM-DD, como exemplo abaixo;
      	Database.executeBatch(new CEC_SSO_BatchInactiveUser('2018-12-31', '2019-12-31'));
    */ 
    
  	public CEC_SSO_BatchInactiveUser(String startDate, String endDate) 
  	{
      this.lLstLogUsr  = new list<LogUser__c>();
      
      this.startDate = startDate;
      this.endDate = endDate;
  	}
    
    // Método que faz o schedule desta classe no Salesforce
    public static void startJob()
    {
        system.debug('*** startJob()');
        system.schedule(NOME_AGENDAMENTO, EXPRESSAO, new CEC_SSO_BatchInactiveUser(null, null));
    }

    //global Iterable<CEC_ObjectFactory.ResponseInactiveUser> start(Database.BatchableContext bc)
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Datetime lToday = Datetime.newInstance(system.today(), Time.newInstance(0, 0, 0, 0)),
      	lYesterday = lToday.addDays(-1);
      
        list<String> lLstArgs;
        if(String.isBlank(this.startDate) && String.isBlank(this.endDate))
        {
            lLstArgs = new list<String>
            { 'startDate=' + lYesterday.format('yyyy-MM-dd'),
              'endDate=' + lToday.format('yyyy-MM-dd'), 
              'resourceName=' + EncodingUtil.urlEncode('CEC Salesforce', 'UTF-8')
            };          
        }
        else
        {
            lLstArgs = new list<String>
            { 'startDate=' + startDate,
              'endDate=' + endDate, 
              'resourceName=' + EncodingUtil.urlEncode('CEC Salesforce', 'UTF-8')
            };  
        }
        
        System.debug(lLstArgs);
        CEC_ObjectFactory.ResponseInactiveUser lUsr = CEC_SSO_IntegrationInactiveUser.consultar(lLstArgs);
        System.debug('lUsr: ' + lUsr);
        
        list<CEC_ObjectFactory.ResponseUser> lLstUsr = (lUsr == null || lUsr.data == null || lUsr.data.user == null) ? new list<CEC_ObjectFactory.ResponseUser>() : lUsr.data.user;
        
        set<String> lSetFedId = new set<String>();
        for (CEC_ObjectFactory.ResponseUser iUsr: lLstUsr) {
            if (String.isNotBlank(iUsr.federationId)) lSetFedId.add(iUsr.federationId);
        }
        
        System.debug('lLstUsr: ' + lLstUsr);
        System.debug('lSetFedId: ' + lSetFedId);
        
        String lQuery = 'SELECT Id, FederationIdentifier FROM User where FederationIdentifier = :lSetFedId and IsActive = true';
        return Database.getQueryLocator(lQuery);
    }
    
    global void execute(SchedulableContext sc)
    {
        database.executeBatch(new CEC_SSO_BatchInactiveUser(null, null));
    }
    
    //global void execute(Database.BatchableContext bc, List<CEC_ObjectFactory.ResponseInactiveUser> aLstUsr)
    global void execute(Database.BatchableContext bc, List<User> aLstUsr)
    {
        for (User iUsr: aLstUsr)
        {
          iUsr.IsActive = false;
          if (test.isRunningTest() && isTestingError) iUsr.LastName = null;
        }
    
        list<Database.SaveResult> lLstSavRes = database.update(aLstUsr, false);
        this.inactiveUserIds = new Set<ID>();
        for (Integer i = 0; i < lLstSavRes.size(); i++)
        {
          Database.SaveResult iRes = lLstSavRes[i];
          User lUsr = aLstUsr[i];
          if (iRes.isSuccess()) {
            //Adiciona na lista se o usuario foi inativado com sucesso para, no finish, rotear os casos
            this.inactiveUserIds.add(lUsr.Id);
            continue;
          }
          String lError = '';
          for (Database.Error iError: iRes.getErrors()) lError += ('\n' + iError.getMessage());
          this.lLstLogUsr.add(new LogUser__c(User__c = lUsr.Id, Log__c = lError.trim()));
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        if (!this.lLstLogUsr.isEmpty()) database.insert(this.lLstLogUsr);
        
        //Canais Criticos. Realiza o roteamento de casos de canais criticos do usuarios que foram inativados
        if(this.inactiveUserIds != null && this.inactiveUserIds.size() > 0) {

           CEC_CC_InativeUserCasesRouting.startJob(this.inactiveUserIds);
           
        }
    }
}