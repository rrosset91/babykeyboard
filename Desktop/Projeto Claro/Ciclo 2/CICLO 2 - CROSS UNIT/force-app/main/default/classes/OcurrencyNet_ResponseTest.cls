@isTest
public class OcurrencyNet_ResponseTest {

    @isTest public static void ocurrencyNetTest()
    {
        test.startTest();
          
          OcurrencyNet_Response lOcurrency = new OcurrencyNet_Response();
          lOcurrency.Data = new OcurrencyNet_Response.Data();
          lOcurrency.Link = new OcurrencyNet_Response.Link();
              
          lOcurrency.apiVersion = 'apiVersion';
          lOcurrency.transactionId = 'transactionId';
          lOcurrency.message = 'message';
          lOcurrency.detailedMessage = 'detailedMessage';
        
          lOcurrency.data.contactRecords = new List<OcurrencyNet_Response.ContactRecords>();
          lOcurrency.link.rel = 'rel';
          lOcurrency.Link.href = 'href';
          lOcurrency.data.ContactRecords =  new List<OcurrencyNet_Response.ContactRecords>();
          lOcurrency.data.contactRecords =  new List<OcurrencyNet_Response.ContactRecords>();
          lOcurrency.data.lContactRecords = new OcurrencyNet_Response.ContactRecords();
          lOcurrency.data.lContactRecords.note = 'note';
          lOcurrency.data.lContactRecords.eventDate = 'eventDate';
          lOcurrency.data.lContactRecords.sourceEvent = 'sourceEvent';
        
          lOcurrency.data.lContactRecords.User = new OcurrencyNet_Response.User();
          lOcurrency.data.lContactRecords.user.login = 'login'; 
          lOcurrency.data.lContactRecords.user.userName = 'userName'; 
        
          lOcurrency.data.lContactRecords.User.PartyId = new OcurrencyNet_Response.PartyId();
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
        
          lOcurrency.data.lContactRecords.User.Emailcontact = new OcurrencyNet_Response.Emailcontact();
          lOcurrency.data.lContactRecords.User.emailcontact.emailAddress = 'emailAddress';
        
          lOcurrency.data.lContactRecords.User.Telephone = new OcurrencyNet_Response.Telephone();
          lOcurrency.data.lContactRecords.User.telephone.areaCode = 'areaCode';
          lOcurrency.data.lContactRecords.User.telephone.extensionNumber = 'extensionNumber';
        
          lOcurrency.data.lContactRecords.EventType = new OcurrencyNet_Response.EventType();
          lOcurrency.data.lContactRecords.eventType.identifier = 'identifier';
          lOcurrency.data.lContactRecords.eventType.description = 'description';
          lOcurrency.data.lContactRecords.Type = new OcurrencyNet_Response.Type();
          lOcurrency.data.lContactRecords.type.identifier = 'identifier';
          lOcurrency.data.lContactRecords.type.description = 'description';
        
          lOcurrency.data.lContactRecords.Contact = new OcurrencyNet_Response.Contact();
          lOcurrency.data.lContactRecords.Contact.User = new OcurrencyNet_Response.User();
        
          lOcurrency.data.lContactRecords.Contact.ContactType = new OcurrencyNet_Response.ContactType();
          lOcurrency.data.lContactRecords.Contact.contactType.identifier = 'identifier';
          lOcurrency.data.lContactRecords.Contact.contactType.description = 'description';
          lOcurrency.data.lContactRecords.Contact.contactType.name = 'name';
          lOcurrency.data.lContactRecords.Contact.contactType.interactionNumber = 'interactionNumber';
          lOcurrency.data.lContactRecords.Contact.contactType.protocol = 'protocol';
        
          lOcurrency.data.lContactRecords.Contact.ContactMedium = new OcurrencyNet_Response.ContactMedium();
          lOcurrency.data.lContactRecords.Contact.contactMedium.Telephone = new OcurrencyNet_Response.Telephone();
          lOcurrency.data.lContactRecords.Contact.contactMedium.Emailcontact = new OcurrencyNet_Response.Emailcontact();
          lOcurrency.data.lContactRecords.Contact.contactMedium.PartyId = new OcurrencyNet_Response.PartyId();
          
          lOcurrency.Error = new OcurrencyNet_Response.Error();
          lOcurrency.error.httpCode = 'httpCode';
          lOcurrency.error.errorCode = 'errorCode';
          lOcurrency.error.message = 'message';
          lOcurrency.error.detailedMessage = 'detailedMessage';
          lOcurrency.error.Link = new OcurrencyNet_Response.Link();
          lOcurrency.error.link.rel = 'rel';
          lOcurrency.error.link.href = 'href';
    test.stopTest();
    }
}