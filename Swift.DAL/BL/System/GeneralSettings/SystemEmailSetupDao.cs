using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class SystemEmailSetupDao : SwiftDao
    {

        public DbResult Update(string user, string id, string name, string email, string mobile, string agent, string isCancel,
            string isTrouble, string isAccount, string isXRate, string isSummary, string isBonus, string isEodRpt,string isbankGuaranteeExpiry, string country)
        {
            string sql = "EXEC proc_systemEmailSetup";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @name = " + FilterString(name);
            sql += ", @email = " + FilterString(email);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @isCancel = " + FilterString(isCancel);
            sql += ", @isTrouble = " + FilterString(isTrouble);
            sql += ", @isAccount = " + FilterString(isAccount);
            sql += ", @isXRate = " + FilterString(isXRate);
            sql += ", @isSummary = " + FilterString(isSummary);
            sql += ", @isBonus = " + FilterString(isBonus);
            sql += ", @isEodRpt = " + FilterString(isEodRpt);
            sql += ", @isbankGuaranteeExpiry = " + FilterString(isbankGuaranteeExpiry);            
            sql += ", @country = " + FilterString(country);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string id)
        {
            string sql = "EXEC proc_systemEmailSetup";
            sql += " @flag = 'd'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_systemEmailSetup";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet GetEmailFormat(string user, string flag, string filterKey, string controlNo, string complain)
        {
            string sql = "EXEC proc_emailFormat";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @filterKey = " + FilterString(filterKey);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @message = " + FilterString(complain);

            return ExecuteDataset(sql);
        }

        public DataSet GetDataForEmail(string user, string flag, string controlNo, string complain)
        {
            string sql = "EXEC proc_emailData";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @complain = " + FilterString(complain);

            return ExecuteDataset(sql);
        }

        public DataSet GetDataForEodEmail(string user, string flag, string branchId)
        {
            string sql = "EXEC proc_emailData";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            return ExecuteDataset(sql);
        }

        public DataRow GetSmtpCredential(string user,string flag)
        {
            string sql = "EXEC proc_emailData";
            sql += " @flag = "+FilterString(flag);
            sql += ",@user = " + FilterString(user);
            return ExecuteDataRow(sql);
        }
    }
}