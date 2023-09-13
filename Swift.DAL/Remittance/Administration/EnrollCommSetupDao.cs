using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class EnrollCommSetupDao : SwiftDao
    {
        public DbResult Update(string user,string enrollCommId, string agentId, string commRate)
        {
            string sql = "EXEC [proc_enrollCommSetup]";
            sql += " @flag = " + (enrollCommId == "0" || enrollCommId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @enrollCommId = " + FilterString(enrollCommId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @commRate = " + FilterString(commRate);


            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string enrollCommId)
        {
            string sql = "EXEC proc_enrollCommSetup";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @enrollCommId = " + FilterString(enrollCommId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string enrollCommId)
        {
            string sql = "EXEC proc_enrollCommSetup";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @enrollCommId = " + FilterString(enrollCommId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

    }
}