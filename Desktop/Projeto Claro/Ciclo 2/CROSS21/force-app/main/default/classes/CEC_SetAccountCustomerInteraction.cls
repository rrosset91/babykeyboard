/*******************************************************************************
* Labs
* @author           Nilyan Berti
* Proyect:          CEC
* Description:      Controlador base para creación de registro en Customer Interation para manejo de parametros en los OS
** Changes (Version)
* -------------------------------------------
*           No.     Fecha           Autor                    Descripción
*           -----   ----------      --------------------     ----------------
* @version   1.0    18/02/2019      Nilyan Berti             Creación de la clase
* @version   1.1    10/04/2019      Nilyan Berti             initOmniscript, returnOrderId getOrder methods added.
* @version   1.2    22/06/2020      Alexandre Farias         createCustomerInteration, change the method getRecordTypeInfosByName to getRecordTypeInfosByDeveloperName.
*															 Changed the class API Version to 47 to support the getRecordTypeInfosByDeveloperName.
*
**********************************************************************************/
public without sharing class CEC_SetAccountCustomerInteraction {

public String CustomerInteractionId {get;set;}
public String OrderIncustInt {get;set;}
public String accountId         = system.currentPageReference().getParameters().get('accountId');
public String documentType      = system.currentPageReference().getParameters().get('accountDocType');
public String documentNumber    = system.currentPageReference().getParameters().get('accountDocNumber');
public String CEP               = system.currentPageReference().getParameters().get('premisesCEP');
public String protocolNum       = system.currentPageReference().getParameters().get('numProtocolo');
List <vlocity_cmt__CustomerInteraction__c> orderKey  = new List<vlocity_cmt__CustomerInteraction__c> ();
List <Order> orderParameter       = new List<Order> ();
Map <String,String> mapOrderInput = new Map <String,String>();
Map <String,Order> mapOrderOutput = new Map <String,Order>();
 
  public CEC_SetAccountCustomerInteraction() {

  }


public void initOmniscript(){
    
    
    if ((documentNumber!=null || documentType!=null || CEP!=null || CEP!='undefined') && (protocolNum == null)) {
        createCustomerInteration(accountId,documentNumber,documentType,CEP,null, null);
    }  
    else if(protocolNum!=null ){
        returnOrderId(protocolNum);
    }
  
    
}

/**
 * createCustomerInteration description
 * @param  accountId      accountId description
 * @param  documentNumber documentNumber description
 * @param  documentType   documentType description
 * @param  CEP            CEP description
 */
  public void createCustomerInteration(String accountId, String documentNumber, String documentType, String CEP, String OrderID, String protocolNum) {
          
        vlocity_cmt__CustomerInteraction__c ci = new vlocity_cmt__CustomerInteraction__c();
        if (accountId != null) ci.vlocity_cmt__AccountId__c       = accountId;
        ci.RecordTypeId       = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('CEC_setParametersOS').getRecordTypeId();
        ci.Document_Number__c = documentNumber;
        ci.Document_Type__c   = documentType;
        ci.CEP__c             = CEP;
        if(OrderID !=null){
          ci.Order__c = OrderID;
        }
        if(protocolNum !=null){
          ci.numProtocolo__c = protocolNum;
        }

        insert ci; 
        this.CustomerInteractionId = ci.Id; 
  }

  // guardar el customer interaction con account id y la orden consulto la orden para sacar los datos de la cuenta y del premise el cep


  /**
   * returnOrderId description
   * @param  protocolNum protocolNum description
   */
  public void returnOrderId(String protocolNum){
   
      orderKey = getOrder(protocolNum);
      System.debug(orderKey);
      if (!orderKey.isEmpty()){
        //Order orderToUpdate = orderKey[0].Order_Key__c;
        mapOrderInput.put('cartId', orderKey[0].Order_Key__c);
        //Llamar aqui a getExpiredOrderItens
        orderParameter = getAccountParameters(orderKey[0].Order_Key__c);
        //CEC_CheckCustomer.getExpiredOrderItens(mapOrderInput, mapOrderOutput, null);
      System.debug(orderParameter);

        if(!orderParameter.isEmpty()){
          createCustomerInteration(orderParameter[0].AccountId , orderParameter[0].Account.DocumentNumber__c, orderParameter[0].Account.DocumentType__c, orderParameter[0].Account.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, orderKey[0].Order_Key__c,orderKey[0].Name);
        }
      }

      
    
  }

  /**
   * getOrder description
   * @param  protocolNumb protocolNumb description
   * @return              return description
   */
  public static List <vlocity_cmt__CustomerInteraction__c> getOrder(String protocolNumb){
        RETURN [SELECT Order_Key__c, vlocity_cmt__AccountId__c, Name
              FROM vlocity_cmt__CustomerInteraction__c
              WHERE Name =: protocolNumb 
              AND RecordType.DeveloperName = 'ProtocoloComercial'
              LIMIT 1];
      }

  /**
   * getAccountParameters description
   * @param  OrderId OrderId description
   * @return         return description
   */
  public static List <Order> getAccountParameters(String OrderId){
        RETURN [SELECT Id, AccountId, Account.DocumentNumber__c, Account.DocumentType__c, Account.vlocity_cmt__PremisesId__c,         Account.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c
              FROM Order
              WHERE Id =: OrderId 
              AND AccountId != NULL AND Account.DocumentNumber__c != NULL AND Account.DocumentType__c != NULL AND Account.vlocity_cmt__PremisesId__c != NULL AND         Account.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c  != NULL 
              LIMIT 1];
      }
}