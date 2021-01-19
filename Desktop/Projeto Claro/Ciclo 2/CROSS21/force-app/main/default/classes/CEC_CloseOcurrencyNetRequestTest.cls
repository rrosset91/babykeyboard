@isTest
public class CEC_CloseOcurrencyNetRequestTest {
/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 13/10/2020  
* Autor: Squad Canais Criticos
* Hitts do Brasil
*/
    @isTest 
    public static void ocurrencyNetTest()
    {
        test.startTest();
          CEC_CloseOcurrencyNetRequest lOcurrency = new CEC_CloseOcurrencyNetRequest();
          lOcurrency.source = 'Claro';
          lOcurrency.userLogin = '';
          lOcurrency.resolution = new CEC_CloseOcurrencyNetRequest.Data();
        
          lOcurrency.resolution.id = '';
          lOcurrency.resolution.notes =  'Teste Hitss';
        test.stopTest();
        system.assert(lOcurrency.source == 'Claro');
    }
}