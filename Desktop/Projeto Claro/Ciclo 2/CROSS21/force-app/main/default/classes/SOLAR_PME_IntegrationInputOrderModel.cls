/*
* @author Diogo Braga - Deloitte
* @description Classe de modelo para os objetos transacionados na integração com o CPC-RPA
*/
public with sharing class SOLAR_PME_IntegrationInputOrderModel {
    
    public class RequestBody {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public Data data {get; set;}
    }
    
    public class Data {
        public List<SalesOrders> salesOrders {get; set;}
    }
    
    public class SalesOrders {
        public SalesParty salesParty {get; set;}
        public Customer customer {get; set;}
        public EquipmentDelivery equipmentDelivery {get; set;}
        public SOLAR_PME_IntegrationInputOrderModel.Order order {get; set;}
        public Summary summary {get; set;}
        public SubscriberAcceptances subscriberAcceptances {get; set;}
        public Message message {get; set;}
        public List<Documents> documents {get; set;}
    }
    
    public class SalesParty {
        public String salesmanId {get; set;}
        public String salesmanJobTitle {get; set;}
        public String salesmanName {get; set;}
        public String companyName {get; set;}
        public String cnpj {get; set;}
        public String vendorId {get; set;}
        public String salesChannelId {get; set;}
        public String comercialSegment {get; set;}
    }
    
    public class Customer {
        public Boolean flagNetSubscriber {get; set;}
        public Boolean flagEmbratelSubscriber {get; set;}
        public String companyName {get; set;}
        public String tradingName {get; set;}
        public String stateRegistration {get; set;}
        public String municipalRegistration {get; set;}
        public String cnpj {get; set;}
        public String customerAccountId {get; set;}
        public String employeeQuantity {get; set;}
        public String accountType {get; set;}
        public String accountSegment {get; set;}
        public String territory {get; set;}
        public BillingSpec billingSpec {get; set;}
        public ContactPhone contactPhone {get; set;}
        public List<CNAES> cnaes {get; set;}
        public List<Contact> contacts {get; set;}
        public List<Addresses> addresses {get; set;}
    }
    
    public class CNAES {
        public CNAES(String code) {
            this.type = 'primário';
            this.code = code;
            this.description = '';
        }
        public String type {get; set;}
        public String code {get; set;}
        public String description {get; set;}
    }
    
    public class ContactPhone {
        public String telephoneNumber {get; set;}
        public String areaCode {get; set;}
        public String internationalCode {get; set;}
        public String contactMediumRole {get; set;}
    }
    
    public class Contact {
        public Boolean isLegalRepresentative {get; set;}
        public String title {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String cpf {get; set;}
        public String gender {get; set;}
        public String birthDate {get; set;}
        public String emailAddress {get; set;}
        public String jobTitle {get; set;}
        public String occupation {get; set;}
        public List<Phones> phones {get; set;}
    }
    
    public class Phones {
        public String telephoneNumber {get; set;}
        public String areaCode {get; set;}
        public String internationalCode {get; set;}
        public String contactMediumRole {get; set;}
    }
    
    public class Addresses {
        //public Integer streetNr {get; set;}
        public String streetNr {get; set;}
        public String addressType {get; set;}
        public String postcode {get; set;}
        public String streetType {get; set;}
        public String streetName {get; set;}
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
        public SOLAR_PME_IntegrationInputOrderModel.Address address {get; set;}
    }
    
    public class Address {
        public String addressType {get; set;}
        public String postcode {get; set;}
        public String streetType {get; set;}
        public String streetName {get; set;}
        //public Integer streetNr {get; set;}
        public String streetNr {get; set;}
        public String complement {get; set;}
        public String neighborhood {get; set;}
        public String cityName {get; set;}
        public String stateAbbreviation {get; set;}
    }
    
    public class EquipmentDelivery {
        public String type {get; set;}
        public Address address {get; set;}
        public List<Receivers> receivers {get; set;}
    }  
    
    public class Receivers {
        public Receivers(String name, String rg, Phones phone) {
            this.name = name;
            this.rg = rg;
            this.phone = phone;
        }
        public String name {get; set;}
        public String rg {get; set;}
        public Phones phone {get; set;}
    }
    
    public class Order {
        public String orderId {get; set;}
        public String orderAction {get; set;}
        public List<Plans> plans {get; set;}
    }
    
    public class Plans {
        public String planId {get; set;}
        public String name {get; set;}
        public String flagSharedPlan {get; set;}
        public String tradeIn {get; set;}    
        public List<Groups> groups {get; set;}
    }
    
    public class Groups {
        public String groupId {get; set;}
        public String name {get; set;}
        public String requestType {get; set;}
        public String regional {get; set;}
        public String stateAbbreviation {get; set;}
        public String areaCode {get; set;}
        public String franchise {get; set;}
        public String value {get; set;}
        public String overRateValue {get; set;}
        public String contractPeriod {get; set;}
        public String lineAmount {get; set;}
        public String paymentMethod {get; set;}
        public String plugin {get; set;}
        public SpecialOffer specialOffer {get; set;}
        public List<AdditionalServices> additionalServices 				 {get; set;}
        public List<IncludedServices> includedServices 					 {get; set;}     
        public List<LineDetails> lineDetails {
            get {
                return lineDetails;
            } set {
                lineDetails = value;
                if(lineDetails != null) {
                    lineAmount = String.valueOf(lineDetails.size());
                }
            }
        }
    }
    
    public class AdditionalServices {
        public String name {get; set;}
        public String value {get; set;}
        public String type {get; set;}
    }
    
    public class IncludedServices {
        public String name {get; set;}
        public String type {get; set;}
    }
    
    public class LineDetails {
        public String telephoneNumber {get; set;}
        public String operator {get; set;}
        public Donor donor {get; set;}
        public Simcard simcard {get; set;}
        public Device device {get; set;}       
    }
    
    public class Donor {
        public String name {get; set;} 
        public String cpf {get; set;}
        public String emailAddress {get; set;}
        public Address address {get; set;}
        public List<Phones> Phones {get; set;}
    }
    
    public class Simcard {
        public String iccid {get; set;}
        public String type {get; set;}
        public String value {get; set;}
        public Sap sap {get; set;}
    }	
    
    public class Sap {
        public String id {get; set;}
    }
    
    public class Device {
        public Boolean flagAcceptAnotherColor {get; set;}
        public String manufacturerName {get; set;}
        public String modelName {get; set;}
        public String color {get; set;}
        public String value {get; set;}
        public String imei {get; set;}
        public ChosenDeviceSap chosenDeviceSap {get; set;}
        public list<OptionalDevicesSap> optionalDevicesSap {get; set;}     
        
    }
    
    public class ChosenDeviceSap {
        public ChosenDeviceSap(String id) {
            this.id = id;
        }
        public String id {get; set;}
    }
    
    public class OptionalDevicesSap {
        public OptionalDevicesSap(String id) {
            this.id = id;
        }
        public String id {get; set;}
    }
    
    public class Summary {
        public String lineQuantity {get; set;}
        public String deviceQuantity {get; set;}
        public String simcardQuantity {get; set;}
        public String totalValueOfEquipments {get; set;}
        public String totalValueOfServices {get; set;}
    }
    
    public class SubscriberAcceptances {
        public Boolean flagAcceptSmsPublicity {get; set;}
        public Boolean flagAcceptLD21Manager {get; set;}
        public Boolean flagAuthorizesDataSharing {get; set;}
    }
    
    public class Documents {
        public String id {get; set;}
        public String name {get; set;}
        public String fileName {get; set;}
    }
    
    public class Message {
        public String type {get; set;}
        public String action {get; set;}
    }
    
    public class SpecialOffer {
        public List<Bonus> bonus {get; set;}
        public ProgressiveDiscount progressiveDiscount {get; set;} 
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
    
    public class ProgressiveDiscount {
        public Decimal quantity {get; set;}
        public Decimal value {get; set;} 
    }
    
    public class ResponseBody {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public ResponseData data {get; set;}
    }
    
    public class ResponseData {
        public SalesOrder salesOrder {get; set;}
    }
    
    public class SalesOrder {
        public String orderId {get; set;}
    }
    
    public class Error {
        public String httpCode {get; set;}
        public String errorCode {get; set;}
     	public String message {get; set;}
     	public String detailedMessage {get; set;}
        public Link link {get; set;}
    }

    public class Link {
        public String rel {get; set;}
        public String href {get; set;} 
    }
}