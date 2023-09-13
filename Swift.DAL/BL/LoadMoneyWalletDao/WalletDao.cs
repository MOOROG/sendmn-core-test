using log4net;
using Microsoft.SqlServer.Management.Smo;
using Swift.API.Common.BankDeposit;
using Swift.API.Common.SyncModel.Bank;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Swift.DAL.Library;
using Swift.DAL.OnlineAgent;
using Swift.API.Common;
using System.Web.UI;

namespace Swift.DAL.BL.LoadMoneyWalletDao {
  public class WalletDao : RemittanceDao {
    private readonly ILog _log = LogManager.GetLogger(typeof(WalletDao));
    public DataTable LoadWalletDetails(string walletNo) {
      string sql = "EXEC Proc_LoadMoneyInWallet";
      sql += " @flag = 'loadWalletDetails'";
      sql += ", @walletNo = " + FilterString(walletNo);

      return ExecuteDataTable(sql);
    }

    public DbResult UploadMoneyInWallet(string user, string walletNo, string money, string requestFrom, string agentId, string sessionId) {
      string sql = "EXEC Proc_LoadMoneyInWallet";
      sql += " @flag = 'loadMoney'";
      sql += ", @user = " + FilterString(user);
      sql += ", @walletNo = " + FilterString(walletNo);
      sql += ", @uploadAmount = " + FilterString(money);
      sql += ", @requestFrom = " + FilterString(requestFrom);
      sql += ", @tellerId = " + FilterString(agentId);
      sql += ", @sessionId = " + FilterString(sessionId);
      return ParseDbResult(sql);
    }

    public DbResult PartnerWalletRequestState(string id, string flag, string status, string user, string reqFrom, string agentId, string sessionId) {
      string sql = "EXEC Proc_WalletRequestState";
      sql += " @flag = " + FilterString(flag);
      sql += ", @status = " + FilterString(status);
      sql += ", @user = " + FilterString(user);
      sql += ", @id = " + id;
      sql += ", @requestFrom = " + FilterString(reqFrom);
      sql += ", @tellerId = " + FilterString(agentId);
      sql += ", @sessionId = " + FilterString(sessionId);
      return ParseDbResult(sql);
    }

    public DbResult WithdrawMoneyWallet(string user, string walletNo, string money) {
      string sql = "EXEC proc_mobile_withdrawFromWallet";
      sql += " @flag = 'withdrawCore'";
      sql += ", @user = " + FilterString(user);
      sql += ", @walletNo = " + FilterString(walletNo);
      sql += ", @amount = " + FilterString(money);
      return ParseDbResult(sql);
    }

    public DbResult UploadMoneyInAgentFund(string date, string agent, string agentName, string account, string amountCur, string rate, string user) {
      string sql = "EXEC Proc_LoadMoneyInAgentFund";
      sql += " @flag = 'loadMoneyAgentFund'";
      sql += ", @date = " + FilterString(date);
      sql += ", @agent = " + FilterString(agent);
      sql += ", @agentName = " + FilterString(agentName);
      sql += ", @account = " + FilterString(account);
      sql += ", @amountCurrency = " + FilterString(amountCur);
      sql += ", @rate = " + FilterString(rate);
      sql += ", @user = " + FilterString(user);
      return ParseDbResult(sql);
    }

    public DbResult SetFreeServiceCharge(string country, string isFirst, string fromDate, string toDate, string user) {
      string sql = "EXEC Proc_SetFreeScharge";
      sql += " @flag = 'set'";
      sql += ", @fromDate = " + FilterString(fromDate);
      sql += ", @toDate = " + FilterString(toDate);
      sql += ", @country = " + FilterString(country);
      sql += ", @isFirst = " + FilterString(isFirst);
      sql += ", @user = " + FilterString(user);

      return ParseDbResult(sql);
    }
  }
}
