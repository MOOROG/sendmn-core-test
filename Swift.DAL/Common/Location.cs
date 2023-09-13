using System.Collections.Generic;

namespace Swift.DAL.Common
{
    public class Location
    {
        public string errorCode { get; set; }
        public string errorMsg { get; set; }
        public string CountryName { get; set; }
        public string CountryCode { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string Lat { get; set; }
        public string Long { get; set; }
        public string TimeZone { get; set; }
        public string ZipCode { get; set; }
        public string IpAddress { get; set; }

    }

    public class txnCompliance
    {
        public List<result> result { get; set; }
        public string txnType { get; set; }
    }

    public class result
    {
        public string answer { get; set; }
        public string qId { get; set; }
        public string qType { get; set; }
    }
}
