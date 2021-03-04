/**
 * Created by 93668256 on 03/12/2019.
 */

public class PhoneNumberReservationDTO {

    public class IntegrationTestTelephoneNumbersReservations {
        public TelephoneNumberReservationInfo data;

        public IntegrationTestTelephoneNumbersReservations() {
        }

        public IntegrationTestTelephoneNumbersReservations(TelephoneNumberReservationInfo data) {
            this.data = data;
        }
    }

    public class TelephoneNumberReservationInfo{
        public String numberOfReserv;
        public String prefix;
        public String suffix;
        public Integer reservationsTime;
        public String unitMeasureTime;
        public String areaCode;
        public String reasonId;
        public String segmentationId;

        public TelephoneNumberReservationInfo() {
        }

        public TelephoneNumberReservationInfo(String numberOfReserv, String prefix, String suffix, Integer reservationsTime,
                String unitMeasureTime, String areaCode, String reasonId, String segmentationId) {
            this.numberOfReserv = numberOfReserv;
            this.prefix = prefix;
            this.suffix = suffix;
            this.reservationsTime = reservationsTime;
            this.unitMeasureTime = unitMeasureTime;
            this.areaCode = areaCode;
            this.reasonId = reasonId;
            this.segmentationId = segmentationId;
        }
    }

    public class IntegrationTestTelephoneInfo extends CEC_RestObjects.ResponseGen {
        public IntegrationTestTelephoneValue data;

        public IntegrationTestTelephoneInfo() {
        }

        public IntegrationTestTelephoneInfo(IntegrationTestTelephoneValue data) {
            this.data = data;
        }

        public String getOneNumber(){
            for(PhoneNumber n: this.data.telephoneNumbers)
                return n.number_z;
            return '';
        }
    }

    public class IntegrationTestTelephoneValue {
        public List<PhoneNumber> telephoneNumbers;

        public IntegrationTestTelephoneValue() {
        }

        public IntegrationTestTelephoneValue(List<PhoneNumber> telephoneNumbers) {
            this.telephoneNumbers = telephoneNumbers;
        }
    }

    public class PhoneNumber{
        public String number_z;

        public PhoneNumber() {
        }

        public PhoneNumber(String number_z) {
            this.number_z = number_z;
        }
    }
}