using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction {
  public class TranViewDao : RemittanceDao {
    public DataSet SelectTransactionApi(string user, string controlNo, string agentRefId) {
      var sql = "EXEC proc_searchTxnAPI @flag = 'details'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @agentRefId = " + FilterString(agentRefId);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet SelectTransaction(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg) {
      var sql = "EXEC proc_transactionView @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet SelectTransactionMod(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg) {
      var sql = "EXEC proc_transactionView @flag = 'modify'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet SelectPartnerTransaction(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg)// Add for search Partner transaction
        {
      var sql = "EXEC proc_PartnerPinView @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet SelectTransactionEduPay(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg) {
      var sql = "EXEC proc_transactionViewEduPay @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet SelectTransactionInt(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg, string ip, string dcInfo) {
      var sql = "EXEC proc_transactionViewInt @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);
      sql += ", @ip=" + FilterString(ip);
      sql += ", @dcInfo=" + FilterString(dcInfo);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DbResult AddComment(string user, string controlNo, string tranId, string msg) {
      var sql = "EXEC proc_transactionView @flag = 'ac'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @message = N" + FilterString(msg);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }




    public DataRow AddCommentApi(string user, string agentRefId, string controlNo, string tranId, string msg, string sendSmsEmail) {
      var sql = "EXEC proc_addCommentAPI @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @agentRefId = " + FilterString(agentRefId);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @message = " + FilterString(msg);
      sql += ", @sendSmsEmail = " + FilterString(sendSmsEmail);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }


    public DataRow AddCommentApiInt(string user, string controlNo, string msg) {
      var sql = "EXEC proc_addCommentAPI @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @message = " + FilterString(msg);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DataSet DisplayLog(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'showLog'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet DisplayOFAC(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'OFAC'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet DisplayCompliance(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'Compliance'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet DisplayCashLimitHold(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'CashLimitHold'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DbResult SaveApproveRemarksComplaince(string user, string controlNo, string tranId, string remarksComplaince, string remarksOFAC, string remarksCashLimitHold, string cashHoldLimitFlag = "") {
      var sql = "EXEC proc_transactionView @flag = " + (string.IsNullOrEmpty(cashHoldLimitFlag) ? "'saveComplainceRmks'" : FilterString(cashHoldLimitFlag));
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @messageComplaince = " + FilterString(remarksComplaince);
      sql += ", @messageOFAC = " + FilterString(remarksOFAC);
      sql += ", @messageCashLimitHold = " + FilterString(remarksCashLimitHold);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public string checkFlagOFAC(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'chkFlagOFAC'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      return GetSingleResult(sql);
    }
    public string checkFlagCompliance(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'chkFlagCOMPLAINCE'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      return GetSingleResult(sql);
    }
    public string checkFlagCashLimitHold(string user, string controlNo, string tranId, string lockMode) {
      var sql = "EXEC proc_transactionView @flag = 'chkFlagCashLimitHold'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @lockMode = " + FilterString(lockMode);
      sql += ", @tranId = " + FilterString(tranId);

      return GetSingleResult(sql);
    }

    public DbResult ResolveTxnComplain(string user, string tranIds) {
      var sql = "EXEC proc_tranComplainRpt @flag = 'rc'";
      sql += ", @user = " + FilterString(user);
      sql += ", @tranId = " + FilterString(tranIds);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataSet GetEmailFormat(string user, string flag, string filterKey, string controlNo, string complain) {
      string sql = "EXEC proc_emailFormat";
      sql += " @flag = " + FilterString(flag);
      sql += ", @user = " + FilterString(user);
      sql += ", @filterKey = " + FilterString(filterKey);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @message = " + FilterString(complain);

      return ExecuteDataset(sql);
    }

    public DataSet DisplayMatchTran(string user, string searchByText, string searchBy, string fromDate, string controlNo, string tranId, string toDate = "", string statusVal = "All") {
      var sql = "EXEC proc_FindTransaction ";
      if (statusVal.Equals("Uncommit")) {
        sql += " @flag = 'uncommit'";
      } else {
        sql += " @flag = 'A'";
      }
      sql += ", @user = " + FilterString(user);
      sql += ", @searchByText = " + FilterString(searchByText);
      sql += ", @searchBy = " + FilterString(searchBy);
      sql += ", @fromDate = " + FilterString(fromDate);
      sql += ", @controlNo = " + FilterString(controlNo);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @toDate = " + FilterString(toDate);
      sql += ", @statusVal = " + FilterString(statusVal);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet SearchApiTransaction(string user, string controlNo) {
      var sql = "EXEC proc_searchTxnOldAPI_TEST @flag='Search'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet SearchApiTransactionByOther(string user, string criteria, string value) {
      var sql = "EXEC proc_searchTxnOldAPI_TEST @flag='Search'";
      sql += ", @user = " + FilterString(user);
      sql += ", @criteria = " + FilterString(criteria);
      sql += ", @value = " + FilterString(value);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet SearchApiTranTroubleTicket(string user, string controlNo) {
      var sql = "EXEC proc_searchTxnOldAPI_TEST @flag='SearchTicket'";
      sql += ", @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    public DataSet LockTransactionByCustIdApi(string user, string customerId) {
      var sql = "EXEC proc_searchTxnOldAPI_TEST @flag='SEARCHBYCUS'";
      sql += ", @user = " + FilterString(user);
      sql += ", @value = " + FilterString(customerId);

      DataSet ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }
    public DataSet SelectTxnModificationAgent(string user, string tranId, string viewType, string viewMsg, string ip, string dcInfo) {
      var sql = "EXEC proc_transactionView @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @viewType = " + FilterString(viewType);
      sql += ", @viewMsg = " + FilterString(viewMsg);
      sql += ", @ip=" + FilterString(ip);
      sql += ", @dcInfo=" + FilterString(dcInfo);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    #region for CancelTxnReceipt
    public DataSet SelectCancelTransactionReceipt(string user, string controlNo) {
      var sql = "EXEC proc_CancelTxnReceipt";
      sql += " @user = " + FilterString(user);
      sql += ", @controlNo = " + FilterString(controlNo);

      var ds = ExecuteDataset(sql);
      if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds;
    }

    #endregion


    public DataTable SelectVoucherDetail(string user, string tranNo) {
      var sql = "EXEC proc_transactionView @flag = 'voucher'";
      sql += ", @user = " + FilterString(user);
      sql += ", @tranId = " + FilterString(tranNo);

      return ExecuteDataTable(sql);
    }

    public DbResult ManageInquiry(string User, string MobileNo, string msgType, string comments, string Country) {
      var sql = "EXEC proc_CustomerInquiry @flag = 'i'";
      sql += ", @user = " + FilterString(User);
      sql += ", @MobileNo = " + FilterString(MobileNo);
      sql += ", @msgType = " + FilterString(msgType);
      sql += ", @complian = " + FilterString(comments);
      sql += ", @Country = " + FilterString(Country);

      return ParseDbResult(sql);
    }

    public DataTable ViewInquiry(string User, string MobileNo) {
      var sql = "EXEC proc_CustomerInquiry @flag = 's'";
      sql += ", @user = " + FilterString(User);
      sql += ", @MobileNo = " + FilterString(MobileNo);

      return ExecuteDataTable(sql);
    }
    public DataTable QuestionaireExists(string User, string holdTranId) {
      var sql = "EXEC proc_transactionView @flag = 'questionaire-available'";
      sql += ", @user = " + FilterString(User);
      sql += ", @holdTranId = " + FilterString(holdTranId);

      return ExecuteDataTable(sql);
    }
    public DbResult CheckTranInBothRule(string @user, string TranId) {
      var sql = "EXEC proc_transactionView @flag = 'checkTran'";
      sql += ", @user = " + FilterString(@user);
      sql += ", @TranId = " + FilterString(TranId);

      return ParseDbResult(sql);
    }
  }
}
