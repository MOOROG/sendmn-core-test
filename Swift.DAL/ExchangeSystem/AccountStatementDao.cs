using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.ExchangeSystem {
  public class AccountStatementDao : SwiftDao {
    public AccountStatementDao() {
    }
    public DbResult UpdateStatement(string user, string id, string gl_code, string accountNum, string accountName, string accountReportCode
                                , string accountOwnership, string freezeCode, string accountFlag, string agent, string lAmt
                                , string lRemarks, string sysResAmt, string sysResRemarks, string debitBalanceLimit
                                , string limitExpiry, string accountCurrency, string accountSubGroup, string accountGroup
                                , string bill, string BankLetterRefNo, string branch) {
      string flag = string.IsNullOrEmpty(id) ? "i" : "u";
      string sql = "EXEC spa_acmaster @flag=" + FilterString(flag) + "";
      sql += " ,@user=" + FilterString(user);
      sql += " ,@acct_id=" + FilterString(id);
      sql += " ,@gl_code=" + FilterString(gl_code);
      sql += " ,@acct_num=" + FilterString(accountNum);
      sql += " ,@acct_name=" + FilterString(accountName);
      sql += " ,@acct_rpt_code=" + FilterString(accountReportCode);
      sql += " ,@acct_ownership=" + FilterString(accountOwnership);
      sql += " ,@frez_ref_code=" + FilterString(freezeCode);
      sql += " ,@agent_id=" + FilterString(agent);
      sql += " ,@lien_amt=" + FilterString(lAmt);
      sql += " ,@lien_remarks=" + FilterString(lRemarks);
      sql += " ,@system_reserved_amt=" + FilterString(sysResAmt);
      sql += " ,@system_reserver_remarks=" + FilterString(sysResRemarks);
      sql += " ,@dr_bal_lim=" + FilterString(debitBalanceLimit);
      sql += " ,@lim_expiry=" + FilterString(limitExpiry);
      sql += " ,@ac_currency=" + FilterString(accountCurrency);
      sql += " ,@ac_sub_group=" + FilterString(accountSubGroup);
      sql += " ,@ac_group=" + FilterString(accountGroup);
      sql += " ,@bill_bybill=" + FilterString(bill);
      sql += " ,@branch_id=" + FilterString(branch);
      return ParseDbResult(sql.ToString());
    }

    public DbResult UpdateAgentFund(string user, string id, string agent, string date, string amntCur, string rate) {
      string flag = string.IsNullOrEmpty(id) ? "new" : "update";
      string sql = "EXEC spa_acmaster @flag=" + FilterString(flag) + "";
      sql += " ,@user=" + FilterString(user);
      sql += " ,@id=" + FilterString(id);
      sql += " ,@agent=" + FilterString(agent);
      sql += " ,@date=" + FilterString(date);
      sql += " ,@amntCur=" + FilterString(amntCur);
      sql += " ,@rate=" + FilterString(rate);
      return ParseDbResult(sql.ToString());
    }
    public DataRow PupulateDataById(string accId) {
      string sql = "EXEC spa_acmaster @flag=" + FilterString("s") + "";
      sql += " ,@acct_id=" + FilterString(accId);
      return ExecuteDataRow(sql);
    }
  }
}
