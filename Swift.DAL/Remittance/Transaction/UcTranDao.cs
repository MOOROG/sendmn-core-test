using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class UcTranDao : RemittanceDao
    {
        public DataSet SelectTransaction(string user, string controlNo, string tranId, string lockMode, string viewType, string viewMsg)
        {
            var sql = "EXEC proc_UcTranView @flag = 's'";
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
        public DbResult AddComment(string user, string controlNo, string tranId, string msg)
        {
            var sql = "EXEC proc_UcTranView @flag = 'ac'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @message = " + FilterString(msg);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataSet DisplayLog(string user, string controlNo, string tranId, string lockMode)
        {
            var sql = "EXEC proc_UcTranView @flag = 'showLog'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @lockMode = " + FilterString(lockMode);
            sql += ", @tranId = " + FilterString(tranId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet DisplayOFAC(string user, string controlNo, string tranId, string lockMode)
        {
            var sql = "EXEC proc_UcTranView @flag = 'OFAC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @lockMode = " + FilterString(lockMode);
            sql += ", @tranId = " + FilterString(tranId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet DisplayCompliance(string user, string controlNo, string tranId, string lockMode)
        {
            var sql = "EXEC proc_UcTranView @flag = 'Compliance'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @lockMode = " + FilterString(lockMode);
            sql += ", @tranId = " + FilterString(tranId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DbResult SaveApproveRemarksComplaince(string user, string controlNo, string tranId, string remarksComplaince, string remarksOFAC)
        {
            var sql = "EXEC proc_UcTranView @flag = 'saveComplainceRmks'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @messageComplaince = " + FilterString(remarksComplaince);
            sql += ", @messageOFAC = " + FilterString(remarksOFAC);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string checkFlagOFAC(string user, string controlNo, string tranId, string lockMode)
        {
            var sql = "EXEC proc_UcTranView @flag = 'chkFlagOFAC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @lockMode = " + FilterString(lockMode);
            sql += ", @tranId = " + FilterString(tranId);

            return GetSingleResult(sql);
        }
        public string checkFlagCompliance(string user, string controlNo, string tranId, string lockMode)
        {
            var sql = "EXEC proc_UcTranView @flag = 'chkFlagCOMPLAINCE'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @lockMode = " + FilterString(lockMode);
            sql += ", @tranId = " + FilterString(tranId);

            return GetSingleResult(sql);
        }
        public DbResult ResolveTxnComplain(string user, string tranIds)
        {
            var sql = "EXEC proc_tranComplainRpt @flag = 'rc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranIds);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet GetEmailFormat(string user, string tranId, string complain)
        {
            string sql = "EXEC proc_emailFormat @flag = 'C'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @message = " + FilterString(complain);

            return ExecuteDataset(sql);
        }
    }
}
