using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit
{
    public class ReceiveTranLimitDao : RemittanceDao
    {
        #region -- Previous Function --
        //public DbResult Update(string user, string rtlId, string agentId, string countryId, string userId,
        //                       string sendingCountry, string maxLimitAmt, string agMaxLimitAmt, string currency, string tranType,
        //                       string customerType)
        //{
        //    string sql = "EXEC proc_receiveTranLimit";
        //    sql += " @flag = " + (rtlId == "0" || rtlId == "" ? "'i'" : "'u'");
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @rtlId = " + FilterString(rtlId);

        //    sql += ", @agentId = " + FilterString(agentId);
        //    sql += ", @countryId = " + FilterString(countryId);
        //    sql += ", @userId = " + FilterString(userId);
        //    sql += ", @sendingCountry = " + FilterString(sendingCountry);
        //    sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
        //    sql += ", @agMaxLimitAmt = " + FilterString(agMaxLimitAmt);
        //    sql += ", @currency = " + FilterString(currency);
        //    sql += ", @tranType = " + FilterString(tranType);
        //    sql += ", @customerType = " + FilterString(customerType);
        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}

        //public DbResult Delete(string user, string rtlId)
        //{
        //    string sql = "EXEC proc_receiveTranLimit";
        //    sql += " @flag = 'd'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @rtlId = " + FilterString(rtlId);

        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}

        //public DataRow SelectById(string user, string rtlId)
        //{
        //    string sql = "EXEC proc_receiveTranLimit";
        //    sql += " @flag = 'a'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @rtlId = " + FilterString(rtlId);

        //    DataSet ds = ExecuteDataset(sql);
        //    if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        //        return null;
        //    return ds.Tables[0].Rows[0];
        //}

        #endregion

        public DbResult Update(string user, string rtlId, string agentId, string countryId, string userId,
                               string sendingCountry, string maxLimitAmt, string agMaxLimitAmt, string currency, string tranType,
                               string customerType, string branchSelection, string benificiaryIdReq, string relationshipReq,
                               string benificiaryContactReq, string acLengthFrom, string acLengthTo, string acNumberType)
        {
            string sql = "EXEC proc_receiveTranLimit";
            sql += " @flag = " + (rtlId == "0" || rtlId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rtlId = " + FilterString(rtlId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @sendingCountry = " + FilterString(sendingCountry);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @agMaxLimitAmt = " + FilterString(agMaxLimitAmt);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @customerType = " + FilterString(customerType);

            sql += ", @branchSelection = " + FilterString(branchSelection);
            sql += ", @benificiaryIdReq = " + FilterString(benificiaryIdReq);
            sql += ", @relationshipReq = " + FilterString(relationshipReq);
            sql += ", @benificiaryContactReq = " + FilterString(benificiaryContactReq);
            sql += ", @acLengthFrom = " + FilterString(acLengthFrom);
            sql += ", @acLengthTo = " + FilterString(acLengthTo);
            sql += ", @acNumberType = " + FilterString(acNumberType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateCountryWise(string user, string rtlId, string agentId, string countryId, string userId,
                               string sendingCountry, string maxLimitAmt, string agMaxLimitAmt, string currency, string tranType,
                               string customerType, string branchSelection, string benificiaryIdReq, string relationshipReq,
                               string benificiaryContactReq)
        {
            string sql = "EXEC proc_receiveTranLimit";
            sql += " @flag = " + (rtlId == "0" || rtlId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rtlId = " + FilterString(rtlId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @sendingCountry = " + FilterString(sendingCountry);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @agMaxLimitAmt = " + FilterString(agMaxLimitAmt);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @customerType = " + FilterString(customerType);

            sql += ", @branchSelection = " + FilterString(branchSelection);
            sql += ", @benificiaryIdReq = " + FilterString(benificiaryIdReq);
            sql += ", @relationshipReq = " + FilterString(relationshipReq);
            sql += ", @benificiaryContactReq = " + FilterString(benificiaryContactReq);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Delete(string user, string rtlId)
        {
            string sql = "EXEC proc_receiveTranLimit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rtlId = " + FilterString(rtlId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string rtlId)
        {
            string sql = "EXEC proc_receiveTranLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rtlId = " + FilterString(rtlId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public double GetCountryMaxLimit(string user, string agentId)
        {
            var sql = "EXEC proc_receiveTranLimit";
            sql += " @flag = 'cml'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            var value = GetSingleResult(sql);
            double maxLimit;
            double.TryParse(value, out maxLimit);
            return maxLimit;
        }
    }
}