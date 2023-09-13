using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common
{
   public class TFReleaseTxnRequest
    {
        public string TfPin { get; set; }

        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderId { get; set; }
        public string SessionId { get; set; }
        public string RequestBy { get; set; }

    }
}
