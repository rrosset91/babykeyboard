/*
* Autor: Diogo Braga - Deloitte
* Data: 21/10/19
* Descrição: CEC extesão + SQUAD PME: classe de teste
*/
@isTest
public class CEC_PME_OrderPathControllerTest {
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: cria registros no banco de teste
	*/
    @testSetup
    public static void testSetup() {
        CEC_OrderTriggerTest.builderOrder();
    }

    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa o fluxo principal da classe
	*/
    @isTest
    public static void main() {
        Object obj = CEC_PME_OrderPathController.getPath([SELECT Id FROM Order].Id);
        system.assert(obj != null, 'Path não retornado');
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa validação de id em branco
	*/
    @isTest
    public static void errorRecordIdBlank() {
        CEC_PME_PathUtil.Path path = (CEC_PME_PathUtil.Path) JSON.deserialize(CEC_PME_OrderPathController.getPath(''), CEC_PME_PathUtil.Path.class);            
        boolean erroPath = path.items.get(0).type == 'error';
        system.assert(erroPath, 'Não retornou um path de erro');
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa validação de id em errado
	*/
    @isTest
    public static void errorRecordIdInvalid() {
        CEC_PME_PathUtil.Path path = (CEC_PME_PathUtil.Path) JSON.deserialize(CEC_PME_OrderPathController.getPath('1'), CEC_PME_PathUtil.Path.class);            
        boolean erroPath = path.items.get(0).type == 'error';
        system.assert(erroPath, 'Não retornou um path de erro');
    }
}