using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class StateDao : RemittanceDao
    {
        public DbResult Update(string user, string stateId, string countryId, string stateCode, string stateName)
        {
            string sql = "EXEC proc_countryStateMaster";
            sql += " @flag = " + (stateId == "0" || stateId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @stateId = " + FilterString(stateId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @stateCode = " + FilterString(stateCode);
            sql += ", @stateName = " + FilterString(stateName);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string stateId)
        {
            string sql = "EXEC proc_countryStateMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @stateId = " + FilterString(stateId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string stateId)
        {
            string sql = "EXEC proc_countryStateMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @stateId = " + FilterString(stateId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateState(string user, string countryId)
        {
            string sql = "EXEC proc_states";
            sql += " @countryId = " + FilterString(countryId);
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}