using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class MobileFormatDao : SwiftDao
    {
        #region Mobile Format

        public DbResult UpdateMblFormat(string user, string mobileFormatId, string countryId, string ISDCountryCode,
                                        string mobileLen)
        {
            string sql = "EXEC proc_mobileFormat";
            sql += " @flag = " + (mobileFormatId == "0" || mobileFormatId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @mobileFormatId = " + FilterString(mobileFormatId);

            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @ISDCountryCode = " + FilterString(ISDCountryCode);
            sql += ", @mobileLen = " + FilterString(mobileLen);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdMblFormat(string user, string countryId)
        {
            string sql = "EXEC proc_mobileFormat";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion

        #region Mobile Operator

        public DbResult UpdateMblOperator(string user, string mobileOperatorId, string countryId, string mblOperator,
                                          string prefix,string mobileLen)
        {
            string sql = "EXEC proc_mobileOperator";
            sql += " @flag = " + (mobileOperatorId == "0" || mobileOperatorId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @mobileOperatorId = " + FilterString(mobileOperatorId);

            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @operator = " + FilterString(mblOperator);
            sql += ", @mobileLen = " + FilterString(mobileLen);
            sql += ", @prefix = " + FilterString(prefix);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteMblOperator(string user, string mobileOperatorId)
        {
            string sql = "EXEC proc_mobileOperator";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mobileOperatorId = " + FilterString(mobileOperatorId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string mobileOperatorId)
        {
            string sql = "EXEC proc_mobileOperator";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @mobileOperatorId = " + FilterString(mobileOperatorId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion

        public DataTable PopulateOperator(string countryId)
        {
            string sql = "EXEC proc_mobileOperator @flag = 's', @countryId = " + FilterString(countryId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable PopulateGridData(string qry)
        {
            string sql = qry;

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
    }
}