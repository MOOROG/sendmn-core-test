using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.AccountReport {
  public class DayBookReportDAO : SwiftDao {
    public DataTable GetDayBookReport(string fromDate, string toDate, string vType, string agentType, string showType = "manual") {
      var sql = "Exec proc_daybook @startdt =" + FilterString(fromDate);
      sql += " ,@enddt = " + FilterString(toDate);
      sql += " ,@vouchertype = " + FilterString(vType);
      sql += " ,@showType = " + FilterString(showType);
      sql += " ,@agentType = " + FilterString(agentType);
      sql += " ,@company_id = 1";

      return ExecuteDataTable(sql);
    }

    public DataSet GetDayBookReportUser(string fromDate, string toDate, string vType, string userName) {
      var sql = "Exec procVoucherDetail @flag = 'b'";
      sql += ",@StartDate =" + FilterString(fromDate);
      sql += ",@EndDate =" + FilterString(toDate);
      sql += ",@TranType =" + FilterString(vType);
      sql += ",@UserID =" + FilterString(userName);

      return ExecuteDataset(sql);


    }
    public DbResult DeleteAcctDetail(string acct_id, string user) {
      string sql = "Exec [proc_accountStatement]";
      sql += " @flag ='d'";
      sql += ", @acct_id=" + FilterString(acct_id);
      sql += ", @user=" + FilterString(user);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

  }
}