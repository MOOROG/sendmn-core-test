using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
  public  class MaintenancePlanDao : SwiftDao
    {
      public DbResult Update(string user, string mpId, string fromDate, string toDate, string msg, string reason,string isEnable)
        {
            string sql = "EXEC proc_maintenancePlan";
            sql += " @flag = " + (mpId == "0" || mpId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @mpId = " + FilterString(mpId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @msg = " + FilterString(msg);
            sql += ", @reason = " + FilterString(reason);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

      public DbResult Delete(string user, string mpId)
        {
            string sql = "EXEC proc_maintenancePlan";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mpId = " + FilterString(mpId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

      public DataRow SelectById(string user, string mpId)
        {
            string sql = "EXEC proc_maintenancePlan";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mpId = " + FilterString(mpId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

      public DataRow SelectByDate(string user)
      {
          string sql = "EXEC proc_maintenancePlan";
          sql += " @flag = 'dt'";
          sql += ", @user = " + FilterString(user);
   

          DataSet ds = ExecuteDataset(sql);
          if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
              return null;
          return ds.Tables[0].Rows[0];
      }

    }
}
