#pragma warning disable CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.API.Common.PayTransaction;
#pragma warning restore CS0234 // The type or namespace name 'PayTransaction' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn
{
    public interface IPayTransactionThirdpartyDao
    {
#pragma warning disable CS0246 // The type or namespace name 'PayTxnCheck' could not be found (are you missing a using directive or an assembly reference?)
        DbResult SearchTransaction(PayTxnCheck req);
#pragma warning restore CS0246 // The type or namespace name 'PayTxnCheck' could not be found (are you missing a using directive or an assembly reference?)

#pragma warning disable CS0246 // The type or namespace name 'PayTxnConfirm' could not be found (are you missing a using directive or an assembly reference?)
        DbResult ConfirmTransaction(PayTxnConfirm req);
#pragma warning restore CS0246 // The type or namespace name 'PayTxnConfirm' could not be found (are you missing a using directive or an assembly reference?)
    }
}
