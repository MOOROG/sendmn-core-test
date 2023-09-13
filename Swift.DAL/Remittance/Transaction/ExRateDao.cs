using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class ExRateDao : RemittanceDao
    {
        public DataRow View(string user, string agentId, string collCurrency, string payCountry, string payCurrency, string tranType)
        {
            //exec proc_exRateAgent @flag='v',@agentId='3885',@cCurrency='MYR',@pCountry='151',@pCurrency='NPR',@tranType='1'
            string sql = "EXEC proc_exRateAgent";
            sql += "  @flag = 'v'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @cCurrency = " + FilterString(collCurrency);
            sql += ", @pCountry = " + FilterString(payCountry);
            sql += ", @pCurrency = " + FilterString(payCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow GetBankExrateData()
        {
            string sql = "EXEC proc_BankExrate";
            sql += "  @flag = 's'";

            return ExecuteDataRow(sql);
        }

        public DbResult UpdateRate(string customerRate, string sc, string user)
        {
            string sql = "EXEC proc_BankExrate";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @custRate = " + FilterString(customerRate);
            sql += ", @serviceCharge = " + FilterString(sc);

            return ParseDbResult(sql);
        }
    }
}
