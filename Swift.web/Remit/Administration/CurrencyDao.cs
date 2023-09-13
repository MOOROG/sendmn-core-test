using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class CurrencyDao : RemittanceDao
    {
        public DbResult Update(string user, string currencyId, string currencyCode, string isoNumeric, string currencyName,
                               string currencyDesc, string currencyDecimalName, string countAfterDecimal,
                               string roundNoDecimal, string factor, string rateMin, string rateMax)
        {
            string sql = "EXEC proc_currencyMaster";
            sql += " @flag = " + (currencyId == "0" || currencyId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @currencyId = " + FilterString(currencyId);

            sql += ", @currencyCode = " + FilterString(currencyCode);
            sql += ", @isoNumeric = " + FilterString(isoNumeric);
            sql += ", @currencyName = " + FilterString(currencyName);
            sql += ", @currencyDesc = " + FilterString(currencyDesc);
            sql += ", @currencyDecimalName = " + FilterString(currencyDecimalName);
            sql += ", @countAfterDecimal = " + FilterString(countAfterDecimal);
            sql += ", @roundNoDecimal = " + FilterString(roundNoDecimal);
            sql += ", @factor = " + FilterString(factor);
            sql += ", @rateMin = " + FilterString(rateMin);
            sql += ", @rateMax = " + FilterString(rateMax);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string currencyId)
        {
            string sql = "EXEC proc_currencyMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @currencyId = " + FilterString(currencyId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string currencyId)
        {
            string sql = "EXEC proc_currencyMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @currencyId = " + FilterString(currencyId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #region Currency Payout rounding

        public DbResult UpdateCurrRound(string user, string rowId, string currency, string place, string currDecimal, string tranType)
        {
            string sql = "EXEC proc_currencyPayoutRound";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @place = " + FilterString(place);
            sql += ", @currDecimal = " + FilterString(currDecimal);
            sql += ", @tranType = " + FilterString(tranType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteCurrRound(string user, string rowId)
        {
            string sql = "EXEC proc_currencyPayoutRound";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectCurrRoundById(string user, string rowId)
        {
            string sql = "EXEC proc_currencyPayoutRound";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion Currency Payout rounding
    }
}