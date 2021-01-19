/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Data: 03/06/2019  [Sprint 8]
--- Description: Classe útil de mock de dados para classe de teste
-------------------------------------------------------------------------------------------------------*/
public class CEC_MockUtil 
{
    private CEC_MockUtil(){}

    public static CEC_MockProvider getInstance() {
        return new CEC_MockProvider();
    }
    
     public static Object createMock(Type typeToMock) {
        // Invoke the stub API and pass it our mock provider to create a 
        // mock class of typeToMock.
        return Test.createStub(typeToMock, CEC_MockUtil.getInstance());
    }
}