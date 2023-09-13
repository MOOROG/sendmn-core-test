using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.API.Common
{
    public class TransactionDataRequest
    {
        public string flag { get; set; }
        public string tranType { get; set; }
        public string year { get; set; }
        public string month { get; set; }
        public string currency { get; set; }
        public string agent { get; set; }
        public string country { get; set; }
    }
}
