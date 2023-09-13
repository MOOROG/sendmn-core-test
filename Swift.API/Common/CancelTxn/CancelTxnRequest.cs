using Swift.API.Common.SyncModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.CancelTxn
{
    public class CancelTxnRequest : CommonRequest
    {
        public string CancelReason { get; set; }

        public string PartnerPinNo { get; set; }

        public string ControlNo { get; set; }

        public string TranNo { get; set; }
    }
}