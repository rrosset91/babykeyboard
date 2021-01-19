/*
* Autor: Diogo Braga - Deloitte
* Data: 21/10/19
* Descrição: CEC extesão + SQUAD PME: classe de teste
*/
@isTest
public class CEC_PME_PathUtilTest {

    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus não configurado
	*/
    @isTest 
    public static void notConfigStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        pathUtil.getPathByMicroStatus('test');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa builder de path de erro
	*/
    @isTest 
    public static void builderErrorPath() {
        CEC_PME_PathUtil.builderErrorPath('erro');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus inicial
	*/
    @isTest 
    public static void initialStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        CEC_PME_PathUtil.Path path = pathUtil.getPathByMicroStatus('Aguardando criação contrato');
        System.assert(path != null, 'Path não retornado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus perdido
	*/
    @isTest 
    public static void lostStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        CEC_PME_PathUtil.Path path = pathUtil.getPathByMicroStatus('Cancelado');
        System.assert(path != null, 'Path não retornado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus erro
	*/
    @isTest 
    public static void errorStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        CEC_PME_PathUtil.Path path = pathUtil.getPathByMicroStatus('Documentação Devolvida');
        System.assert(path != null, 'Path não retornado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus normal
	*/
    @isTest 
    public static void normalStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        CEC_PME_PathUtil.Path path = pathUtil.getPathByMicroStatus('Pré Analise da Documentação');
        System.assert(path != null, 'Path não retornado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: testa a busca de path com microstatus final
	*/
    @isTest 
    public static void finalStatus() {
        CEC_PME_PathUtil pathUtil = new CEC_PME_PathUtil('CEC_PME_OrderPath');
        CEC_PME_PathUtil.Path path = pathUtil.getPathByMicroStatus('Aprovado no Crédito');
        System.assert(path != null, 'Path não retornado');
    }
}