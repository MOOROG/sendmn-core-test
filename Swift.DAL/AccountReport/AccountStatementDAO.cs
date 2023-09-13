using Swift.DAL.Library;
using Swift.DAL.Model;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.DAL.AccountReport {
  public class AccountStatementDAO : SwiftDao {
    public DataTable GetACStatement(string acNumber, string startDate, string endDate, string Currency, string RptType, string user) {
      var sql = "Exec spa_branchstatement @flag = " + FilterString(RptType);
      sql += " ,@acnum = " + FilterString(acNumber);
      sql += " ,@startDate = " + FilterString(startDate);
      sql += " ,@endDate = " + FilterString(endDate);
      sql += " ,@Currency = " + FilterString(Currency);
      sql += " ,@user = " + FilterString(user);
      sql += " ,@company_id = '1'";

      return ExecuteDataTable(sql);
    }

    public List<StatementModel> GetACStatementNewAjaxForAgent(string acNumber, string startDate, string endDate, string Currency, string RptType, string user) {
      var sql = "Exec spa_branchstatement @flag = " + FilterString(RptType);
      sql += " ,@user = " + FilterString(user);
      sql += " ,@acnum = " + FilterString(acNumber);
      sql += " ,@startDate = " + FilterString(startDate);
      sql += " ,@endDate = " + FilterString(endDate);
      sql += " ,@Currency = " + FilterString(Currency);
      sql += " ,@company_id = '1'";

      var dt = ExecuteDataTable(sql);

      List<StatementModel> items = new List<StatementModel>();
      foreach (DataRow item in dt.Rows) {
        StatementModel model = new StatementModel {
          tran_particular = item["tran_particular"].ToString(),
          fcy_Curr = item["fcy_Curr"].ToString(),
          tran_amt = item["tran_amt"].ToString(),
          usd_amt = item["usd_amt"].ToString(),
          tran_date = item["tran_date"].ToString(),
          acc_num = item["acc_num"].ToString(),
          tran_type = item["tran_type"].ToString(),
          part_tran_type = item["part_tran_type"].ToString(),
          dt = item["dt"].ToString(),
          ref_num = item["ref_num"].ToString()
        };

        items.Add(model);
      }

      return items;
    }

    public List<StatementModel> GetACStatementNewAjax(string acNumber, string startDate, string endDate, string Currency, string RptType, bool hasRight) {
      var sql = "Exec spa_branchstatement @flag = " + FilterString(RptType);
      sql += " ,@acnum = " + FilterString(acNumber);
      sql += " ,@startDate = " + FilterString(startDate);
      sql += " ,@endDate = " + FilterString(endDate);
      sql += " ,@Currency = " + FilterString(Currency);
      sql += " ,@company_id = '1'";

      var dt = ExecuteDataTable(sql);

      List<StatementModel> items = new List<StatementModel>();
      foreach (DataRow item in dt.Rows) {
        if (acNumber.Equals("1000006") && item["tran_particular"].ToString().StartsWith("Remittance Send Voucher RefNo"))
          continue;
        StatementModel model = new StatementModel {
          tran_particular = item["tran_particular"].ToString(),
          fcy_Curr = item["fcy_Curr"].ToString(),
          tran_amt = item["tran_amt"].ToString(),
          usd_amt = item["usd_amt"].ToString(),
          tran_date = item["tran_date"].ToString(),
          acc_num = item["acc_num"].ToString(),
          tran_type = item["tran_type"].ToString(),
          part_tran_type = item["part_tran_type"].ToString(),
          dt = item["dt"].ToString(),
          ref_num = item["ref_num"].ToString(),
          hasRight = hasRight
        };

        items.Add(model);
      }

      return items;
    }

    public DbResult GetBalance(string user, string referralCode) {
      var sql = "EXEC PROC_AGENT_COMM_ENTRY";
      sql += " @FLAG ='B'";
      sql += ",@USER =" + FilterString(user);
      sql += ",@REFERRAL_CODE =" + FilterString(referralCode);

      return ParseDbResult(sql);
    }

    public DataTable UploadVoucher(string user, string sessionId, string xml) {
      var sql = "EXEC PROC_CUSTOMER_DEPOSIT_VOUCHER";
      sql += " @FLAG ='UPLOAD'";
      sql += ",@USER = " + FilterString(user);
      sql += ",@XML = N'" + xml + "'";
      sql += ",@SESSION_ID =" + FilterString(sessionId);

      return ExecuteDataTable(sql);
    }

    public DbResult CheckUploadVoucher(string user, string xml) {
      var sql = "EXEC PROC_CUSTOMER_DEPOSIT_VOUCHER";
      sql += " @FLAG ='CHECK'";
      sql += ",@USER = " + FilterString(user);
      sql += ",@XML = N'" + xml + "'";

      return ParseDbResult(sql);
    }

    public DbResult PayAgentComm(string user, string amountVal, string tDateVal, string branch, string introducer, string narration = "") {
      var sql = "EXEC PROC_AGENT_COMM_ENTRY";
      sql += " @FLAG ='I'";
      sql += ",@USER =" + FilterString(user);
      sql += ",@REFERRAL_CODE =" + FilterString(introducer);
      sql += ",@RECEIVER_ACC_NUM =" + FilterString(branch);
      sql += ",@AMOUNT =" + FilterString(amountVal);
      sql += ",@TRAN_DATE =" + FilterString(tDateVal);
      sql += ",@NARRATION =" + FilterString(narration);

      return ParseDbResult(sql);
    }

    public DbResult TransitCashManagement(string user, string amountVal, string tDateVal, string paymentMode, string branch, string introducer, string narration = "") {
      var sql = "EXEC PROC_TRANSIT_CASH_MANAGEMENT";
      sql += " @FLAG ='I'";
      sql += ",@USER =" + FilterString(user);
      sql += ",@REFERRAL_CODE =" + FilterString(introducer);
      sql += ",@RECEIVING_MODE =" + FilterString(paymentMode);
      sql += ",@RECEIVER_ACC_NUM =" + FilterString(branch);
      sql += ",@AMOUNT =" + FilterString(amountVal);
      sql += ",@TRAN_DATE =" + FilterString(tDateVal);
      sql += ",@NARRATION =" + FilterString(narration);

      return ParseDbResult(sql);
    }

    public DbResult AgentCommisionEntry(string user, string amountVal, string tDateVal, string branch, string introducer, string narration = "") {
      var sql = "EXEC PROC_AGENT_COMMISION_ENTRY";
      sql += " @FLAG ='I'";
      sql += ",@USER =" + FilterString(user);
      sql += ",@REFERRAL_CODE =" + FilterString(introducer);
      sql += ",@RECEIVER_ACC_NUM =" + FilterString(branch);
      sql += ",@AMOUNT =" + FilterString(amountVal);
      sql += ",@TRAN_DATE =" + FilterString(tDateVal);
      sql += ",@NARRATION =" + FilterString(narration);

      return ParseDbResult(sql);
    }

    public DbResult VaultTransferAdmin(string user, string amountVal, string tDateVal, string paymentMode, string toAcc, string fromAcc) {
      var sql = "EXEC PROC_";
      sql += " @FLAG ='I'";
      sql += ",@USER =" + FilterString(user);
      sql += ",@AMOUNT =" + FilterString(amountVal);
      sql += ",@TRAN_DATE =" + FilterString(tDateVal);
      sql += ",@RECEIVING_MODE =" + FilterString(paymentMode);
      sql += ",@RECEIVING_BANK_BRANCH =" + FilterString(toAcc);
      sql += ",@REFERRAL_CODE =" + FilterString(fromAcc);

      return ParseDbResult(sql);
    }

    public DataRow GetAccountNumber(string user, string type, string agentId) {
      var sql = "Exec balancesheetDrilldown2 @flag = 'acc' ";
      sql += " ,@type = " + FilterString(type);
      sql += " ,@user = " + FilterString(user);
      sql += " ,@agentId = " + FilterString(agentId);
      sql += " ,@company_id = '1'";

      return ExecuteDataRow(sql);
    }

    public DataTable GetSubLedgerReport(string mapcode, string treeSape, string rdate, string date) {
      var sql = "Exec balancesheetDrilldown2 @flag = '2' ";
      sql += " ,@mapcode = " + FilterString(mapcode);
      sql += " ,@tree_sape = " + FilterString(treeSape);
      sql += " ,@date2 = " + FilterString(rdate);
      sql += " ,@date = " + FilterString(date);
      sql += " ,@company_id = '1'";

      return ExecuteDataTable(sql);
    }

    public DataTable GetGLReport(string mapcode, string date, string bsDtl = "") {
      var sql = "Exec balancesheetDrilldown2 @flag = '1' ";
      sql += " ,@mapcode = " + FilterString(mapcode);
      sql += " ,@date2 = " + FilterString(date);
      sql += " ,@company_id = '1'";
      sql += ",@bsDtl = " + FilterString(bsDtl);
      DataTable retDt = ExecuteDataTable(sql);
      if (!string.IsNullOrEmpty(bsDtl)) {
        for (int i = 0; i < 14; i++) {
          DateTime dt = DateTime.Parse(date).AddDays(-(i + 1));
          var sql1 = "Exec balancesheetDrilldown2 @flag = '1' ";
          sql1 += " ,@mapcode = " + FilterString(mapcode);
          sql1 += " ,@date2 = " + FilterString(dt.ToString("yyyy-MM-dd"));
          sql1 += " ,@company_id = '1'";
          sql1 += ",@bsDtl = " + FilterString(bsDtl);
          DataRow ndtb = ExecuteDataRow(sql1);
          retDt.Rows.Add(ndtb.ItemArray);
        }
      }
      return retDt;
    }

    public DataTable GetSubLedgerReport2(string mapcode, string date, string date2) {
      var sql = "Exec balancesheetDrilldown2 @flag = '3' ";
      sql += " ,@mapcode = " + FilterString(mapcode);
      sql += " ,@date = " + FilterString(date);
      sql += " ,@date2 = " + FilterString(date2);
      sql += " ,@company_id = '1'";

      return ExecuteDataTable(sql);
    }

    public DataTable GetBalancesheetReport(string reportDate) {
      var sql = "Exec procBalancesheet @flag = 'b'";
      sql += " ,@company_id = '1'";
      sql += " ,@date1 = " + FilterString(reportDate);

      return ExecuteDataTable(sql);
    }

    public DataTable GetPLReport(string plDate, string plDate2) {
      var sql = "Exec procBalancesheet @flag = 'p'";
      sql += " ,@company_id = '1'";
      sql += " ,@date1 = " + FilterString(plDate);
      sql += " ,@date2 = " + FilterString(plDate2);

      return ExecuteDataTable(sql);
    }

    public DataTable GetACStatementConditional(string acNumber, string startDate, string endDate, string condition, string condition_value) {
      var sql = "Exec procAccountStatementFilter ";
      sql += " @acnum = " + FilterString(acNumber);
      sql += " ,@startDate = " + FilterString(startDate);
      sql += " ,@endDate = " + FilterString(endDate);
      sql += " ,@condition = " + FilterString(condition);
      sql += " ,@condition_value = " + FilterString(condition_value);

      return ExecuteDataTable(sql);
    }

    public DataTable GetUserReportResultSingle(string tranNum, string tranDate, string voucherType) {
      var sql = "EXEC procUserStatement @flag='t' ";
      sql += " ,@user = " + FilterString(tranNum);
      sql += " ,@startDate = " + FilterString(tranDate);
      sql += " ,@vouchertype = " + FilterString(voucherType);

      return ExecuteDataTable(sql);
    }

    public DataTable GetTrialBalance(string startDate, string endDate, string reportType) {
      var sql = "EXEC procTrialBalanceReport @flag =" + FilterString(reportType);
      sql += ",@date =" + FilterString(startDate);
      sql += ",@date2 =" + FilterString(endDate);
      sql += ",@company_id = '1'";

      return ExecuteDataTable(sql);
    }

    public DataTable GetStatementResultDollor(string acNumber, string startDate, string endDate) {
      var sql = "Exec ProcBranchstatementDollor @flag='a' ";
      sql += " ,@acnum = " + FilterString(acNumber);
      sql += " ,@startDate = " + FilterString(startDate);
      sql += " ,@endDate = " + FilterString(endDate);
      sql += " ,@company_id = '1'";

      return ExecuteDataTable(sql);
    }

    public DbResult GetVoucherReverse(string tran_num, string vouchertype, string User, string TxnDate, string Narration) {
      var sql = "Exec proc_EditVoucher @flag='REVERSE' ";
      sql += " ,@refNum = " + FilterString(tran_num);
      sql += " ,@vType = " + FilterString(vouchertype);
      sql += " ,@User = " + FilterString(User);
      sql += " ,@date = " + FilterString(TxnDate);
      sql += " ,@remarks = " + FilterString(Narration);

      return ParseDbResult(sql);
    }

    public DbResult PerformEOD(string User) {
      var sql = "Exec " + GetUtilityDAO.RemitDbName() + ".dbo.PROC_CASH_MANAGEMENT_REPORT @flag='EOD' ";
      sql += " ,@User = " + FilterString(User);

      return ParseDbResult(sql);
    }
  }
}