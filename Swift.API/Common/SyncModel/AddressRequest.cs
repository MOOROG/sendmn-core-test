using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel
{
    public class AddressRequest : CommonRequest
    {
        public string CountryIsoCode { get; set; }
        public string StateId { get; set; }
        public string CityName { get; set; }
        public int StartIndex { get; set; }
        public int PageSize { get; set; }
        public string CityId { get; set; }
        public string TownName { get; set; }
        public string MethodType { get; set; }
    }
}