using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
  public class FundTransferReceiptDao : SwiftDao
    {
      public DbResult Delete(string user, string rowId)
      {
          string sql = "EXEC proc_fundTransfer";
          sql += " @flag = 'd'";
          sql += ", @fundTrxId = " + rowId;
          sql += ", @user = " + FilterString(user);

          return ParseDbResult(ExecuteDataset(sql).Tables[0]);
      }
      public DbResult Update(long rowId, string user, string sagentId, string agentId, string amount, string trnDate, string remarks,string trnType)
      {
          string sql = "exec [proc_fundTransfer] @flag=" + (rowId == 0 ? "'i'" : "'u'");
          sql = sql + ", @fundTrxId=" + FilterString(rowId.ToString());
          sql = sql + ", @user=" + FilterString(user);
          sql = sql + ", @sAgent=" + FilterString(sagentId);
          sql = sql + ", @Agent=" + FilterString(agentId);
          sql = sql + ", @trnAmt = " + FilterString(amount);
          sql = sql + ", @trnDate = " + FilterString(trnDate);
          sql = sql + ", @remarks=" + FilterString(remarks);
          sql = sql + ", @trnType=" + FilterString(trnType);
          return ParseDbResult(ExecuteDataset(sql).Tables[0]);
      }
      public DataRow SelectById(string rowId)
      {
          string sql = "Exec proc_fundTransfer @flag='a',@fundTrxId=" + FilterString(rowId) + "";

          DataSet ds = ExecuteDataset(sql);
          if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
              return null;
          return ds.Tables[0].Rows[0];
      }
    }
}
