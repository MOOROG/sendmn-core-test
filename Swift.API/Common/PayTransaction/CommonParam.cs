using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.PayTransaction
{
   public class CommonParam
    {
        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderId { get; set; }
        public string SessionId { get; set; }
        public string PBranch { get; set; }
        public string RequestFrom { get; set; }
    }
}
