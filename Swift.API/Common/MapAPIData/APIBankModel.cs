using System.Collections.Generic;

namespace Swift.API.Common.MapAPIData
{
    public class APIBankModel
    {
        public class BankRequest
        {
            public string CountryCode { get; set; }
            public string ProviderId { get; set; }
            public string BankName { get; set; }
            public bool IsBranch { get; set; }
            public int CityId { get; set; }
        }

        public class BankResponse
        {
            public string Id { get; set; }
            public string Name { get; set; }
        }

        public class _BankResponse : ConsoleResponse
        {
            public List<BankResponse> Data { get; set; }
        }

        public class ConsoleResponse
        {
            public string ResponseCode { get; set; }
            public string Msg { get; set; }
            public string Id { get; set; }
            public string Extra { get; set; }
            public string Extra2 { get; set; }
            public string Status { get; set; }
        }
    }
}
