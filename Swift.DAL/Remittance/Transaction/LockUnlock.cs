using System;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class LockUnlock : RemittanceDao
    {
        public DbResult BlockTransaction(string user, string controlNo, string comments)
        {
            string sql = "EXEC proc_LockUnlockTransaction";
            sql += " @flag = 'lt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @comments = " + FilterString(comments);

            return ParseDbResult(sql);
        }
        public DbResult UnBlockTransaction(string user, string controlNo, string comments)
        {
            string sql = "EXEC proc_LockUnlockTransaction";
            sql += " @flag = 'ut'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @comments = " + FilterString(comments);

            return ParseDbResult(sql);
        }

        public DbResult UnLockTransaction(string user, string tranId)
        {
            string sql = "EXEC proc_unlockTransaction";
            sql += " @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranIds = " + FilterString(tranId);

            return ParseDbResult(sql);
        }

        public DbResult UnlockByControlNo(string user, string controlNo)
        {
            string sql = "EXEC proc_unlockTransaction";
            sql += " @flag = 'ut'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DbResult TranViewLog
                    (
                         string user
                        , string tranId
                        , string controlNo
                        , string remarks
                        , string tranViewType
                    )
        {
            string sql = "EXEC proc_tranViewHistory";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(sql);
        }

        public DataRow UpdatePayOrderApi(string user, string tranNo, string tranType)
        {
            string sql = "EXEC proc_UnlockTxnApi_NEW";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranNo = " + FilterString(tranNo);
            sql += ", @tranType = " + FilterString(tranType);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        
        public DataSet GetLockedTransaction(string user)
        {
            var sql = "EXEC proc_unlockTransaction @flag='dom_unpaid_ac'";
            sql += ", @user = " + FilterString(user);
            DataSet ds = ExecuteDataset(sql);
            return ds;
        }

        public DataSet LockTransactionListApi(string user)
        {
            var sql = "EXEC proc_UnlockTxnApi_NEW @flag='list'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet UnlockTransactionApiFromPayPage(string user, string controlNo)
        {
            string sql = "EXEC proc_UnlockTxnApi_NEW";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult UnlockTransaction(string user, string controlNo)
        {
            string sql = "EXEC proc_unlockTransaction";
            sql += " @flag = 'unlock'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DbResult PaidToUnpaidTxn(string user, string controlNo)
        {
            string sql = "EXEC proc_PaidToUnpaid";
            sql += " @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }
    }
}
