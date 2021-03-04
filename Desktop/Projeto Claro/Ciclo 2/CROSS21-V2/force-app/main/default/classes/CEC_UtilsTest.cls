/*
* Autor: RLdO
* Data: 11-jan-2019
* Descrição: CEC FASE 1 COMERCIAL: classe de teste e cobertura da classe CEC_Utils
*/
@isTest
private class CEC_UtilsTest
{
  @isTest static void testCPF()
  {
    system.assert(CEC_Utils.validateCPF('00272951099'));
  }

  @isTest static void testCNPJ()
  {
    system.assert(CEC_Utils.validateCNPJ('67476538000148'));
  }

  @isTest static void testNavToField()
  {
    Account lAcc = new Account(Name = 'Test');
    Contact lCtt = new Contact(FirstName = 'Test', LastName = 'Contact');
    lCtt.putSObject('Account', lAcc);

    Object lObj = CEC_Utils.navigateToField(lCtt, 'account.name');
    system.assert(lObj != null);

    lObj = CEC_Utils.navigateToField(lCtt, 'account.nonexistentfield__c');
    system.assert(lObj == null);
  }
}