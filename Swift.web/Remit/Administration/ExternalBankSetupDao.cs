using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class ExternalBankSetupDao : SwiftDao
    {
        public DbResult Update(string user
                    , string externalBankId
                    , string parentId
                    , string agentType
                    , string agentName
                    , string agentCode
                    , string countryId
                    , string country
                    , string location
                    , string address
                    , string phone
                    , string mapCodeInt
                    , string mapCodeDom
                    , string extCode
                    , string swiftCode
                    , string routingCode
                    , string isHeadOffice
                    , string isBlocked)
        {
            string sql = "EXEC [proc_externalBankSetup]";
            sql += "  @flag = " + (externalBankId == "0" || externalBankId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(externalBankId);
            sql += ", @parentId = " + FilterString(parentId);
            sql += ", @agentType = " + FilterString(agentType);
            sql += ", @agentName = " + FilterString(agentName);
            sql += ", @agentCode = " + FilterString(agentCode);
            sql += ", @agentCountryId = " + FilterString(countryId);
            sql += ", @agentCountry = " + FilterString(country);
            sql += ", @agentLocation = " + FilterString(location);
            sql += ", @agentAddress = " + FilterString(address);
            sql += ", @agentPhone = " + FilterString(phone);
            sql += ", @mapCodeInt = " + FilterString(mapCodeInt);
            sql += ", @mapCodeDom = " + FilterString(mapCodeDom);
            sql += ", @extCode = " + FilterString(extCode);
            sql += ", @swiftCode = " + FilterString(swiftCode);
            sql += ", @routingCode = " + FilterString(routingCode);
            sql += ", @isHeadOffice = " + FilterString(isHeadOffice);
            sql += ", @isBlocked = " + FilterString(isBlocked);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string externalBankId)
        {
            string sql = "EXEC proc_externalBankSetup";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(externalBankId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string externalBankId)
        {
            string sql = "EXEC proc_externalBankSetup";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(externalBankId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public string SelectAgentNameById(string user, string agentId)
        {
            string sql = "select agentName from agentMaster where agentId=" + FilterString(agentId);

            return GetSingleResult(sql);
        }

        public DataRow SelectAgentInfoById(string user, string agentId)
        {
            string sql = "select agentName,agentCountry from agentMaster where agentId=" + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}