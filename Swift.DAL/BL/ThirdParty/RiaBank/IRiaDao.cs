#pragma warning disable CS0234 // The type or namespace name 'BankDeposit' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.API.Common.BankDeposit;
#pragma warning restore CS0234 // The type or namespace name 'BankDeposit' does not exist in the namespace 'Swift.API.Common' (are you missing an assembly reference?)
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.RiaBank
{
    public interface IRiaDao
    {
        DataTable LoadRiaCancelTxn(string user);

#pragma warning disable CS0246 // The type or namespace name 'CancelRiaTxn' could not be found (are you missing a using directive or an assembly reference?)
        DbResult CancelRiaTxn(CancelRiaTxn reqObj);
#pragma warning restore CS0246 // The type or namespace name 'CancelRiaTxn' could not be found (are you missing a using directive or an assembly reference?)
    }
}