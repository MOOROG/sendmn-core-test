using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class RemitCalculatorDao : RemittanceDao
    {
        public DataRow Calculate(string user, string agentId, string collCurrency, string payCountry, string payCurrency, string tranType, string amount, string amountRec)
        {
            string sql = "EXEC proc_remitCalculator";
            sql += "  @flag = 'cal'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @collCurrency = " + FilterString(collCurrency);
            sql += ", @payCountryId = " + FilterString(payCountry);
            sql += ", @payCorrency = " + FilterString(payCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @amountRec = " + FilterString(amountRec);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    
    }
}
