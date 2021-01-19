@isTest
public class PhoneNumberReservationDTOTest {
    @isTest
    public static void mainTest() {
        PhoneNumberReservationDTO.TelephoneNumberReservationInfo phoneInfo = 
            new PhoneNumberReservationDTO.TelephoneNumberReservationInfo('0001', 'Preffix', 'Suffix', 1, 'kg', '11', '0001', '0001');
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations phoneReservation = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations(phoneInfo);
        
        PhoneNumberReservationDTO.PhoneNumber phoneNumber = 
            new PhoneNumberReservationDTO.PhoneNumber('11912341234');
        
        List<PhoneNumberReservationDTO.PhoneNumber> lstPhoneNumber = new List<PhoneNumberReservationDTO.PhoneNumber>();
        lstPhoneNumber.add(phoneNumber);
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneValue phoneValue = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneValue(lstPhoneNumber);
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo testPhoneInfo = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneInfo(phoneValue);
        
        String oneNumber = testPhoneInfo.getOneNumber();
    }
    
	@isTest
    public static void testBlanks() {
		PhoneNumberReservationDTO.TelephoneNumberReservationInfo phoneInfo = 
            new PhoneNumberReservationDTO.TelephoneNumberReservationInfo();
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations phoneReservation = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations();
        
        PhoneNumberReservationDTO.PhoneNumber phoneNumber = 
            new PhoneNumberReservationDTO.PhoneNumber();
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneValue phoneValue = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneValue();
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo testPhoneInfo = 
            new PhoneNumberReservationDTO.IntegrationTestTelephoneInfo();        
    }    
}