@isTest
private class CEC_CreateAccountFromOS_tst {

public List <Account> accountToUpdate = new List <Account>();
public List <Account> accountToUpdateWithPremise = new List <Account>();
public String contextId {get;set;}
public String accountId       = system.currentPageReference().getParameters().get('ContextId');
public String documentType      = system.currentPageReference().getParameters().get('accountDocType');
public String documentNumber    = system.currentPageReference().getParameters().get('accountDocNumber');
public String CEPtoInsert       = system.currentPageReference().getParameters().get('premisesCEP');

  @isTest static void retrieveAccount() {
    String accountID;
    String documentType;
    String documentNumber;
    String contextId;
    List <Account> acountToCompare = [SELECT Id, DocumentType__c,DocumentNumber__c, RecordTypeId from Account where RecordType.DeveloperName = 'Consumer' LIMIT 1 ];
    List <Account> accountToInsert = new List<Account>();

  for (Account acc: acountToCompare ){
      accountID = acc.Id;
      documentType = acc.DocumentType__c;
      documentNumber = acc.DocumentNumber__c;
      accountToInsert.add(acc);
  }

  insert  accountToInsert;


  //    if(accountId == null){
    //      Account acc       = new Account();
  //      acc.Name        = '-';
  //      acc.DocumentType__c   = documentType;
  //      cc.DocumentNumber__c  = documentNumber;
  //      acc.RecordTypeId      = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
  //    insert acc;
  //    this.contextId = acc.Id;
  //       else
  //     }
  //      this.contextId = accountId;
  //    {

    }




}