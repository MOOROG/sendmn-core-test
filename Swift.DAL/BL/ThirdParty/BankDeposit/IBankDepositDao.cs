using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.BL.ThirdParty.BankDeposit
{
    public interface IBankDepositDao
    {
        DbResult PayBankDeposit(string user, string[] tranId);
    }
}
