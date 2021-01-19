/*******************************************************************************
* Labs
* @author           Nilyan Berti
* Proyect:          CEC
* Description:      Controlador base para creación de cuenta dummy en la llamada    *         del OS
** Changes (Version)
* -------------------------------------------
*           No.     Fecha           Autor                    Descripción
*           -----   ----------      --------------------     ----------------
* @version   1.0    12/02/2019      Nilyan Berti             Creación de la clase
*      1.2  13/02/2019    Nilyan Berti       Se agrega el método  *                                                            createPremises
*
**********************************************************************************/


public without sharing class CEC_CreateAccountFromOS {

public List <Account> accountToUpdate = new List <Account>();
public List <Account> accountToUpdateWithPremise = new List <Account>();
public String contextId {get;set;}
public String accountId       = system.currentPageReference().getParameters().get('ContextId');
public String documentType      = system.currentPageReference().getParameters().get('accountDocType');
public String documentNumber    = system.currentPageReference().getParameters().get('accountDocNumber');
public String CEPtoInsert       = system.currentPageReference().getParameters().get('premisesCEP');

    public CEC_CreateAccountFromOS() {
        // act = new Account();
    }

   public  void createPremises() {
    if(CEPtoInsert != null){
      vlocity_cmt__Premises__c pr = new vlocity_cmt__Premises__c();
      pr.Name              = '-';
      pr.vlocity_cmt__StreetAddress__c = '-';
      pr.vlocity_cmt__City__c      = '-';
      pr.Number__c           = '-';
      pr.Neighborhood__c         = '-';
      pr.vlocity_cmt__State__c         = '-';
      pr.vlocity_cmt__PostalCode__c  = CEPtoInsert;
      insert pr;
      createAccount(pr.id);
    }else{
      createAccount(null);
      }
  }

  public void createAccount(String premiseId) {
    if(accountId == null){
          Account acc       = new Account();
        acc.Name        = '-';
        acc.DocumentType__c   = documentType;
        acc.DocumentNumber__c   = documentNumber;
        acc.RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
      acc.vlocity_cmt__PremisesId__c = premiseId;
      insert acc;
      this.contextId      = acc.Id;
    }else
    {
      this.contextId  = accountId;
      accountToUpdate = getAccountById(this.contextId);
      if(accountToUpdate.size() > 0){
        for(Account accPremise :accountToUpdate){
          if(premiseId != null){
            accPremise.vlocity_cmt__PremisesId__c = premiseId;
          }
          accountToUpdateWithPremise.add(accPremise);
        }
        update accountToUpdateWithPremise;
      }
    }
  }

  private List<Account> getAccountById(String accountId){
     List <Account> accountReturned = [SELECT id, Name,vlocity_cmt__PremisesId__c
    FROM Account where Id =: accountId];

    return accountReturned;

  }
}