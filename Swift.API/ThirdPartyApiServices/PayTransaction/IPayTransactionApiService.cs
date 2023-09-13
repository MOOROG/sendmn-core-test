using Swift.API.Common;
using Swift.API.Common.PayTransaction;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.ThirdPartyApiServices.PayTransaction
{
    public interface IPayTransactionApiService
    {
        JsonResponse PaySearch(PayTxnCheck model);

        JsonResponse PayConfirm(PayTxnConfirm model);

        JsonResponse DownloadRiaTxn(RiaTxnDownload model);

        JsonResponse GetTxnStatus(dynamic model);
    }
}