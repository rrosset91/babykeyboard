/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Ocorrência Response Test]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 13/02/2019  
* Autor: Squad Canais Criticos
* Alterações: Utilização de Named Credentials 
*/
@isTest
public class CEC_OcurrencyNetResponseTest {

    @isTest public static void ocurrencyNetTest()
    {
        test.startTest();
          
          CEC_OcurrencyNetResponse lOcurrency = new CEC_OcurrencyNetResponse();
          lOcurrency.Data = new CEC_OcurrencyNetResponse.Data();
          lOcurrency.Link = new CEC_OcurrencyNetResponse.Link();
             
          lOcurrency.apiVersion = 'apiVersion';
          lOcurrency.transactionId = 'transactionId';
          lOcurrency.message = 'message';
          lOcurrency.detailedMessage = 'detailedMessage';
        
          lOcurrency.data.contactRecords = new List<CEC_OcurrencyNetResponse.ContactRecords>();
          lOcurrency.link.rel = 'rel';
          lOcurrency.Link.href = 'href';
          lOcurrency.data.ContactRecords =  new List<CEC_OcurrencyNetResponse.ContactRecords>();
          lOcurrency.data.contactRecords =  new List<CEC_OcurrencyNetResponse.ContactRecords>();
          lOcurrency.data.lContactRecords = new CEC_OcurrencyNetResponse.ContactRecords();
          lOcurrency.data.lContactRecords.note = 'note';
          lOcurrency.data.lContactRecords.eventDate = 'eventDate';
          lOcurrency.data.lContactRecords.sourceEvent = 'sourceEvent';
        
          lOcurrency.data.lContactRecords.User = new CEC_OcurrencyNetResponse.User();
          lOcurrency.data.lContactRecords.user.login = 'login'; 
          lOcurrency.data.lContactRecords.user.userName = 'userName'; 
        
          lOcurrency.data.lContactRecords.User.PartyId = new CEC_OcurrencyNetResponse.PartyId();
          lOcurrency.data.lContactRecords.User.partyId.type = 'type';
          lOcurrency.data.lContactRecords.User.partyId.addressId = 'addressId';
          lOcurrency.data.lContactRecords.User.partyId.country = 'country';
          lOcurrency.data.lContactRecords.User.partyId.placeId = 'placeId';
          lOcurrency.data.lContactRecords.User.partyId.cityId = 'cityId';
          lOcurrency.data.lContactRecords.User.partyId.cityName = 'cityName';
          lOcurrency.data.lContactRecords.User.partyId.postCode = 'postCode';
          lOcurrency.data.lContactRecords.User.partyId.neighborhood = 'neighborhood';
          lOcurrency.data.lContactRecords.User.partyId.streetType = 'streetType';
          lOcurrency.data.lContactRecords.User.partyId.streetTypeId = 'streetTypeId';
          lOcurrency.data.lContactRecords.User.partyId.streetName = 'streetName';
          lOcurrency.data.lContactRecords.User.partyId.streetNrFirst = 'streetNrFirst';
          lOcurrency.data.lContactRecords.User.partyId.urbanPropertySubAddress = 'urbanPropertySubAddress';
          lOcurrency.data.lContactRecords.User.partyId.complementarySubAddress = 'complementarySubAddress';
          lOcurrency.data.lContactRecords.User.partyId.boxNr = 'boxNr';
        
          lOcurrency.data.lContactRecords.User.Emailcontact = new CEC_OcurrencyNetResponse.Emailcontact();
          lOcurrency.data.lContactRecords.User.emailcontact.emailAddress = 'emailAddress';
        
          lOcurrency.data.lContactRecords.User.Telephone = new CEC_OcurrencyNetResponse.Telephone();
          lOcurrency.data.lContactRecords.User.telephone.areaCode = 'areaCode';
          lOcurrency.data.lContactRecords.User.telephone.extensionNumber = 'extensionNumber';
        
          lOcurrency.data.lContactRecords.EventType = new CEC_OcurrencyNetResponse.EventType();
          lOcurrency.data.lContactRecords.eventType.identifier = 'identifier';
          lOcurrency.data.lContactRecords.eventType.description = 'description';
          lOcurrency.data.lContactRecords.Type = new CEC_OcurrencyNetResponse.Type();
          lOcurrency.data.lContactRecords.type.identifier = 'identifier';
          lOcurrency.data.lContactRecords.type.description = 'description';
        
          lOcurrency.data.lContactRecords.Contact = new CEC_OcurrencyNetResponse.Contact();
          lOcurrency.data.lContactRecords.Contact.User = new CEC_OcurrencyNetResponse.User();
        
          lOcurrency.data.lContactRecords.Contact.ContactType = new CEC_OcurrencyNetResponse.ContactType();
          lOcurrency.data.lContactRecords.Contact.contactType.identifier = 'identifier';
          lOcurrency.data.lContactRecords.Contact.contactType.description = 'description';
          lOcurrency.data.lContactRecords.Contact.contactType.name = 'name';
          lOcurrency.data.lContactRecords.Contact.contactType.interactionNumber = 'interactionNumber';
          lOcurrency.data.lContactRecords.Contact.contactType.protocol = 'protocol';
        
          lOcurrency.data.lContactRecords.Contact.ContactMedium = new CEC_OcurrencyNetResponse.ContactMedium();
          lOcurrency.data.lContactRecords.Contact.contactMedium.Telephone = new CEC_OcurrencyNetResponse.Telephone();
          lOcurrency.data.lContactRecords.Contact.contactMedium.Emailcontact = new CEC_OcurrencyNetResponse.Emailcontact();
          lOcurrency.data.lContactRecords.Contact.contactMedium.PartyId = new CEC_OcurrencyNetResponse.PartyId();
          
          lOcurrency.Error = new CEC_OcurrencyNetResponse.Error();
          lOcurrency.error.httpCode = 'httpCode';
          lOcurrency.error.errorCode = 'errorCode';
          lOcurrency.error.message = 'message';
          lOcurrency.error.detailedMessage = 'detailedMessage';
          lOcurrency.error.Link = new CEC_OcurrencyNetResponse.Link();
          lOcurrency.error.link.rel = 'rel';
          lOcurrency.error.link.href = 'href';
        test.stopTest();
        system.assert(lOcurrency.detailedMessage.contains('detailedMessage'));
    }
    
}