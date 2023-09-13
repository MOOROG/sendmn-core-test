using System.Data;
using Swift.DAL.SwiftDAL;


namespace Swift.DAL.BL.System.GeneralSettings
{
    public class TxnMessageSettingDao : SwiftDao
    {
        public DbResult Update(string user, string id, string country, string service, string codeDesc, string paymentMethodDesc, string messageType, string isActive)
        {
            string sql = "EXEC proc_txnMessageSetup";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @country = N" + FilterString(country);
            sql += ", @service = N" + FilterString(service);
            sql += ", @codeDescription = N" + FilterString(codeDesc);
            sql += ", @paymentMethodDesc = N" + FilterString(paymentMethodDesc);
            sql += ", @msgFlag = " + FilterString(messageType);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string id)
        {
            string sql = "EXEC proc_txnMessageSetup";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_txnMessageSetup";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet SelectByFlag(string user, string msgFlag)
        {
            var sql = "EXEC proc_txnMessageSetup";
            sql += "  @flag = 'display'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgFlag = " + FilterString(msgFlag);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
    }
}