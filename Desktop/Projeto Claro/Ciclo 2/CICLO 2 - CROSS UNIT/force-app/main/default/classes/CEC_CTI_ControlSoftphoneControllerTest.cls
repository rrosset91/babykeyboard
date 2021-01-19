/*
* Autor: Diego Lima - Deloitte
* Data: 08/08/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [Classe utilizada para os testes da classe
CEC_CTI_ControlSoftphoneController]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 08/08/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e dos métodos parametersNull, decryptIsCPF e decryptIsCNPJ, decryptdocIsNull, 
* urlReturnedFieldsBlank, urlReturnedIncorrectFields, urlReturnedFieldsCompleted]
* ---------------------------------------------------------------
* Data: 30/08/2019
* Autor: Diego Lima - Deloitte
* Alterações: Alterações referentes as funcionalidades de transferência]
* ---------------------------------------------------------------
* Data: 25/09/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação do método createNewTask para o agendamento do softphone]
* ---------------------------------------------------------------
* Data: 17/10/2019
* Autor: Diego Lima - Deloitte
* Alterações: Mudança nos JSONS utilizados para os testes de descriptografia]
*----------------------------------------------------------------
* Data: 09/12/2019
* Autor: Diego Lima - Deloitte
* Alterações: Mudança nos JSONS para a Validação de Name <> do ID Salesforce]
*/
@isTest
public class CEC_CTI_ControlSoftphoneControllerTest {
	
    @testSetup
    static void makeData()
    {
        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.ContractReferenceNumber__c = 'Con/tratot123'; 
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert contrato;

        Account conta = new Account(Name = 'Account Test');
        conta.ExternalID__c = 'Conta123';
        insert conta;

        Contact contact = new Contact();
        contact.LastName = 'teste';
        contact.AccountId = conta.Id;
        contact.ContactType__c = 'Titular';
        insert contact;
    }
    
    @isTest
    static void decryptIsFIN(){
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WDH2IWAqpiboE65IedLM9oKbwymFyCGgeaswPYV+Xvj/0tu1sso0/kkf69RTNKInTIdKRfWNanEgK7VxFNKaf5DzltSCC5SclCXPQVhKBnsRcP6LG4+rSxHqqgsihXCeUiDP9HqxqKvNs1YJmf197hmvbPOEevrxakqvVSbwDyPBBTvXzBZ4BALQZof9atxdYofScFBC345N44AzoSv8mpW8GqG5TmC+yZQrTY+T72zBiGRSLxzj7EAckRquwa1co1duDs+ILz9wVLt4sBwnsa/97eGnEvCZfTSoo6FmGO8H0bVwLKzM0zUA274jqDDDcVj8CQ2MfWCDliLF86/ygj7UUhqRaN/K8T+IixOKoAYXuWlcsVnjDdxbbkoPrs0pE/JxZurILj3X7HYNFJJnDzD7lFQh9KWH2a+JxoRXvhqHcBceSD2JxJjwRNVa6uqbqhU88ubi+hv3MJsn8VLM42HpEdDcIDjiFPZqxRgTfhRRpwMzc7toJbbpvohilrhyqvfkevJ3C0NhYZV4RhGyC0irNIBjjo4AHUikr5fX/tqVBTpFK9Lc7yegzeiZQycCy8xDf4tt9lBYvYnI95ilHKfNHQZUUL48zfC/3l8Vh23QtlI7BjNjk6R+UepFp3mLlaRbBuj7HusL3TeH5qZQMNa6I41QywGpxZYblIos2Aqf8Oy3MTh0sEX2yb5zqlA6Wi5zW36j5xuU1bPv/+rSM+GgBe6GZmwZzlbY3STAYu6LDSrVtvdjpRwi797g+v68KMRbSSjspyLjYDFZ7Z0ub6UjjyOZiLreYMTSfUUqjVSJF118xZMu1PdZKsFnyadTRLyjsg6hjV7Dej8GhoJLYrq5UMz2XCqr6OS4aaKCTyCtDHWcX+PdndJ/ysRk3YuFlH6+wfInGBy+RYvdE0Pc4pHQNMdgSq7VUrEwR/ghBpRyOxQCLCnkzgbhRb3IjXblfCR2zldY7bKagxzzHKzzpICAD4UiixTUHOmMxJNqRDpOXFad78yGzMtJQLHlWIihLI0TDJVc3PbTZy1y3PVhN2pbEE4YmWfMz03ExH4vujDOvoQ8E47X5J9hAT8yrP4HNDrSwWq2qAQ6l/thOEnHtsg+eWjxhUudv125PScRpddi9XnNI9hsYrzw60OMmILoD/gU+tkYX8HF/8xqE3u/RFLPAHoMFbYD6FU8sTsAipV4l9x7I/iVJpia6heoOkK92cEgqOs6kJ1wwzfyAwDioV3Bd05qSbNVOZwX8EXOBcyRgXPYi7kn9uCduYXr/98qGUuKJ5dT67CUeQw2Xj1vHBb8o4ht+YIxuYPQFZkDeUYDqyQOU9BEFpJjHEgA4JtKjtYZzwady1PnXXd0QfHMQBobWWf1YlE13eHuD2+rb4c0diH4THRPrU5gvte3gKw1KhE4tDaLlj1gWusS6Nr9rDOtZn3gfi+zCR5fGUpeIM7VC80otPVNTxsMyMHiNzh1kqfiPomwcHOH+n8fKX13CEIF+L1IWKzh1kfJFBbXd6V/bqCe9LIUDzceUULve+J17HpCdOU9UKTYfqQDSVqCewdX4eeWAYyIEFLzYO6kNVjc5iUHTRobyy37qwNsEAN/VDOxuTWwkCX03u3FpT4xTsE/rQiBXkbPMMNMraPmgIxQlesnxnig7hgEDbFgpPIcgQz6g11YDhYEP0U5UiVCVTaKA3uSiGSY4+Uj0aHWGLM9ATE7Dx22TDspFOA9CaCuQ4b/rExTf9+N70XQFM1rYjpOvzSFRklIVnXuBP/6JcW1dKPggPHSk749qdROFXXMfE=';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();   
        System.assertEquals(true, wrapperTest.urlReturned.contains('Case'));     
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método parametersNull 
    * envia como parâmetro as variáveis numRamal, siteId]
    */
    @isTest
    static void parametersNull(){
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        String numRamal = '';
        String siteId = '';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.checkRamal(numRamal, siteId);
        Test.stopTest();   
        System.assertEquals('Nenhum erro ao atualizar os valores', wrapperTest.mensagemErro);     
    }
    
    
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método decryptIsCPF 
    * envia a string criptografada com um CPF]
    */
    @isTest
    static void decryptIsCPF(){
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = '+dG/meI6bV4aF+lJOH76c2VCd2EZrxJnCjfLO7iuhvCjKwZGIPp2oH++2JLBtH/blAtquKA3fZrBFDR4c8V2ZhDPkqO17lttXOUyTQ3n19rFe/a5JLsGNJP70VuiBpDx1K+UKTUcQdnf/LW7kZYPe2unC48nPOeFzKfI8NwgyoEK1pmtBtN7lBBFg7tNoZgjM/k/mwE++3kgky7Wm6qIyFz8sEnt3Pl9gJRPxInMCwlkh1exQQLkccMPDXmIPytDQO8Fyc+PuB0HyjIkMktAZquWoNXtUZWnBnkrgtFlGgrntG1tdGvIdueMuMB/QcG6W/HxRpMhYrTZiSlBiyujlbQvCgvOmmAGier3FcuMOYS93zl2h3wO7Z3V/FXFlqte8/PiuaWW1tceNmWnx0psB6v4Z4G+7kh2ZLVbUOkbTRvC1V1KVuHkOSUJ8ehn9M9/FSRZqTs9cg6S66csQo9Y+zhVAL610ZBJ4T2jsvLX1zABNXXC4fmjr8J59pLlzFAmrOGsuWL7aJqYickP0lpSdsKA/lDvoPhA76/ufByM5CGWJj21TOMjQDWrQEFw7Rxl6XqlI9cBai5UMfI9ryeA4H35OUJ7ylEkTWe8k7a7Nnv/Toj/dYr5Nc4Go031b3FjB2D5isya85ZqJ/Wjp7Jgb1LohwTHoty0RT2tjzSwKZ/mBef8sna/qmxkYWt1fAoh';
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WBsmUAhtXRUq/LZtBsLuPnjFXoknZ1+wOn5DVBX4ibmB+H72nepb4+DdYP74Qg9W31sx0cdfCr1Pc/dmRxlnhqzkFYudwPuyyES60RpFv3IBt0BtDtbDTZvRNY8BM6wnV0DEwGcsaklM22e0UmH7a88f77JBHqg0Kf3Nc1qg4l9HzMHgYmHfo5FvhN9SW+kICBYcNEhnsZfAE5pysja2GgUT9W+0fQ/Lb/5XV0Jiyq3FIE7rKq5TdTV1XJMDcBy3PXlzsEUc/0mfgqaNOPmB9PMosnnIcGzuTHT+gN9NOKRHCVj8gD7pIeTA0DCcP+WaIZhjVxzhZr8gPSY7kiHV9s0wHjZhk9X7IDVrciME62jro2w+lPZ6TF7WlOSlRlLAQ9PQ6AbbkQ0rCxBrBJN1M1fPwo0Jk2Iv+OGrhk4TLvjQjpyxG9ZxQhr3u48arcV/KUqcIrL/lfZgCV8A6aXyU40lGhri8cM8vw/yCvcbPWkGoFts96xJuoZvWpCWE5ROvrGaOxttUqa/hznQ58nUK1/lulFXwh2ZYiKgokmFIa7CODknOEY7mgpBFLmU0VvWnKZvs2/r6zlzMjLnhafNlr+LU776Fv/m7kf0jGiBWbUQNGOAqDH911snaydj9WeMutNWBBw8LCTkv3D5N5tj08MWSDDgC6fH0YotsRKyvZcJ9HdkCkJZrkpPNkMC6rmWCAXz4YpqiT6B/KV9IJql0NCE6DGlEHhN3HuIGoIyRsuR9hFz22bdsomMcMNF+rW1UqtGo0wbEzoWkpa1zfhJ4MzAbbOuuHaJThxpv3bUYgk+IeQK5i/LkPJAile81Enq6f/B8TO1wndL0xJONUjzvipA2sw39cJkvZ91NTS5ww9dz0qTQxiN5zql0/hohx4DmGaqaVi2vPZ3ad6l/WIZfwAhy8OAXSMjXyzeY9Tl6Y3+U9UdmuTKrrGmujSBdhr6bKX7mVu5RG3/os7GguwManm5eMmh3TSq22Z9SLKNc71KEACo3N88iBd9AVIRMf6ZYLGmbT4toXGAQOx+HnBD3/2eXECbPCPj37S2WOzkcoOWlTM39CTB+HG7euqkQuNoTFaeMZdswv+apIJkjUa3Jtkmc9nkSY4QTtU2lEVjLzPvv2WqUUfvyv9nmaMYcmSFMVf39Y3tHPQDgHt3CASJhO8F9e7/GcRXKB4TZoovhsuvB4Yxr/vSEVemdFLnNjTHk7wqTriUlCcMlXn6nx9ba+MrXWfXtUJpOX/xRSNaDV4H4VO2OffZ3cfFcbY2b5hta9QPHxgRcdBUSTWJThHqtNzyUalMHdNe5bzyt3fH2U9yq6Cn1SjQQdY/8rOy8YxhPCwQ5J5cjOsW+K6ZzNFVWwEYlGzi+ed2ejuVhOrK+U/eRapCJSuqxINhyVVYmjgPlFUxqHYR2ZUKfuwe21TpYUpTRvvKN3cq2vmoTt1qfKDfO9oZdHODAH5EW60AXY7E7CU3TiVoNQF7B5NbKSP1kHPYWqXjoX6FU7R/IdW9gwfyPv1yIBixt1bgfSVne4PgB7iM7NmkEw43fRY3ybafGA9Ui3oemdp+4YB14ngWtetNsmWEdAh2IAVfqe5UJ/r8K5zM61UybadnKXT+lfkUoUgcUBC43rXP30ZoWDYa8yzenihUuLflzc3IAITVF52pqQ/97OX3s8R79H5553pVuy5NpH6MSgKUxwzaPI7gd/yofxKBjzC2Wpj1s6J1k0nFCZF6algPXBadkFykyBSurZkcwQDAGat5CQaDT48FdaqQ52PAjroBvmBnQgOxZ3x564An1wT2dbxXEwaC3KLv73x';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();   
        System.assertEquals(true, wrapperTest.docIsCPF);     
       
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método decryptIsCNPJ 
    * envia a string criptografada com um CNPJ]
    */
    @isTest
    static void decryptIsCNPJ(){
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = '+dG/meI6bV4aF+lJOH76c2VCd2EZrxJnCjfLO7iuhvCjKwZGIPp2oH++2JLBtH/blAtquKA3fZrBFDR4c8V2ZhDPkqO17lttXOUyTQ3n19rFe/a5JLsGNJP70VuiBpDx1K+UKTUcQdnf/LW7kZYPe2unC48nPOeFzKfI8NwgyoEK1pmtBtN7lBBFg7tNoZgjM/k/mwE++3kgky7Wm6qIyFz8sEnt3Pl9gJRPxInMCwlkh1exQQLkccMPDXmIPytDQO8Fyc+PuB0HyjIkMktAZquWoNXtUZWnBnkrgtFlGgrntG1tdGvIdueMuMB/QcG6W/HxRpMhYrTZiSlBiyujlbQvCgvOmmAGier3FcuMOYS93zl2h3wO7Z3V/FXFlqte8/PiuaWW1tceNmWnx0psB6v4Z4G+7kh2ZLVbUOkbTRvC1V1KVuHkOSUJ8ehn9M9/FSRZqTs9cg6S66csQo9Y+zhVAL610ZBJ4T2jsvLX1zABNXXC4fmjr8J59pLlzFAmEcUpdslM8jnsUlNa32ZEwQ5dUNQMXd3+56twpuL6Lr+SnGGeeBP4RVUBYbMlmroF3X5BPDXzClOx3nbgnpnwZYtQW/39A6+D22nKajw2WiovxTaN35a3PzIZZ9GI4nk+Ckc0YvzyrHIlxj6Pet1ArYIaPwO0G5+MwzQ5IpEHwPFLVb86rw7zr+tKnoekWraq';
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WBsmUAhtXRUq/LZtBsLuPnjFXoknZ1+wOn5DVBX4ibmB+H72nepb4+DdYP74Qg9W31sx0cdfCr1Pc/dmRxlnhqzkFYudwPuyyES60RpFv3IBt0BtDtbDTZvRNY8BM6wnV0DEwGcsaklM22e0UmH7a88f77JBHqg0Kf3Nc1qg4l9HzMHgYmHfo5FvhN9SW+kICBYcNEhnsZfAE5pysja2GgUT9W+0fQ/Lb/5XV0Jiyq3FIE7rKq5TdTV1XJMDcBy3PXlzsEUc/0mfgqaNOPmB9PMosnnIcGzuTHT+gN9NOKRHCVj8gD7pIeTA0DCcP+WaIZhjVxzhZr8gPSY7kiHV9s0wHjZhk9X7IDVrciME62jro2w+lPZ6TF7WlOSlRlLAQ9PQ6AbbkQ0rCxBrBJN1M1fPwo0Jk2Iv+OGrhk4TLvjQpcUNhDDheQMN1LYTACqYvHWDh3ODfISZaQ3BoH6AhzlDTPgT/2HKn0nSLeSX1CBIRT5C4v76ONLyU9ukfBBWlp0vazcmdlbH3NJ1Xt8Ib4WO1D0WCjtDlyU51XdifrJzC448KlWU2hgY0lwENr6CH6QOA7R7SHmvkXuwpEQeJNe2jh3Ake7ckPBDLEHmoI2zh98lXnvPYjX8XfAV7jp3aBuoR8Lm4DgLyCNahzdZmwgQ5kOzcDStP3EOxK4qbQuvUEKMovtQMFsAR1kaCrED6mZoHnHvyMe3JtVzUn1e0V2YNW5T5ul7AWvEw0BhV1u0WEadlrxY5EzIfZoZF26nqM+qz+ROrZ+VFXbjh7naI8wI6E1b3NkzMKtmb+jYZfb9yKlA2EsGRZVU8A6rXR3QdIE3K1cl0izTqIRxFbNUvDfsQOF2DhHUt07ojOI5uHeuQiwRHeWqQeScUW5dwvGtpyd9GRnkldgk3CkIxgfnSpzV9dPA+0VGzN/maZlGzEnhI/f1I9PXZ9Tplhf1c47TeCBWrCgXuKo0sKGl3BRHBjaDdA9mrXxCsfQBoFihVebH0PoWjvXyCu0iVqdFFoeXQhnQEBQSD5Pmtnh/WX80TsykCaC4uhD/prGsvhwCtxYFBJztCip91jJPXVXobqH2qBDmdZ5KX1Ur46ocE82kMuCVYa2dyTax+ERABzuTJgIPmPHBmfOZZMWH8r+IQeeqlCKFxwpnegVNr1mjzz7F3jPok4m+v6gijkD4p5Zpv2L2lRCjcLwr0KbLWZ1/ukaUI34HbjYqgSd9UGvcxB75KtnFHuSL3mWtuBOfeXnQcXDiwaxS6TWOHYGF4D7fBs/thwq5Jk9+lu5tWPXhZlMsM2V76buCkIgqkJHPC/uHjnIcfih//C/6CZgbudBEK15dG+E1lf/rAcvnD5HluSnX+jzgUeQWpcKHxOpXIRSQlfTU9iIdBCSeuWuh0w0GXL+BjZLkC5k+RwFrpeDI8+Vads4FOMDagwg7hDtMVpL2v1WhvRvp4c26BYQe3mhLzwt97xSouxG0JMYO1+9Hv4/17mtuN9rBh0sqRQ4ik9DJSz0umIcjGrrhqrveOzuk7xcgtzRsyaLLODHlsWmClqY3LYufRA5Nul34Ug8J1dG3FpmbS2JH7d5j2OmS3PZu2q8BYJD+ReV7HkSLHP48nve+60xBk14WXvfPAnnL0u72gBGEb7YEs1T6VCstY2uGh8mxLzyBOwsXAvWhUPoqE8e/SGH9ygWdIH7Gkq67lgB2q6KgYnsC0GLOIaVSNJTWZ8A+YGIW+s9lKjTskIFuH6kd218+wsI74CZCWap2FdUp+7T5CEZlpET15g04KVnpHl5SeW7ozTDIy7T/w6nKGhav6e8';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();
        System.assertEquals(false, wrapperTest.docIsCPF);     
        
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método decryptdocIsNull 
    * envia a string criptografada sem o documento]
    */
    @isTest
    static void decryptdocIsNull(){
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = '+dG/meI6bV4aF+lJOH76c2VCd2EZrxJnCjfLO7iuhvCjKwZGIPp2oH++2JLBtH/blAtquKA3fZrBFDR4c8V2ZhDPkqO17lttXOUyTQ3n19rFe/a5JLsGNJP70VuiBpDx1K+UKTUcQdnf/LW7kZYPe2unC48nPOeFzKfI8NwgyoEK1pmtBtN7lBBFg7tNoZgjM/k/mwE++3kgky7Wm6qIyFz8sEnt3Pl9gJRPxInMCwlkh1exQQLkccMPDXmIPytDQO8Fyc+PuB0HyjIkMktAZquWoNXtUZWnBnkrgtFlGgrntG1tdGvIdueMuMB/QcG6W/HxRpMhYrTZiSlBiyujlbQvCgvOmmAGier3FcuMOYS93zl2h3wO7Z3V/FXFlqte8/PiuaWW1tceNmWnx0psB6v4Z4G+7kh2ZLVbUOkbTRvC1V1KVuHkOSUJ8ehn9M9/FSRZqTs9cg6S66csQo9Y+zhVAL610ZBJ4T2jsvLX1zABNXXC4fmjr8J59pLlzFAmrg6cRUDJlDMXngZ8TbIwmZwYlRmemnWLQA/VFCzU/WSk8/6HiAH3jcsbUHB/x3wfyGXU9gOysmPrF9mayVD+ZGo+RZqQfYkeDycWdAxEokDIvATMIDjBk+rQ2MMc4CPVccahQRJ1X7CgvIToCPCgCvQyIqmmRB+nA1ADGV15EAU=';
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WBsmUAhtXRUq/LZtBsLuPnjFXoknZ1+wOn5DVBX4ibmB+H72nepb4+DdYP74Qg9W31sx0cdfCr1Pc/dmRxlnhqzkFYudwPuyyES60RpFv3IBt0BtDtbDTZvRNY8BM6wnV0DEwGcsaklM22e0UmH7a88f77JBHqg0Kf3Nc1qg4l9HzMHgYmHfo5FvhN9SW+kICBYcNEhnsZfAE5pysja2GgUT9W+0fQ/Lb/5XV0Jiyq3FIE7rKq5TdTV1XJMDcBy3PXlzsEUc/0mfgqaNOPmB9PMosnnIcGzuTHT+gN9NOKRHCVj8gD7pIeTA0DCcP+WaIZhjVxzhZr8gPSY7kiHV9s0wHjZhk9X7IDVrciME62jro2w+lPZ6TF7WlOSlRlLAQ9PQ6AbbkQ0rCxBrBJN1M1fPwo0Jk2Iv+OGrhk4TLvjQnoCcjgJ3N+IEgoSa/ZBpIEels9twSLIc05HbdotO+iPxeabvqMoGnSw4RvdNqLPwBMURCnmv9/5sXHlWYry1KI0xbWYcXnTmym/3fNoV6AscySFYwyNP4Nf+H3OFLhL0zjYkvvX8afkqDZaiRgAi4EHRNBF+5GqXGRL0BpClSSL5Xd0oKa+1VT0YfTYJhqb2SEfUfRi6RySBZQjyXLyMJY3L8LW+Em9vevHPJ+4fydIAcA1mlrEAI8nBkROW2G4ayB+wV8E8sjV15ez34LIL4v0ahytrRjT4Kg8FwCU1uIY2r5XpQHOtyz29ZwYL1/tw1HYVsoSPK5t484DmjoJyg6+tqpfDmxcbYymWm0XO8ypDijvy3Y3PtSqSGNDRpACI7BgN5EepLcbCL6O6HLYTMGjOw4i5VT/AfJ9eGACA9pTpAtYbgBSOuG8tcJ+vJ/ER69OC5oTyf3VXIx954uS2Dicks/KVlyqXr/pEqkQ41vYgGyoFZ+MgSOn4V6uEwf4S4FV7BUoNDao41wiAQBvhobXsMnCy9r0kKVDaZ9awxhmb6WTcZLJgf1vpislF/ft0FhRzUWff6gwv/Nt1A5xpXRBux/5SWcn6qhrdc0kZrRCZ82jwh+c/ScDMH+8NFXGGwCuTqn74bgND2lT5LgHriJpd2Pk7u2r2TcMa+XTw3WKoSqG0GjL5y7YfIIFPiDyV/waaeZSyNhCU9GHQcVCmBJto0f5997nlLEs8j6aGrYY7cV+FbhD76RSyouQKMz63aqrs+Pv/XDYh3XaBdbLXdaXdvEQhV/Nsv7N16HUMecWnL7hrZbBHPUfdTUrYE5mC/J9jLVT2qLuDi/h3AqiPRnziv7N49xRJeuIDH/l8ykvAplA0yXXd0+Qym0D0/CdQOSQKs/nPHHcTz4nXpL+inC/5AsCoXmbKu+Nsm2KTvs46kK3upfHOVWdeX30SEqXO6f8jTkL1w4xVfBCSGp2jUiTJLs/lT/OydkLBtUnxnSoJS+iAypvAmzJIu1f2YHaEIeD8j3GI3wrjManSdNaiSOOAYp7nOEWxlixCZ4BgaOF7A8fjYh2kIzQoWPC59rwELcAsVa9zhzD5aNWXJLsSMlxdb/CVF706hvEqH4vXREKfpUo9KVkAUg7Lx0aQBqD5POr45QiMu5hYD/egJenSsrCKp9sJzZErHVYv956UHgUUtuvvvB/A3i9po+4sHEp7af6TeEMlQCx10/Hg+mAV/nfoZ66izG/uhCnvh67jRQ02E7AfIvo1NJ6d3LTQxzd57BZWaQO2JEiHmZYDjGHCFzjg9ofaBofFKFRERE55sE7PhZh+H8hoHv6eNn6jqtgqMhsNyawo1z4Vn1ynJzscvI=';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();
        System.assertEquals(true, wrapperTest.docIsNull);     
        
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método urlReturnedFieldsBlank 
    * envia os campos para busca do cliente em branco]
    * 
    * Depreciado por: Leandro Cubas - Deloitte 19/06/2020
    * Descrição: [Nome do projeto/ID: SOLAR FASE 2] + [Time: SQUAD CTI] + [O método urlReturnedFieldsBlank 
    * não faz mais esse teste porque não temos mais casos em que retornamos uma url vazia.
    */
    /*
    @isTest
    static void urlReturnedFieldsBlank(){
        
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = 'wpOAnkk6rCApm9o5lgD1T/Lm7PKYD2fcjBYJ4Q4Hfcrroi7ETtAIyJPlO4oPbl5IGgjnGX0R9DuEikmzprpJNAmMtZE6Ptu8/V80qnN85hZ/lRfyEU0ioPkz1HzQ1ch1SwtJ4npPojEQPpKRT4LqxDbVYErJ9WOLInfvJOB8eMT7gmDIVOlGf5z9jfvuCIfoESKDG2YGX72bZsu33O+/XybBqD8iJFMDgfyMBWhi7o27KNtgISYoWQ2MCrtYSPzVtGIUNUZkdt6NFnhg8OqARryeR7arudZCaIN4mT0zWlm+uNEbi5T2ql3iYQTyDSCzkcjn0RL8mSyJcCRF7OV+w1TPVnFx+r1pcHog4ygpN80Ikq1WoCOfWE4q60wV49PHUzS5eJJY1UImE+qGMVx+eF/ZNKuuM1MZic0kCRu69tHSuFTJtRPC0QEnS2rLu4BahyQ4zJahv1VsrYld9ZOOZNO9B/uaAqHaGWnmgldqPkHBkUWyyj5GXf3LjNARUnWSwedrmFZE0Pwb6t9tNKommP9OZtUI+cg8IdMJY+xOKloXhwJ0nroM6IjViDnR7IY/n5RPiUIH8AFiMpLsAdFbxS2AZnjxCeWwFW/BLqMP40iW5wmUCpkw3Y37XnicwQxPcT2ir2196Zl4RrKMToyq6Q==';
		String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WC91bBZ26vBVsN0ggZ92is1YVH6Mblp+Ru785G4C8913iWl2W/B46/UBd0Ct/Wkk52qhxrxOVLRD9ULRaBFAqlFdMQWafylrLtLvqZlSPAACwdSi5AFMbOkc5bias/acGojBcHuKUVctBVZCf1n6zKUEu0Esptji3Rk1gDhJsT00C5ZUbjFndywP8iGVzV9KMvcbT+q9UoLEaEZJWJAqrDI/CAB0j6EWot0ZTZC+TSLIRZD9ZyYSBEK7UiU2rAFRIw8dy6JQpteUJc30JrOmTA1wKewGKFZvVgrG8Zrpf0jKE8VooLVZPc8E0LtPyqBrNrQcp8qoTOSWRDsn3SCAyipa9aHMLEyUooC9oYTC1VxTyUelbbvcb3F6PpCp5EtOyNLFiRYoSkqzy3Kib1Si1KWieoIc7OuZFFg2wVv8APsodvAdb+hw/vRhbC/eLrPNbAYrlhQF40QClPb0QteerKdScL4aYveIdr/7lWfBMFPOsgcAxNFWLFntkOG+9h/vtT7qBjE3afOEdDlUVlrex6UYnCQx0yA7hfH0JfpBxY/DeiBAGc7Ocpy3xVP9wGuMAasKMc6vHcSoM8LLPWDXrv+7LeoDch8HHZM5Lxg96B0v87wLrmJnqTkAv40EBF6u1+UlHbcOFxWmXVi+Nx38Uuh/VrxvsoUWbsSnZspA+i+5m7jKUDnrAAphwKxmuyDcW0nAH8vqpYadIShxBTRPyz/hnqhVddYS3VsEYT7WjTFbSiUzBbLgr+XIOYcSYC0gFDGbkh5dN3LxjoPmcaj6ZwRNM5z2PnkMryFWcVZ2JoQA4JA5/QPz3zadpZvHTgiZ2Cs/pmFrgvHP7RY0lgSSP4xBBnB1pykojH9yk2rrj4/IASsupGH4U7vJIHLTfhYY+1l6pK/KvZkakeqJOPnbbW7aEhBFVMwhYSE0qjWToeYrqWDfgIJuZ93/qQ1YNRl9ZGMuZsVy6KDLMXvYlqd9bcFBkQ3iB/rhHFKzXGcTURgbOiwnsnsjA6QQ1V+OFVw1UtVHXXv/k4MGKqzMdUn+le1PATEFZmu3X42J08/4EIyLugPhIOeDAePFAILFbhAal1MxamScQOj8h5e9R7Se8U+0NKQUW/Ni61VVw0kPjh4gccwwFRgHdztfTD4R+Ihw5Uoi8LTorAxvByWuadsnbxqfcPvteBTSw+CXxleInyFX8aUDoB2Aj0SaK1FT1S+TV9s0MGgslGdZTymnm8bdbotCjXU+QBGeHc6Vmqllt90XnyH2VsPZZSuwFSVv76JpLJNZ3iDA+V7IeqrdPMV/+KKMiCobdsNtSB7NR5NlGjrgXhVRIhhXXneLB4Lh8AWveA7D7peuKEKCjvQl2dwC+M2GTrrQVCfvbHWx/FAXLBF4varwj6Qce9SbM2l9qsFSc0m0j5sDvKImqfyQnn4l3kWG+jL0qkpuyl/PZUQRTNe4C9ncNnZm1ZfyYjojc7pMl7meizUYvCvj+3cA8xjt1UxXGCsyEP4yZOzHrTKgQDlTPNc4KtNVWrZLVn1a7dyjdMCD1YEsoJTlV+srcUI3+/66UzO92UaX+Ejb34yqAzNE2mAfMH2yT3eIgtyyNUwob4vXrTRpkuy6RyNrnoYgG4YIIbfOAiahWVWAD6Zr19w4qQHRWRdd0yxEWuh5z9pMNo=';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();
        System.assertEquals('', wrapperTest.urlReturned);     
        
    }*/
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método urlReturnedIncorrectFields 
    * envia os campos para busca do cliente preenchidos]
    * 
    * Depreciado por: Leandro Cubas - Deloitte 19/06/2020
    * Descrição: [Nome do projeto/ID: SOLAR FASE 2] + [Time: SQUAD CTI] + [O método urlReturnedIncorrectFields 
    * não faz mais esse teste porque não temos mais casos em que retornamos uma url vazia.
    */
    /*
    @isTest
    static void urlReturnedIncorrectFields(){
        
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = 'wpOAnkk6rCApm9o5lgD1T/Lm7PKYD2fcjBYJ4Q4Hfcq98jxCXflLgv+u+Zx+C+HxpUIYrs0GyMzGxCqt/HyE9YeqDLOS9+ilUsrwk2YHXxpj/dGGDmpeNVmMIAw3iLJwVtICplBIh69/UWyU7y8AdrgpPElVdaS1CoboYVGEnIR1K1Br5WoqUeeZMwf49HDnnje2VKLZQbG5w0GXNoRo/2DTepCZHMGcifrxnl34ObAoDTA8R+aZZXSWoaJpBvt3TI+djYDeuoJY9k9iqLfhA+4g2Eysp9r/mK+kglnOKfUN4Bv+h0G2H2RYRtBTWNkrTR5y54pppGUtFis5drTKvC/n75EoZkpKgzk+ceGzohn+iHU14EmF4hOcpUDcn2PlMsJTk6PRUhl43jV8VBVvIVk58qbei49cZ7A+uw4ZwkU7ns92iEEwFjnOXfws2KvogJyhtz0qHJebkfGAruJ0agXqsl291hQbtZ4etVU7lxhjhIXoZSuixGZSXJYhNb+FJpzmxxuM+zHl7mLvWYJmgNM1F9vh/ecGRhocHLtN3QLGrFNh4Rc/mIocuuymFDCnSD5ErqhBb31sRya/N5jw2xvEA9+//WMSwstWWJEj5kaqgtYcBNC4UUK2RjqWVjB+blD3mZmY+qJk5YDRK78UN4vOYIFEucf1WTyyJKFUr6ctRTn1krevedIP19lNxB9wVZVhFKY145hxxF/BxmvzkiWC4KFfuo41KnxWXv7EJFQ=';
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WAplSa3riDkn1nf6bs1ds84t5bPMj8pP1zsrKwPV5FNLK96IeDQsHHG6ycpdU8QE6BtZBOppQgGk7LQDXVa4MkumH0HSNkVZP2KCSxuW397a3WWdzJO+f7c5+IfQRj+Vvse7cCf6xQGx1LU8TzT0kXBd5quroTZhtFfasz8+kc/xEt4Av8nh+i6tO4gtJZmaCVXD4DNqV38wBz0/wqvEVMGet/AjLJRXo4FFbKxmFbq2X8soyzFAWVgoyHfFIKss++qARMGwvxElBPU/pLcSQNkKajnkQ/JSc8eQTR8iX4PZSH7zT+T5sbmf6H14nmTBaw9KDOUjETRjun4aqjdIQFsaLVaQ1yOfFJfdT+7DhNNNS1KrnWBl/H7jux0M9isj/qnX6aCllVokLrrkTmYWXpPp0G7ZfqEqv5wJdO/6jee7lgkqd8VYz10Gt6cj7gdz0uwrXWAogO/z+2XFZGXUTsNDIj6XfctyLRZlrvFvVJRSNz1It2wL1WcoFxb6mNVoY0dhVT6XKJ+9Nc6d3wOA4Ij8179ERNpdnxDvF9N5ocWHlEZcu7XFz+DA6/PIGMzrfKdxJgasXI/XYCaFDTxsoQedE3X5HZU8T1k8NhZJFL5VWskeHNfYBzFpOY7ke0RLd1PPFNAWUWMp+VSJXtDNfkmKyTO75v7LhP1HNgvZfQpAIeh3/xk5Mi1gqI5MuqOTBKlm3HS+po6IKt6GYOGot2AlP2ooPw0eytK2a9V+t09JLSkTF4LCYH4PMciadk1gCsUiCejBzZ9dgewacRRAYnnpfY4OmjiEPFQ/faa4Pju9udIq0WtvZl9cg+zStj/jIi150upOC1rXlFUUUO4Qnn4KpDPForIj7u3A9M07SKtI5fLLKW1q8bkTlaSos/M7dypUCy01m6P618x3SjD3q/L5HrelnayoJBzEin1Mh58fl+9W7M5X/7nFTM+DCEKoe90V5j5+4glRFGklbj/UwU+CwJjjYXvp3u8GwRFYo1S42TrR1+9PvHGHQTZmxhmYc/7A8KJ190dOCgAnW1U7fNcgOwMGGsjS05YjAo1wqiKAxSyjEctPeoYP3N7Q7IEysybVirhBY97BWnOhnH8qsm5zx4Lek313515gvD0bxS6mAOB/dpHhPchDancschc0Wz6ZNjCrxpGXAAeELotxClRQo6T7KPtRw/8rav+U5BkX8SObnQU2Osubp6APexOgGkGakAp+HcNTPIl0cj3b8Q8pOBAxa0fqvvixUbAfsCJAG2rfY7jOfSPS+boSehBSECydConpUcjLokKybFjTdj3Q7zgKpq2lZ92aV1cCqf1VlPJSWHpu/Fjmgdzp9BsP0qtQqard1TL/acBm3sIl7sMQlG0dMKVAq3tAIxDQ0+k1sXBRJ7NdHEb+rILRrMTH6A4sF7BMpYLX/a/fU+yLALsP8Dsp50VJNPJSHx4EkhfoODsQV2w19971nAecqptG36/e33Vg/cdMTT384f5DxrV5r74EJz5VuWgFD2As6fznxo9JeFT5lM6XrAE7i6PK3giw99BC1X55auHI4lcvYcokJotAfPRMIzzwIJ20C7WXO4AH6NwAtaUpW5TF0CpS6f1sC2tId3T3mw+G1t6GTahqQznjboigdcVFk7TsdcDAhPC94rDuJC8ntE5Sq1lixiBNr+JbK2C9qSEl8z1r3LgtmwQ2lfiDRxOToVYpxpp0hkAEZABBX5K1OE16H1IveNQbl2qIcfuBDWrhhjcdc6Z/hmJ1lhnuRnJqI8oBGlO+w==';
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();
        System.assertEquals('', wrapperTest.urlReturned);     
        
    }*/
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [O método urlReturnedFieldsCompleted 
    * envia os campos para busca do cliente preenchidos]
    */
    @isTest
    static void urlReturnedFieldsCompleted(){
        
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = 'wpOAnkk6rCApm9o5lgD1T/Lm7PKYD2fcjBYJ4Q4Hfcq98jxCXflLgv+u+Zx+C+HxpUIYrs0GyMzGxCqt/HyE9YeqDLOS9+ilUsrwk2YHXxpj/dGGDmpeNVmMIAw3iLJwVtICplBIh69/UWyU7y8AdrgpPElVdaS1CoboYVGEnIR1K1Br5WoqUeeZMwf49HDnnje2VKLZQbG5w0GXNoRo/2DTepCZHMGcifrxnl34ObAe6A/0TEkiEGoeCPrXns+sq738Dk3pZbQb1m6PANyncnWSaE+O5TY0qq3HmMAr+/W4adLy9nj8379FXHBCPlolhT9/EQcT4J6tOiWwxd23ptDDFXZK2/w/jAA+j4ZKB+janIvLn4bSGufP033XjI25gNNnC/EYIkvxr9JDN1ou+aotqcxW3yB3pZcj2DdxNTLa70/eVONq4l/5/4KBtr32F9a2nZtJ7iREy4jXGon+F7pZQ7Ecp237NDG+YVaFbrbcN3DfQjzfBqiqSyjg4Zo6hvzkAohxXJ0UewDvVkFGesReH6WMEP1Fe2qfBv3Gc0z3vpYr26fRhIbh3NYe9wj5r0fhDB2/VLX6nsvF0E4dEVoCSUaEDIgQslpUHTdHpygg4GZXv6izzlcx2QyeXsvQ36t4IyPean/KusHIoOk455f4AVJ3VweRiF4gzoP5SCStC4jOKQwKcFpYdnAg7QQRZx8jC8xKlGifzr/r/EKWs1swjxPlxhn+d+VmopZzlsw=';
		String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WAplSa3riDkn1nf6bs1ds84t5bPMj8pP1zsrKwPV5FNLK96IeDQsHHG6ycpdU8QE6BtZBOppQgGk7LQDXVa4MkumH0HSNkVZP2KCSxuW397a3WWdzJO+f7c5+IfQRj+Vvse7cCf6xQGx1LU8TzT0kXBd5quroTZhtFfasz8+kc/xEt4Av8nh+i6tO4gtJZmaCVXD4DNqV38wBz0/wqvEVMGet/AjLJRXo4FFbKxmFbq2X8soyzFAWVgoyHfFIKss++qARMGwvxElBPU/pLcSQNkKajnkQ/JSc8eQTR8iX4PZSH7zT+T5sbmf6H14nmTBaw9KDOUjETRjun4aqjdIQFsaLVaQ1yOfFJfdT+7DhNNNS1KrnWBl/H7jux0M9isj/qnX6aCllVokLrrkTmYWXpPp0G7ZfqEqv5wJdO/6jee7lgkqd8VYz10Gt6cj7gdz0uwrXWAogO/z+2XFZGXUTsNDIj6XfctyLRZlrvFvVJRSFMrTPouqVyH7PdpIOtgTbdaH1QHsrUUSVzqD10MXqkDG0fF10DlmxN0pEC7tPzjYW50tVOiX8k/JQAxc/Jsy6aeVDG0Kpubkjdnt3cesCJRRqJ41Ng0jGb1USezDRkIRipdUNkwL8qNDUKj68j9R4sUZP76jIHK1RLHAvzHZhlQm3yDe1ZO/f2JyrxXZmuY2g8u6nZRQcEKOOWuaTDSkhN5yf71QChtOfZw3/UgSiYPA4JW2LCfkfcdqsrJ/0UdMylu8CHNCYIGZ6K26oOcVgdLoU7E7vUEHuTNssWhhRLz/45YyqbxTXeekET72gEyxOiCqLtfjT/WVFQ5wv1/MPTXLf8gG0zX3jAdcoMJhJi6D2B2O2Hfg2QRiPGtC/3Z3RPgd8WTvHsMBmVWHsDtubzqjVKCp14i0p5SOnHCpJ8QBIRXN4kFg0/qOKONaDmhbKBverjjrz6P6Bh67uJzaqSp4upSAsw03Nft5EJ75vt509jOR8qO8+FPvgHABAqKlsQgJxvpIeecqd2Qt3P9OMuHfvpSb12D3BtXE4RJDMFrvagg7svM1vrWJj6Yl2ELh/g87VrC1xL3AeE+7Wj4jiXIN/WtljvHzdob/q9U1EUkEQXmMKznlayKglO7MLaFeSgxZr63x4PKDUsCZC94qOAuq5oZAUq20RhJHSKKTAnNN1h3vDvFCHVUpLaml1dOLcnqLKchpfK224053g5e3E/qsp9x7FnmIVZ2VpD8lMJXD/KCkVk9fhuevcpejHWanIFWp38xZCxG0/dQ7JMKT5+jWGGjExhxGLXHru4PP6qIwOOWCH+VpnusC5YyfnBc0VsGuqof2zIAnVJXkqDCVIbfFG+PRcmhtL7ZXzWskgKZ+pVONuhYlcQm1s1pOG42K25rw+bm9JZK7HveLhz/M3MzxJ78qsuDn7/HwMsnfUsWYKG72y1TlYv0B77Jjq60ccbeZHCQxknlhWc8jwLQATm0XzDLxtstkdLhqgr70RZyVFK2ocxjjOP2ghLiNN8P7C5aYBiBSPu1TqeK11XPXC8vlekpvQ8NaX4Qt0E+/0hD31qoMpMv3TU8LY+sKLReAOXuOEdLjMvAX4suhUvNWWVbcIAbvJTAUD2LLGVbftJN+w+iIQqPggSKJ4mMhaUpxQAgznSh/nQB4odiMjmYJ4vDbxuNVO9Vw7UfZIcLzTsB838elDt0FO80qXOfxM+JsW/0H9gLzF4A7f+hXRmzrT0H+r0PF+GU+HcLCeZLfpX8F2DnN514d2nqR1nPzRswZ5+QI2ZVvzgBxc7cjNiHQ/g='; 
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        Test.stopTest();
        System.debug('wrapperTest.urlReturned => ' + wrapperTest.urlReturned);
        System.assertEquals('/lightning/n/Buscar_Cliente/00123456&0000TESTE&', wrapperTest.urlReturned);     
        
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [O método returnTreeToTransfer 
    * retorna uma arvore gerada para a realizacao da transferencia]
    */
    @isTest
    static void returnTreeToTransfer(){
        
        CEC_CTI_TransferCallWrapper transferWrapperTeste = new CEC_CTI_TransferCallWrapper();
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        /*
        CEC_CTI_TestSetup.getSkill();
        CEC_CTI_TestSetup.getTransferenciaLvl1();
        CEC_CTI_TestSetup.getTransferenciaLvl2();
        CEC_CTI_TestSetup.getTransferenciaLvl3();
        */
        //transferWrapperTeste = CEC_CTI_ControlSoftphoneController.createTreeToTransfer(testSkill.Id);

        Site__c testSite = new Site__c();
        testSite.Name ='SiteTest';
        testSite.CodSite__c = '11111';
        testSite.Tecnologia__c = 'Avaya';
        insert testSite;
        
        Skill__c testSkill = new Skill__c();
        testSkill.Name = 'SkillTest';
        testSkill.CodSkill__c = '0001Test';
        testSkill.IdExterno__c = '0001';
        testSkill.Conferencia__c = true;
        testSkill.Desliga__c = true;
        testSkill.Espera__c = true;
        testSkill.Site__c = testSite.Id;
        insert testSkill;
        System.debug('testSkill = ' + testSkill);

        Transferencia__c transfLvl1 = new Transferencia__c();
        transfLvl1.Name = 'Teste Transf';
        transfLvl1.CodTransferencia__c = 'Teste Transf';
        transfLvl1.OrigemSkill__c = testSkill.Id;
        transfLvl1.NivelSuperior__c = null;
        transfLvl1.DestinoVDNTC__c = null;
        insert transfLvl1;
        System.debug('transfLvl1 = ' + transfLvl1);
        
        Transferencia__c transfLvl2 = new Transferencia__c();
        transfLvl2.Name = 'Teste Transf 2';
        transfLvl2.CodTransferencia__c = 'Teste Transf 2';
        transfLvl2.OrigemSkill__c = testSkill.Id;
        transfLvl2.NivelSuperior__c = transfLvl1.Id;
        transfLvl2.DestinoVDNTC__c = null;
        insert transfLvl2;
        System.debug('transfLvl2 = ' + transfLvl2);        
        
        Transferencia__c transfLvl3 = new Transferencia__c();
        transfLvl3.Name = 'Teste Transf 3';
        transfLvl3.CodTransferencia__c = 'Teste Transf 3';
        transfLvl3.OrigemSkill__c = testSkill.Id;
        transfLvl3.NivelSuperior__c = transfLvl2.Id;
        transfLvl3.DestinoVDNTC__c = '123456';
        insert transfLvl3;
		System.debug('transfLvl3 = ' + transfLvl3);        
        
		Test.startTest();
        //String varCripto = 'BpA6OsXCl3A7QHuLB2A0QSdg6UO9cbJV2lRgKdUUUkiWFgUFXKX9eGd+HOukBfaahnBuEVS6YrFNmeSCS5yYs9f/gqhARtfjTFDcRmyPiaF/u9hG6bgWGDyFkhUiMG4hbZpRz2Vccsjoq0q++VILua5rmaMqHrYurnxTVP/R16kmbBwtHTHD9917r5i054Oe+0L9v6pxar9xCKa4ldt9HfTEuB3L/moXUTgTmJv2++DUEEdszkib24d4gQr9nWdogLgd/6QZf2TqI2MHadEajl05pF06C3FavRIhwznrhOphSS8Vbq6nScc70IEg1l747IS43bDubJliPEpUOENyQ/mmyVl6bZohD4oDEOLNDWtVRMRocTUeG4420W5u1oqLQxoouCM4KW/ukmtVfy5myhSuM3M7nzI8SI98yhGRGKzHbrnLUrFrJ6mjgTAfRpUnqqrI10G1/PVP9G8+B0wlryXT60ljeV/8j9riFpwHa5g5GTixTSTze5esYoUz+fWPaxguyrIG8KE3LGheKnMS78IgsQNUGOJaLME6ut8q3zFG8mduTx2N3Djx9wytt63I5gS8HbMRfchg9eIebLsRKw==';
        String varCripto = 'QTl6DIOTmmwEPHyVnGtiZNEu+FS+R2pcDgK1iSUJ/WB9lx1nEipbwb/Elt4B7FR/18tetNHngAs5W2vc+5zF7HU2BPe/2QvBPkb0vMzbHKb3x+86eKZOGRzTv7ewJPt9ybyZLca00qHqzfIHUVtOKQLtYZM/obtyVu5H3VEctwPa1pXDKn6gB6Yoma6Syf+qxN1YtM3LxlM5txdOEAAA+K7QNMOuWsDtWcGcUf8NRQTiGiJhY+PNB4+/p40ERmuoqsQWZtcJVKbEp3C1mTkjgWeMf+id2aqseDFmkRjVsq7TjszQN3LDKhfFg8QMfFcIYu3kfdQefgW/jXoe+dhGJgpiA1Bg7O4tFTOg/bxJnCBdmhcXhZhiERezr76plOs8QXqNwmWydA60ksoy1lNHVc9A7A8unwFyDeTmAPkEMmtRU0HO5CjxrveGcCZbaM+1dfMZRd5yWoXEX3E/yS++kJKNPnT8Ae/LMSFgu/aavIi+HCeGJWeFikYMYaEAkSoFB7z7eQavCgcll2oHBHdddG1loRnejRMc/AOIO197asd20AYxyNHz/lQvLv6f6fQcwhpwg56H+S4sKhiovsaqrTacKrn/HXpfDY5DeInpO5ABe8DaAq/1RU1Ygy+fxEBPasRzN8kGDlMGlXCUwO90rlJ0sdTyz8Ocyt6INT8qq/n9KaiGf9QpDS2ZBIChk8qdrLhf0+B6mtpIoM2oyxQvtglLNltVmbzrpvN7aY2maZMAhTfgz8zqt6gov60pyfdZbUaoiNGu0W5PYPXhEsi/IBiTFt2L5wH8ygXZVW78S0CE5B6nXsU7ey1bYZD/eDcD31ABoQL0NfFcdGfEnG3uVDv6jzy19O73YVDBCf92Bwk7IY+t44TIaKAvHmvY/rko4mM6h3PiQdbQlbY9LPoLiubh7Wrmy+ZRF//VlM/AHvEkL/j48meMJkueR+fvgpFNgXCfJHghyOhiCRxGfHvnDdjaeH/+JaNj9pXqFadsaBEK/hb/9NA7IwisouI9czkl2iejYl87YLsG6I/nXlJ7gkDIIgZP1/js+9W0SrFg5XlmfYHdlHByWQc/zkATrWJMxJbyyVpMu6caHvgJ0htJnCMm7HFTI7bI5Fkr4i7PH+yHByWzE2JvolbKhvBhuCNX+d5XpBxK5p7j2gyQAw5+sTjcoH3z8YItph2x2rBp1uapHw4pPLKJFNTO/8mec17pokJz2SS1r/o6RS8XOp1WFLuNRLiIpAhwCP0SA6h8jbPSZaUOc06EoNmdjzL0SQHA/pA0fc31wnsxUKTBHLpmYTKpax8HWjv6RsILw7i+/e79gXyMwVRKKbLkiqtqMnlOwBpqdOutjSjnsFR1MlpSBNcQQcGY1SdGW5HnYsaHrcpvc2qgsc8mDW/Qr+apEg00kei3CWl61qC4OOCE7LVgDlBp/jnLISu9kbLVQZp3WzV7AKvE3x+Hw4KRFzQu48Srf1yqgT6nljqQqsZbyNRNg6et8T29+BrbUhcE91tOuT8F439rr5I011zWtd6xjRWvzztjcDrjbcBohnCMsSezXXVfdCRiNbM0Ks4dCODzywE6GpokvXjuusRbDVAd4U1kc0h2HOqTjlZU1v7YdpBFvjxCpgBOfBnB1PmAazkVOeMCq1XOmEOzoudGk9R4DK74fQJvYGvzgLZaIuiFjSM6WRauaC956EtH3/S4r9VAoUTS4XiUILWfLPi5FJOeS2y0U5mdHpzbUOT0fBq4/elTpKjEx15R+0fyGZAZsOeBfz69H6HXWuTuVLTMMNvPHMnNkLzYsu2ZvFcymRv6WHPGaptnoNb7xs9Oa17435qJd2pswW1WbFR87hZLgE1TqYWMNc6F2szo0xKCvj9WjjchPM9uTU0e4U0iBDDtaZ4qAtA=';
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, testSite.CodSite__c);
        transferWrapperTeste = CEC_CTI_ControlSoftphoneController.createTreeToTransfer(testSkill.Id);
        System.assertNotEquals(null, transferWrapperTeste.set3Nivel);     
        Test.stopTest();
    }
    
	/*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [O método createNewTask 
    * cria uma nova tarefa para o agendamento de retorno de chamada, e espera um retorno de sucesso]
    */
    @isTest
    static void createNewTask(){
		
		String resultTest;

		String customerNameScheduling = 'John Test';
		String customerDocumentScheduling = '1111111111111';
		String dayScheduling = '30/12/2030';
		String hourAppointmentScheduling = '13:00';
		String titleReasonScheduling = 'Teste';
		String textReasonScheduling = 'Teste';
		String telefone1 = '21321321';
		String telefone2 = '32323231';
		String telefone3 = '23232131';
		String telefone4 = null;
		String telefone5 = null;

		Test.startTest();
		resultTest = CEC_CTI_ControlSoftphoneController.makeAppointment(customerNameScheduling, customerDocumentScheduling,
																		dayScheduling, hourAppointmentScheduling, 
																		titleReasonScheduling, textReasonScheduling,
																		telefone1, telefone2, telefone3, telefone4, telefone5);
		System.assertEquals('SUCCESS', resultTest);     																	
		Test.stopTest();

	}
    /*
    * Autor: Wanderson Viena - Deloitte
    * Descrição: [Nome do projeto/ID: SOLAR FASE 2] + [Time: SQUAD CTI - Semana 03] + [O método createCustomerInteraction 
    * cria um novo Customer Interaction para uma chamada, e espera um retorno com o ID do registro criado]
    */
    @isTest
    static void createNewCustomerInteraction(){
        id resultTest;
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        vlocity_cmt__CustomerInteraction__c varCustomerInteractiontest = new vlocity_cmt__CustomerInteraction__c();
        //1
        //
      	varCustomerInteractiontest.Name = 'IVR - 1';
        varCustomerInteractiontest.OwnerId =UserInfo.getUserId();
        varCustomerInteractiontest.Document_Number__c= '00123456';
        varCustomerInteractiontest.Document_Type__c='TYPETEST';
        varCustomerInteractiontest.ProtocolNumber__c = '1';
        varCustomerInteractiontest.CEP__c = '58075820';
        varCustomerInteractiontest.RecordTypeId = idRecordId;
        insert varCustomerInteractiontest;
        CEC_CTI_SoftPhoneWrapper wrapperTest = new CEC_CTI_SoftPhoneWrapper();
        
        //String varCripto = 'wpOAnkk6rCApm9o5lgD1T/Lm7PKYD2fcjBYJ4Q4Hfcq98jxCXflLgv+u+Zx+C+HxpUIYrs0GyMzGxCqt/HyE9YeqDLOS9+ilUsrwk2YHXxpj/dGGDmpeNVmMIAw3iLJwVtICplBIh69/UWyU7y8AdrgpPElVdaS1CoboYVGEnIR1K1Br5WoqUeeZMwf49HDnnje2VKLZQbG5w0GXNoRo/2DTepCZHMGcifrxnl34ObAe6A/0TEkiEGoeCPrXns+sq738Dk3pZbQb1m6PANyncnWSaE+O5TY0qq3HmMAr+/W4adLy9nj8379FXHBCPlolhT9/EQcT4J6tOiWwxd23ptDDFXZK2/w/jAA+j4ZKB+janIvLn4bSGufP033XjI25gNNnC/EYIkvxr9JDN1ou+aotqcxW3yB3pZcj2DdxNTLa70/eVONq4l/5/4KBtr32F9a2nZtJ7iREy4jXGon+F7pZQ7Ecp237NDG+YVaFbrbcN3DfQjzfBqiqSyjg4Zo6hvzkAohxXJ0UewDvVkFGesReH6WMEP1Fe2qfBv3Gc0z3vpYr26fRhIbh3NYe9wj5r0fhDB2/VLX6nsvF0E4dEVoCSUaEDIgQslpUHTdHpygg4GZXv6izzlcx2QyeXsvQ36t4IyPean/KusHIoOk455f4AVJ3VweRiF4gzoP5SCStC4jOKQwKcFpYdnAg7QQRZx8jC8xKlGifzr/r/EKWs1swjxPlxhn+d+VmopZzlsw=';
		String varCripto = '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'; 
        Test.startTest();
        wrapperTest = CEC_CTI_ControlSoftphoneController.decryptDriverData(varCripto, '1010');
        resultTest = CEC_CTI_ControlSoftphoneController.createIVRCustomerInteraction(wrapperTest);
        Test.stopTest();
        System.debug('resultTest => ' + resultTest);
        System.assert(String.isNotBlank(resultTest));
        
    }


}