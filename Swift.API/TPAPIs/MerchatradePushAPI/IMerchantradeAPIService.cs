using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.MerchatradePushAPI
{
    public interface IMerchantradeAPIService
    {
        DbResult SendTxnMtrade(string user, MtradePushDetail _txnDetail, string provider);

        DbResult GetExRate(string user, string provider, string pAgentCode);
    }
}
