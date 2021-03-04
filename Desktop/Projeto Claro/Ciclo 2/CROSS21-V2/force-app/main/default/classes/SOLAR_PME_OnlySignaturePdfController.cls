public class SOLAR_PME_OnlySignaturePdfController {
    public class SOLAR_PME_OnlySignaturePdfControllerException extends Exception {}
    public class SigniturePdfModel {
        public SigniturePdfModel() {
            this.listAdministrators = new List<Administrator>();
        }
        
        public Company company {get; set;}
        public AppointedManager apointedManager {get; set;}
        public List<Administrator> listAdministrators {get; set;}
        public List<Donor> listDonors {get; set;}
    }
    
    public class Donor {
        public String anchor {get; set;}
    }
    
    public class Administrator {
        public String name {get; set;}
        public String responsibility {get; set;}
        public String documentNumber {get; set;}
        public String anchor {get; set;}
    }
    
    public class AppointedManager {
        public String name {get; set;}
        public String phone {get; set;}
    }
    
    public class Company {
        public String name {get; set;}
        public String documentNumber {get; set;}
    }
    
    public SigniturePdfModel signiturePdfModel {get; set;}
    private Order order {get; set;}
    private List<AccountContactRelation> listAcountRelations {get;set;}
    
    public SOLAR_PME_OnlySignaturePdfController() {
        
        String orderId = ApexPages.currentPage().getParameters().get('id');
        this.order = getOrder(orderId);
        this.listAcountRelations = getListAccountRelations();
        if(this.listAcountRelations == null || this.listAcountRelations.isEmpty()) {
            throw new SOLAR_PME_OnlySignaturePdfControllerException('Erro não esperado: Assinantes não encontrados');
        }
        this.signiturePdfModel = buildSigniturePdfModel();
    }
    
    public Order getOrder(String orderId) {
        if(String.isBlank(orderId)) {
            throw new SOLAR_PME_OnlySignaturePdfControllerException('Id parameter is required');
        }
        
        return [SELECT Id,
                Account.DocumentNumber__c,
                Account.Name,
                Related_Contacts__c,
                (SELECT Id,
                 DonatorName__c, 
                 DonatorDocumentNumber__c, 
                 DonatorPhone__c,
                 DonatorEmail__c
                 FROM OrderItems
                 WHERE DonatorName__c != null)
                FROM Order
                WHERE Id = :orderId];
    }
    
    private List<AccountContactRelation> getListAccountRelations() {
        return [SELECT Id,
                Contact.Name,
                Contact.DocumentNumber__c,
                Roles,
                Phone__c,
                MobilePhone__c
                FROM AccountContactRelation 
                WHERE Id IN :getRelatedContactSetId(order.Related_Contacts__c)
                AND ResponsibleForTheSignature__c = true];
    }
    
    private List<String> getRelatedContactSetId(String relatedContactsConc) {
        system.debug('relatedContactsConc ' + relatedContactsConc);
        if(relatedContactsConc == null || String.isBlank(relatedContactsConc)) {
            return new List<String>();
        }
        
        if(relatedContactsConc.endsWith(';')) {
            relatedContactsConc = relatedContactsConc.substring(0, relatedContactsConc.length() - 1);
        }
        System.debug('relatedContactsConc.split() ' + json.serialize(relatedContactsConc.split(';')));
        return relatedContactsConc.split(';');
    }
    
    private SigniturePdfModel buildSigniturePdfModel() {
        SigniturePdfModel signiturePdfModel = new SigniturePdfModel();
        signiturePdfModel.company = buildCompany();
        signiturePdfModel.listAdministrators = buildListAdministrators();
        signiturePdfModel.apointedManager = buildAppointedManager();
        signiturePdfModel.listDonors = buildListDonors();
        return signiturePdfModel;
    }
    
    private Company buildCompany() {
        Company company = new Company();
        company.name = order.Account.Name;
        company.documentNumber = formatCNPJ(order.Account.DocumentNumber__c);
        return company;
    }
    
    private String formatCNPJ(String unformattedCNPJ) {
        if(String.isBlank(unformattedCNPJ)) {
            return '---';
        }
        
        if(unformattedCNPJ.length() == 14) {
            String cnpj = unformattedCNPJ.mid(0, 2) + '.';
            cnpj += unformattedCNPJ.mid(2, 3) + '.';
            cnpj += unformattedCNPJ.mid(5, 3) + '/';
            cnpj += unformattedCNPJ.mid(8, 4) + '-';
            cnpj += unformattedCNPJ.mid(12, 2);
            return cnpj;
        }
        return unformattedCNPJ;
    }
    
    private AppointedManager buildAppointedManager() {
        AppointedManager appointedManager = new AppointedManager();
       	AccountContactRelation varAccountContactRelation = this.listAcountRelations.get(0);
        appointedManager.name = varAccountContactRelation.Contact.Name;
        appointedManager.phone = getFormatedPhones(varAccountContactRelation.Phone__c, varAccountContactRelation.MobilePhone__c);
        return appointedManager;
    }
    
    private String getFormatedPhones(String phone, String mobilePhone) {
        String formatedPhones = '';
        if(String.isNotBlank(phone) && String.isNotBlank(mobilePhone)) {
            formatedPhones = formatPhone(phone) + '/' + formatPhone(mobilePhone);
        } else if(String.isNotBlank(phone)) {
            formatedPhones = formatPhone(phone);
        } else if(String.isNotBlank(mobilePhone)) {
            formatedPhones = formatPhone(mobilePhone);
        }
        
        return formatedPhones;
    }
    
    private String formatPhone(String unformattedPhone) {
        if(String.isBlank(unformattedPhone)) {
            return '---';
        }
        
        if(unformattedPhone.length() == 9) {
            return unformattedPhone.mid(0, 5) + '-' + unformattedPhone.mid(5, 4);
        } else if (unformattedPhone.length() == 8) {
            return unformattedPhone.mid(0, 4) + '-' + unformattedPhone.mid(4, 4);
        } else if (unformattedPhone.length() == 10) {
            return '(' + unformattedPhone.mid(0, 2) + ')' + unformattedPhone.mid(2, 4) + '-' + unformattedPhone.mid(6, 4);
        } else if (unformattedPhone.length() == 11) {
            return '(' + unformattedPhone.mid(0, 2) + ')' + unformattedPhone.mid(2, 5) + '-' + unformattedPhone.mid(7, 4);
        }
        return unformattedPhone;
    }
    
    private List<Administrator> buildListAdministrators() {
        List<Administrator> listAdministrators = new List<Administrator>();
        
        Integer count = 1;
        for(AccountContactRelation varAccountContactRelation : this.listAcountRelations) {
            Administrator newAdministrator = new Administrator();
            newAdministrator.name = varAccountContactRelation.Contact.Name;
            newAdministrator.documentNumber = formatCpf(varAccountContactRelation.Contact.DocumentNumber__c);
            newAdministrator.responsibility = varAccountContactRelation.Roles;
            newAdministrator.anchor = 'RLSF#00' + count;
            count++;
            listAdministrators.add(newAdministrator);
        }
        
        return listAdministrators;
    }
    
    private String formatCpf(String unformattedCpf) {
        if(String.isBlank(unformattedCpf)) {
            return '---';
        }
        if(unformattedCpf.length() == 11) { 
            return unformattedCpf.mid(0, 3) + '.' + unformattedCpf.mid(3, 3) + '.' + unformattedCpf.mid(6, 3) + '-' + unformattedCpf.mid(9, 2);
        }
        return unformattedCpf;
    }
    
    private List<Donor> buildListDonors() {
        List<Donor> listDonors = new List<Donor>();
        Integer count = 1;
        Set<String> setDonorsNames = new Set<String>();
        for(OrderItem varOrderItem : order.OrderItems) {
            Boolean isDonor = String.isNotBlank(varOrderItem.DonatorName__c);
            if(isDonor && !setDonorsNames.contains(varOrderItem.DonatorName__c)) {
                setDonorsNames.add(varOrderItem.DonatorName__c);
                Donor newDonor = new Donor();
                newDonor.anchor = 'TTSF#00' + count;
                count++;
                listDonors.add(newDonor);
            }
        }
        
        return listDonors;
    }
}