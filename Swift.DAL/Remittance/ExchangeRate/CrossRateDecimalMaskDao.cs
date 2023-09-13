using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class CrossRateDecimalMaskDao : RemittanceDao
    {
        public DbResult Delete(string user, string crdmId)
        {
            var sql = "EXEC proc_crossRateDecimalMask @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crdmId = " + FilterString(crdmId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Update(string user, string crdmId, string cCurrency, string pCurrency, string rateMaskAd, string displayUnit)
        {
            string sql = "EXEC proc_crossRateDecimalMask";
            sql += " @flag = " + (crdmId == "0" || crdmId == "" ? "'i'" : "'u'");
            sql += ", @crdmId = " + FilterString(crdmId);
            sql += ", @user = " + FilterString(user);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @rateMaskAd = " + FilterString(rateMaskAd);
            sql += ", @displayUnit = " + FilterString(displayUnit);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string crdmId)
        {
            var sql = "EXEC proc_crossRateDecimalMask @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crdmId = " + FilterString(crdmId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCurrency, string pCurrency)
        {
            var sql = "EXEC proc_crossRateDecimalMask @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCurrency = " + FilterString(pCurrency);

            return ExecuteDataset(sql);
        }
    }
}
