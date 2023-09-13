using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentContactPersonDao : SwiftDao
    {
        public DbResult Update(string user, string acpId, string agentId, string name, string country, string state,
                               string city, string zip, string address, string phone, string mobile1, string mobile2,
                               string fax, string email, string post, string contactPersonType, string isPrimary)
        {
            string sql = "EXEC proc_agentContactPerson";
            sql += " @flag = " + (acpId == "0" || acpId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @acpId = " + FilterString(acpId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @name = " + FilterString(name);
            sql += ", @country = " + FilterString(country);
            sql += ", @state = " + FilterString(state);
            sql += ", @city = " + FilterString(city);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @address = " + FilterString(address);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @mobile1 = " + FilterString(mobile1);
            sql += ", @mobile2 = " + FilterString(mobile2);
            sql += ", @fax = " + FilterString(fax);
            sql += ", @email = " + FilterString(email);
            sql += ", @post = " + FilterString(post);
            sql += ", @contactPersonType = " + FilterString(contactPersonType);
            sql += ", @isPrimary = " + FilterString(isPrimary);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string acpId)
        {
            string sql = "EXEC proc_agentContactPerson";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @acpId = " + FilterString(acpId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string acpId)
        {
            string sql = "EXEC proc_agentContactPerson";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @acpId = " + FilterString(acpId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow PullDefaultValueById(string user, string parentAgentId)
        {
            string sql = "EXEC proc_agentContactPerson";
            sql += " @flag = 'pullDefault'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(parentAgentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}