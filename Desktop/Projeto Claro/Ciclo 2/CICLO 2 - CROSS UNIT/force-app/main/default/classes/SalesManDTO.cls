/**
 * Created by 93668256 on 02/12/2019.
 */

global class SalesManDTO {

    global CEC_RestObjects.Error error;
    //SalesMan
    global class SalesMan extends CEC_RestObjects.ResponseGen{
        global SalesManData data ;
    }
    global class SalesManData {
        global Salesmen salesman ;
    }
    global class Salesmen {
        global String id ;
        global String name ;
        global String registration ;
        global String situation ;
        global String situationDate ;
        global Partyidentification partyidentification ;
        global List<ContactSalesMan> contact ;
        global SalesManAgent salesAgent ;
        global List<MarketArea> marketArea ;
        global UserSalesMan user ;
    }
    global class Partyidentification {
        global String type ; // in json: type
        global String numberZ ; // in json: number
    }
    global class ContactSalesMan {
        global String emailAddress ;
        global String telephoneNumbertype ;
        global String telephoneNumber ;
    }
    global class SalesManAgent {
        global String iwSalesAgentId ;
        global String iwTypeId ;
        global String description ;
        global String channelId ;
        global String businessName ;
        global String regionalId ;
        global String iwRegionalId ;
        global Address address ;
        global List<PointSale> pointSale ;
    }
    global class Address {
        global String type ;
        global String placeId ;
        global String city ;
        global String postalCode ;
        global String neighborhood ;
        global String streetType ;
        global String streetName ;
        global String streetNumber ;
        global String urbanPropertySubAddress ;
        global String boxNr ;
    }
    global class UserSalesMan {
        global String userId ;
        global String roleId ;
        global String description ;
        global List<Profiles> profiles ;
    }
    global class PointSale {
        global String iwSalesAgentId ;
        global String businessName ;
    }
    global class MarketArea {
        global Market market ;
    }
    global class Market {
        global List<Numeration> numeration ;

    }
    global class Numeration {
        global String ddd ;
    }
    global class Profiles {
        global String profileId ;
        global String name ;
    }

    //Salesman Residential
    global class SalesManRes extends CEC_RestObjects.ResponseGen
    {
        global ResData data ;
    }

    global class ResData
    {
        global SalesmanResidential salesman;
        global List<Company> company ;
    }
    global class SalesmanResidential
    {
        global String id ;
        global String login ;
        global String name ;
        global Partyidentification partyidentification ;
    }
    global class Company
    {
        global String id ;
        global String corporateName ;
        global List<SalesChannel> salesChannel ;
    }
    global class SalesChannel
    {
        global String id ;
        global String description ;
        global List<SalesTeam> salesTeam ;
    }
    global class SalesTeam
    {
        global String id ;
        global String description ;
    }

	public static List<SalesOrderIntegrationDTO.Profile_z> 
        convertProfile2SalerOrderProfile(Profile profile){
                
        List<SalesOrderIntegrationDTO.Profile_z> retorno = new List<SalesOrderIntegrationDTO.Profile_z>();
        retorno.add(new SalesOrderIntegrationDTO.Profile_z('AtvTlv', ''));
                     
        return retorno;
    }		
}