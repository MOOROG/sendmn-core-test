using Swift.API.Common.PayTransaction;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn
{
    public interface IPayTransactionDao
    {
        DbResult SearchTransaction(PayTxnCheck req);

        DbResult ConfirmTransaction(PayTxnConfirm req);
    }
}
