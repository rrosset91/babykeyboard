public class CEC_PME_MobileCustomer_Response {
    public Data data                                                { get; set; }
    public ParametroInvalidoFault parametroInvalidoFault            { get; set; }
    public TechnicalFault technicalFault                            { get; set; }
    
    public class Data{
        public List<MobileCustomers> mobileCustomers                { get; set; }
    }
    
    public class MobileCustomers{
        public String customerIdentifier                            { get; set; }
        public String socialName                                    { get; set; }
        public String documentNumberCNPJ                            { get; set; }
    }
    
    public class ParametroInvalidoFault{
        public String mensagem                                      { get; set; }
    }
    
    public class TechnicalFault{
        public String mensagem                                      { get; set; }
    }
}