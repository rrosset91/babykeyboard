/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para fazer as queries de banco do porcesso do GGD.
*/

public class CEC_PME_SalesDocumentsQuerys 
{
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta do pedido
    */     
    public static Order getOrder(String orderId)
    {
        return [SELECT Id, AccountId, ReceiverFullName1__c, ReceiverFullName2__c, ReceiverFullName3__c,
                ReceiverRG1__c, ReceiverRG2__c, ReceiverRG3__c, ReceiverMobile1__c, ReceiverMobile2__c,
                ReceiverMobile3__c, ReceiverPhone1__c, ReceiverPhone2__c, ReceiverPhone3__c, OwnerId,
                toLabel(Payment_Term__c), OrderNumber, Related_Contacts__c, LD21__c
                FROM Order 
                WHERE Id =: orderId];
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta dos itens do pedido
    */     
    public static List<OrderItem> getOrderItens(String orderId)
    {
        return [SELECT Id, Product2.Name, Product2.ProductCode, TypeOfRequest__c, ParentGroup__c,
                Group__c, SubGroup__c, vlocity_cmt__RecurringTotal__c, Quantity, Payment_Term__c,
                ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, Product2.vlocity_cmt__Type__c,
                PortabilityNumber__c, DonatorName__c, DonatorDocumentNumber__c, DonatorPhone__c,
                DonatorEmail__c, Operator__c, ICCID__c, vlocity_cmt__RecurringCharge__c, Product2.Manufacturer__c,
                Product2.Model__c, DeviceSecondOptionColor__c, AnotherDeviceColor__c, vlocity_cmt__EffectiveRecurringTotal__c,
                PlanGroup__c, TradeIn__c, Discount_Type__c, Discount_Values__c, vlocity_cmt__OverageTotal__c,
                BonusValue__c, vlocity_cmt__RecurringDiscountPrice__c, UnitPrice, vlocity_cmt__ItemName__c
                FROM OrderItem 
                WHERE OrderId =: orderId];
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta do usuário
    */     
    public static User getSalesUser(String userId)
    {
        return [SELECT Id, Name, Resale__c, CNPJResale__c, ConsultantCode__c, Channel__c, AccountId, ResaleCode__c 
                FROM User 
                WHERE Id =:userId]; 
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta dos campos da conta
    */     
    public static Account getCustomerAccount(String accountId)
    {
        return [SELECT Id, Name, StateSubscription__c, MunicipalSubscription__c, CNAE__c, CNAE2__c, 
                DocumentNumber__c, NETClient__c, EmbratelClient__c, NumberOfEmployees, CommercialSegment__c, 
                BillingPostalCode, ShippingPostalCode, BillingStreet, ShippingStreet, CEC_BillingComplement__c, 
                CEC_ShippingComplement__c, CEC_BillingNeighborhood__c, CEC_ShippingNeighborhood__c, CEC_BillingNumber__c,
                BillingCity, ShippingCity, CEC_ShippingNumber__c, CEC_BillingAddressType__c, CEC_ShippingAddressType__c,
                Phone, BillingState, ShippingState, DueDay__c, NETContractNumber__c
                FROM Account 
                WHERE Id =: accountId];
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta dos administradores
    */     
    public static List<AccountContactRelation> getAccountRelations(Set<Id> setAdmins)
    {
        return [SELECT Id, Contact.Name, Contact.DocumentNumber__c, Contact.Email, Contact.Title, 
                Contact.Phone, ResponsibleForTheSignature__c, MobilePhone__c, Phone__c, Roles, Email__c 
                FROM AccountContactRelation 
                WHERE Id =: setAdmins];
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizada na consulta das faixas
    */     
    public static List<Product2> getRange(Set<String> setRange) {
        return [SELECT Name, ProductCode FROM Product2 WHERE ProductCode IN :setRange];
    }
}