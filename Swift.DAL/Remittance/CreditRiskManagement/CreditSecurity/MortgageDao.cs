using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity
{
    public class MortgageDao : RemittanceDao
    {
        public DbResult Update(string user, string mortgageId, string agentId, string regOffice, string mortgageRegNo,
                               string valuationAmount, string currency, string valuator, string valuationDate,
                               string propertyType, string plotNo, string owner, string country, string state,
                               string city, string zip, string address, string sessionId)
        {
            string sql = "EXEC proc_mortgage";
            sql += " @flag = " + (mortgageId == "0" || mortgageId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @mortgageId = " + FilterString(mortgageId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @regOffice = " + FilterString(regOffice);
            sql += ", @mortgageRegNo = " + FilterString(mortgageRegNo);
            sql += ", @valuationAmount = " + FilterString(valuationAmount);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @valuator = " + FilterString(valuator);
            sql += ", @valuationDate = " + FilterString(valuationDate);
            sql += ", @propertyType = " + FilterString(propertyType);
            sql += ", @plotNo = " + FilterString(plotNo);
            sql += ", @owner = " + FilterString(owner);
            sql += ", @country = " + FilterString(country);
            sql += ", @state = " + FilterString(state);
            sql += ", @city = " + FilterString(city);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @address = " + FilterString(address);
            sql += ", @sessionId = " + FilterString(sessionId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string mortgageId)
        {
            string sql = "EXEC proc_mortgage";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mortgageId = " + FilterString(mortgageId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string mortgageId)
        {
            string sql = "EXEC proc_mortgage";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mortgageId = " + FilterString(mortgageId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}