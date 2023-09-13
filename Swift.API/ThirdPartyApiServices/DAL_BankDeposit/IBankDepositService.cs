using Swift.API.Common;
using Swift.API.Common.BankDeposit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.ThirdPartyApiServices.DAL_BankDeposit
{
    public interface IBankDepositService
    {
        JsonResponse PayBankDepositThroughAPI(WithdrawWalletRequestModel model);

        JsonResponse CancelRiaTxn(CancelRiaTxn model);
    JsonResponse ContactModifyTxn(ChangeOutgoing model);
  }
}
