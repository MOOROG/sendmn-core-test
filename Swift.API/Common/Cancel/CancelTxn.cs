using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;

namespace Swift.API.Common.Cancel
{
    public class CancelTxn
    {
        public string CancelReason { get; set; }

        [Required]
        public string PartnerPinNo { get; set; }

        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderId { get; set; }
        public string SessionId { get; set; }
    }
}
