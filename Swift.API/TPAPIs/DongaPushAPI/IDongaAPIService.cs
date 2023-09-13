using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.DongaPushAPI
{
    public interface IDongaAPIService
    {
        DbResult SendTxnDonga(string user, DongaPushDetail _txnDetail, string provider);
    }
}
