using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentOwnershipInfDao : SwiftDao
    {
        public DbResult Update(string user, string aoiId, string agentId, string ownerName, string ssn, string idType,
                               string idNumber, string issuingCountry, string expiryDate, string permanentAddress,
                               string country, string city, string state, string zip, string phone, string fax,
                               string mobile1, string mobile2, string email, string position, string shareHolding)
        {
            string sql = "EXEC proc_agentOwnershipInf";
            sql += " @flag = " + (aoiId == "0" || aoiId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @aoiId = " + FilterString(aoiId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @ownerName = " + FilterString(ownerName);
            sql += ", @ssn = " + FilterString(ssn);
            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNumber = " + FilterString(idNumber);
            sql += ", @issuingCountry = " + FilterString(issuingCountry);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            sql += ", @permanentAddress = " + FilterString(permanentAddress);
            sql += ", @country = " + FilterString(country);
            sql += ", @city = " + FilterString(city);
            sql += ", @state = " + FilterString(state);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @fax = " + FilterString(fax);
            sql += ", @mobile1 = " + FilterString(mobile1);
            sql += ", @mobile2 = " + FilterString(mobile2);
            sql += ", @email = " + FilterString(email);
            sql += ", @position = " + FilterString(position);
            sql += ", @shareHolding = " + FilterString(shareHolding);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string aoiId)
        {
            string sql = "EXEC proc_agentOwnershipInf";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @aoiId = " + FilterString(aoiId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string aoiId)
        {
            string sql = "EXEC proc_agentOwnershipInf";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @aoiId = " + FilterString(aoiId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }


        public DataRow PullDefaultValueById(string user, string parentAgentId)
        {
            string sql = "EXEC proc_agentOwnershipInf";
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