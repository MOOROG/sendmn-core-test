using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.Remittance.Transaction
{
    public class TranCalculator : RemittanceDao
    {
        public DataTable GetExRate(string user,string sSuperAgent, string sCountryId, string sAgent, string sBranch, string collCurr,
                                              string pCountryId, string pAgent, string pCurr, string deliveryMethod, string collAmt, string payAmt,
                                               string calculateBy)
        {
            var sql = "EXEC proc_sendIRH @flag = 'exRate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @collCurr = " + FilterString(collCurr);
            sql += ", @pCountryId = " + FilterString(pCountryId);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurr = " + FilterString(pCurr);
            sql += ", @deliveryMethod = " + FilterString(deliveryMethod);
            sql += ", @cAmt = " + FilterString(collAmt);
            sql += ", @pAmt = " + FilterString(payAmt);
            sql += ", @sSuperAgent = " + FilterString(sSuperAgent);
            //sql += ", @calculateBy = " + FilterString(calculateBy);
         
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public string GetCollCurrency(string user, string sCountryId)
        {
            var sql = "EXEC proc_tranCalculator @flag = 'collCurr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sCountryId = " + FilterString(sCountryId);

            return GetSingleResult(sql);
        }
    }
}
