using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common
{
    public class SendTxnRequest
    {
        public string provider { get; set; }
        public string requestJSON { get; set; }
        public string processId { get; set; }
    }
}
