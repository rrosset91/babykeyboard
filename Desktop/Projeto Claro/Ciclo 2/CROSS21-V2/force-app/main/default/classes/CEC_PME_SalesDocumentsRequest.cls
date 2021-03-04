/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para inicialização do objetos utilizados na integração do GGD.
*/

public class CEC_PME_SalesDocumentsRequest {
    public String apiVersion {get; set;}
    public String transactionId {get; set;}
    public Data data {get; set;}
    
    public class Data {
        public List<SalesDocuments> salesDocuments {get; set;}
    }
    
    public class SalesDocuments {
        public SalesParty salesParty {get; set;}
        public Customer customer {get; set;}
        public List<EquipmentReceivers> equipmentReceivers {get; set;}
        public List<Plans> plans {get; set;}
        public Summary summary {get; set;}
        public SubscriberAcceptances subscriberAcceptances {get; set;}
    }
    
    public class SalesParty {
        public String salesmanId {get; set;}
        public String salesmanName {get; set;}
        public String companyName {get; set;}
        public String cnpj {get; set;}
        public String vendorId {get; set;}
        public String salesChannelId {get; set;}
        public String segment {get; set;}
    }
    
    public class Customer {
        public String companyName {get; set;}
        public String stateRegistration {get; set;}
        public String municipalRegistration {get; set;}
        public String primaryCNAE {get; set;}
        public String secondaryCNAE {get; set;}
        public String cnpj {get; set;}
        public Boolean flagNetSubscriber {get; set;}
        public Boolean flagEmbratelSubscriber {get; set;}
        public String customerAccountId {get; set;}
        public ContactPhone contactPhone {get; set;} 
        public Integer employeeQuantity {get; set;}
        public List<Administrators> administrators {get; set;}
        public List<Addresses> addresses {get; set;}
        public List<CommercialReferences> commercialReferences {get; set;}
        public BillingSpec billingSpec {get; set;}       
    }

	public class ContactPhone {
        public String telephoneNumber {get; set;}
        public String areaCode {get; set;}
        public String internationalCode {get; set;}
        public String contactMediumRole {get; set;}
    }

	public class Administrators {
    	public String name {get; set;}
        public String cpf {get; set;}
        public String formattedCpf {
            get { 
                return formatCpf(cpf);
            }
            private set; 
        }
        public List<Phones> phones {get; set;}
        public String emailAddress {get; set;}
        public Boolean isLegalRepresentative {get; set;}
        public String jobTitle {get; set;}
	}

    public class Phones {
    	public String telephoneNumber {get; set;}
        public String areaCode {get; set;}
        public String internationalCode {get; set;}
        public String contactMediumRole {get; set;}
        public String formattedNumber {
            get {
                if(String.isBlank(telephoneNumber)) {
                    return '---';
                }
                String formattedNumber = '('+areaCode+') ';
                if(telephoneNumber.length() == 9) {
                    formattedNumber += telephoneNumber.mid(0,5) + '-' + telephoneNumber.mid(5,4);
                } else if (telephoneNumber.length() == 8){
                    formattedNumber += telephoneNumber.mid(0,4) + '-' + telephoneNumber.mid(4,4);
                } else {
                    return telephoneNumber;
                }
                if(String.isNotBlank(internationalCode)) {
                    formattedNumber = '+' + internationalCode + ' ' + formattedNumber;
                }
                return formattedNumber;
            }
            private set; 
        }
    }

	public class Addresses {
        public String addressType {get; set;}
        public String postcode {get; set;}
        public String streetType {get; set;}
        public String streetName {get; set;}
        public String streetNr {get; set;}
        public String complement {get; set;}
        public String neighborhood {get; set;}
        public String cityName {get; set;}
        public String stateAbbreviation {get; set;}
	}

	public class CommercialReferences {
        public String companyName {get; set;}
        public String cnpj {get; set;}
        public String contactName {get; set;}
        public ContactPhone contactPhone {get; set;}
    }
    
    public class BillingSpec {
        public String paymentDayDue {get; set;}
        public BankingDetails bankingDetails {get; set;}
    }
    
    public class BankingDetails {
        public String bankId {get; set;}
        public String bankName {get; set;}
        public String agency {get; set;}
        public String accountNumber {get; set;}
        public String contactName {get; set;}
        public ContactPhone contactPhone {get; set;}
    }
    
    public class EquipmentReceivers {
    	public String name {get; set;}
        public String rg {get; set;}
        public Phones phones {get; set;}
    }
    
    public class Plans {
        public String name {get; set;}
        public String formattedName {
            get {
                if(string.isBlank(name)) {
                    return '---';
                }
                if('Plano Claro Total Compartilhado'.equals(name)) {
                    return 'Compartilhado - Total Share - Claro Total PME (Anatel n°072)';
                }
                if('Plano Claro Total Individual'.equals(name)) {
                    return 'Plano Claro Total Individual - Claro Life (Anatel n°190)';
                }
                return name;
            }
            private set; 
        }
        public Boolean flagSharedPlan {get; set;}
		public String tradeIn {get; set;}        
        public List<Groups> groups {get; set;}
    }
    
    public class Groups {
    	public String name {get; set;}
        public String requestType {get; set;}
        public String regional {get; set;}
        public String stateAbbreviation {get; set;}
        public String areaCode {get; set;}
        public String franchise {get; set;}
        public Decimal value {get; set;}
        public String formattedValue {
            get {
                return formatCurrency(value);
            }
            private set; 
        }
        public String lineAmount {get; set;}
        public String paymentMethod {get; set;}
        public String bonus {get; set;}
        public List<Bonus> listBonus {get; set;}
        public Decimal progressiveDiscount {get; set;}
        public String formattedProgressiveDiscount {
            get {
                return formatCurrency(progressiveDiscount);
            }
            private set; 
        }
        public Decimal valueDiscount {get; set;}
        public String formattedValueDiscount {
            get {
                return formatCurrency(valueDiscount);
            }
            private set; 
        }
        public String kit {get; set;}
        public String formattedKit {
            get {
                if(String.isBlank(kit)) {
                    return '---';
                }
                return kit;
            }
            private set; 
        }
        public List<Plugin> plugins {get; set;}
        public List<AdditionalServices> additionalServices {get; set;}
        public List<IncludedServices> includedServices {get; set;}
        public List<LineDetails> lineDetails {get; set;}
        public List<FormattedDevice> listFormattedDevice {
            get {
                Map<String, FormattedDevice> groupedLineDetails = new Map<String, FormattedDevice>();
                if(lineDetails == null || lineDetails.isEmpty()) {
                    return null;
                }
                for(LineDetails itemLineDetails : lineDetails) {
                    if(itemLineDetails.simcard != null) {
                        String key = itemLineDetails.simcard.type + itemLineDetails.simcard.formattedValue;
                        if(groupedLineDetails.containsKey(key)) {
                            groupedLineDetails.get(key).amount++;
                        } else {
                            FormattedDevice formattedDevice = new FormattedDevice();
                            formattedDevice.amount = 1;
                            if(String.isBlank(itemLineDetails.simcard.type)) {
                                formattedDevice.equipment = 'SimCard';
                            } else {
                                formattedDevice.equipment = 'SimCard ' + itemLineDetails.simcard.type;
                            }
                            formattedDevice.unitaryValue = itemLineDetails.simcard.formattedValue;
                            formattedDevice.color = '---';
                            formattedDevice.acceptAnotherColor = '---';
                            formattedDevice.range = '---';
                            formattedDevice.punctuation = '---';
                            groupedLineDetails.put(key, formattedDevice);
                        }
                    }
                }
                
                for(LineDetails itemLineDetails : lineDetails) {
                    if(itemLineDetails.device != null && itemLineDetails.device.modelName != null) {
                        String key = itemLineDetails.device.modelName + itemLineDetails.device.color + itemLineDetails.device.flagAcceptAnotherColor;
                        key = key + itemLineDetails.device.formattedValue + itemLineDetails.device.range + itemLineDetails.device.score;
                        if(groupedLineDetails.containsKey(key)) {
                            groupedLineDetails.get(key).amount++;
                        } else {
                            FormattedDevice formattedDevice = new FormattedDevice();
                            formattedDevice.amount = 1;
                            formattedDevice.equipment = itemLineDetails.device.modelName;
                            formattedDevice.unitaryValue = itemLineDetails.device.formattedValue;
                            formattedDevice.color = itemLineDetails.device.color;
                            if(itemLineDetails.device.flagAcceptAnotherColor) {
                                formattedDevice.acceptAnotherColor = 'Sim';
                            } else {
                                formattedDevice.acceptAnotherColor = 'Não';
                            }
                            formattedDevice.range = itemLineDetails.device.range;
                            formattedDevice.punctuation = String.valueOf(itemLineDetails.device.score);
                            groupedLineDetails.put(key, formattedDevice);
                        }
                    }
                }
                return groupedLineDetails.values();
            }
            private set; 
        }
        public Boolean hasLineDetails  {
            get {
                Boolean hasLineDetails = false;
                if(lineDetails == null) {
                    return false;
                }
                for(LineDetails varLineDetails : lineDetails) {
                    hasLineDetails |= String.isNotBlank(varLineDetails.telephoneNumber);
                    hasLineDetails |= String.isNotBlank(varLineDetails.operator);
                    hasLineDetails |= varLineDetails.donor != null && String.isNotBlank(varLineDetails.donor.cpf);
                    hasLineDetails |= varLineDetails.simcard != null && String.isNotBlank(varLineDetails.simcard.iccid);
                }
                return hasLineDetails;
            }
            private set; 
        }
    }
    
    public class FormattedDevice {
        public Integer amount {get; set;}
        public String equipment {get; set;}
        public String color {get; set;}
        public String acceptAnotherColor {get; set;}
        public String unitaryValue {get; set;}
        public String range {get; set;}
        public String punctuation {get; set;}
    }
    
    public class Bonus {
        public String name {get; set;}
        public String productCode {get; set;}
        public String value {get; set;}
        public String type {get; set;}
        public String subtype {get; set;}
        public String objectType {get; set;}
        public String productFamily {get; set;}
        public String period {get; set;}
    }

	public class Plugin {
        public String type {get; set;}
        public String id {get; set;}
        public Decimal value {get; set;}
        public String formattedValue {
            get {
                return formatCurrency(value);
            }
            private set; 
        }
        public String areaCode {get; set;}
	}

	public class AdditionalServices {
        public String name {get; set;}
        public Decimal value {get; set;}
        public String formattedValue {
            get {
                return formatCurrency(value);
            }
            private set; 
        }
	}

	public class IncludedServices {
        public String name {get; set;}
	}
    
    public class LineDetails {
        public String telephoneNumber  {get; set;}
        public String formattedTelephoneNumber {
            get { 
                if(String.isBlank(telephoneNumber)) {
                    return '---';
                }
                if(telephoneNumber.length() == 10) { 
                    return '(' + telephoneNumber.mid(0,2) + ')' + telephoneNumber.mid(2, 4) + '-' + telephoneNumber.mid(6, 4);
                }
                if(telephoneNumber.length() == 11) { 
                    return '(' + telephoneNumber.mid(0,2) + ')' + telephoneNumber.mid(2, 5) + '-' + telephoneNumber.mid(7, 4);
                }
                return telephoneNumber;
            }
            private set; 
        }
        public Donor donor {get; set;}
        public String operator {get; set;}
        public String formattedOperator {
            get { 
                if(String.isBlank(operator)) {
                    return '---';
                }
                return operator;
            }
            private set; 
        }
        public Simcard simcard {get; set;}
        public Device device {get; set;}
    }
    
    public class Donor {
    	public String name {get; set;}
        public String cpf {get; set;}
        public String formattedCpf {
            get {
                return formatCpf(cpf);
            }
            private set; 
        }
        public List<Phones> phones {get; set;}
        public String emailAddress {get; set;}
        public Address address {get; set;}
    }

	public class Address {
        public String addressType {get; set;}
        public String postcode {get; set;}
        public String streetType {get; set;}
        public String streetName {get; set;}
        public String streetNr {get; set;}
        public String complement {get; set;}
        public String neighborhood {get; set;}
        public String cityName {get; set;}
        public String stateAbbreviation {get; set;}
    }
    
    public class Simcard {
    	public String iccid {get; set;}
        public String formattedIccid {
            get { 
                if(String.isBlank(iccid)) {
                    return '---';
                }
                return iccid;
            }
            private set; 
        }
        public String type {get; set;}
        public Decimal value {get; set;}
        public String formattedValue {
            get {
                return formatCurrency(value);
            }
            private set; 
        }
        public Decimal baseValue {get; set;}
        public String formattedBaseValue {
            get {
                return formatCurrency(baseValue);
            }
            private set; 
        }
    }
    
    public class Device {
    	public String manufacturerName {get; set;}
        public String modelName {get; set;}
        public String color {get; set;}
        public Boolean flagAcceptAnotherColor {get; set;}
        public Decimal value {get; set;}
        public String formattedValue {
            get {
                return formatCurrency(value);
            }
            private set; 
        }
        public Integer score {get; set;}
        public String formattedScore {
            get {
                if(score == null) {
                    return '---';
                }
                return String.valueOf(score);
            }
            private set; 
        }
        public String range {get; set;}
        public String formattedRange {
            get {
                if(String.isBlank(range)) {
                    return '---';
                }
                return range;
            }
            private set; 
        }
        public Decimal baseValue {get; set;}
        public String formattedBaseValue {
            get {
                return formatCurrency(baseValue);
            }
            private set; 
        }
    }
    
    public class Summary {
    	public String lineQuantity {get; set;}
        public String deviceQuantity {get; set;}
        public Decimal totalValueOfEquipments {get; set;}
        public String formattedTotalValueOfEquipments {
            get {
                return formatCurrency(totalValueOfEquipments);
            }
            private set; 
        }
        public String totalValueOfServices {get; set;}
        public String formattedTotalValueOfServices {
            get {
                return formatCurrency(Decimal.valueOf(totalValueOfServices));
            }
            private set; 
        }
        public List<SimcardDetails> simcards {get; set;}
        public String paymentMethod {get; set;}
    }
    
    public class SubscriberAcceptances {
        public Boolean flagAcceptSmsPublicity {get; set;}
        public Boolean flagAcceptLD21Manager {get; set;}
        public Boolean flagAuthorizesDataSharing {get; set;}
    }
    
    public class SimcardDetails {
        public String type {get; set;}
        public Decimal quantity {get; set;}
    }  
    
    public static String formatCurrency(Decimal value) {
        if(value == null) {
            return '---';
        }
        String valueStr = String.valueOf(value.setScale(2));
        valueStr = valueStr.replace('.', ',');
        return 'R$ ' + valueStr;
    }
    
    public static String formatCpf(String unformattedCpf) {
        if(String.isBlank(unformattedCpf)) {
            return '---';
        }
        if(unformattedCpf.length() == 11) { 
            return unformattedCpf.mid(0, 3) + '.' + unformattedCpf.mid(3, 3) + '.' + unformattedCpf.mid(6, 3) + '-' + unformattedCpf.mid(9, 2);
        }
        return unformattedCpf;
    }
}