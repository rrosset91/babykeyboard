@isTest
public class PortabilitiesPreAnalysisDTOTest {
    @isTest
    public static void mainTest() {
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest newPortabilityPreAnalysisRequest = 
            new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest();
        
        newPortabilityPreAnalysisRequest.data = 
            new PortabilitiesPreAnalysisDTO.ListOfPhoneNumber();
        newPortabilityPreAnalysisRequest.data.telephoneNumbers = null;
        
        
        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis newPortabilityPreAnalysis = 
            new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis();
        
        
        newPortabilityPreAnalysis.data = 
            new PortabilitiesPreAnalysisDTO.PortabilityPre();
        
        newPortabilityPreAnalysis.data.portabilty = 
            new PortabilitiesPreAnalysisDTO.Vailables();
        
        newPortabilityPreAnalysis.data.portabilty.unavailables =
            new PortabilitiesPreAnalysisDTO.Unavailables();
        newPortabilityPreAnalysis.data.portabilty.unavailables.detail = 'test';
        newPortabilityPreAnalysis.data.portabilty.unavailables.reasonId = 'test';
        
        newPortabilityPreAnalysis.data.portabilty.unavailables.tickets = new List<PortabilitiesPreAnalysisDTO.Tickets>();
        
        newPortabilityPreAnalysis.data.portabilty.unavailables.tickets.add(
            new PortabilitiesPreAnalysisDTO.Tickets());
        newPortabilityPreAnalysis.data.portabilty.unavailables.tickets.get(0).id = 'test';
        newPortabilityPreAnalysis.data.portabilty.unavailables.tickets.get(0).telephoneNumber = 
            new PortabilitiesPreAnalysisDTO.TelephoneNumber();
        newPortabilityPreAnalysis.data.portabilty.unavailables.tickets.get(0).telephoneNumber.number_z = '1';
        
        newPortabilityPreAnalysis.data.portabilty.availables =
            new PortabilitiesPreAnalysisDTO.Availables();
        newPortabilityPreAnalysis.data.portabilty.availables.portabilityIndicatorSource = 'test';
        newPortabilityPreAnalysis.data.portabilty.availables.detail = 'test';
        newPortabilityPreAnalysis.data.portabilty.availables.name = 'test';
        newPortabilityPreAnalysis.data.portabilty.availables.spidCode = 'test';
        newPortabilityPreAnalysis.data.portabilty.availables.tickets = newPortabilityPreAnalysis.data.portabilty.unavailables.tickets;
        
        PortabilitiesPreAnalysisDTO.PhoneNumber newPhoneNumber = 
            new PortabilitiesPreAnalysisDTO.PhoneNumber();
        newPhoneNumber.number_z = '1';
        
        PortabilitiesPreAnalysisDTO.Portabilty newPortabilty = 
            new PortabilitiesPreAnalysisDTO.Portabilty();
        newPortabilty.availables = null;
        newPortabilty.unavailables = null;
        
        
        System.assert(newPortabilityPreAnalysis.getTicketByNumber('test') == null, 'ticket number não deveria ter sido retornado');
    }
}