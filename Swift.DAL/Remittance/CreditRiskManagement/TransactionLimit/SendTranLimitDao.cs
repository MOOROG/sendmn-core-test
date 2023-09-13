using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.TransactionLimit
{
    public class SendTranLimitDao : RemittanceDao
    {
        #region -- Previous Function --
        //public DbResult Update(string user, string stlId, string agentId, string countryId, string userId,
        //                       string receivingCountry, string minLimitAmt, string maxLimitAmt, string currency, string tranType,
        //                       string paymentType, string customerType)
        //{
        //    string sql = "EXEC proc_sendTranLimit";
        //    sql += " @flag = " + (stlId == "0" || stlId == "" ? "'i'" : "'u'");
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @stlId = " + FilterString(stlId);

        //    sql += ", @agentId = " + FilterString(agentId);
        //    sql += ", @countryId = " + FilterString(countryId);
        //    sql += ", @userId = " + FilterString(userId);
        //    sql += ", @receivingCountry = " + FilterString(receivingCountry);
        //    sql += ", @minLimitAmt = " + FilterString(minLimitAmt);
        //    sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
        //    sql += ", @currency = " + FilterString(currency);
        //    sql += ", @tranType = " + FilterString(tranType);
        //    sql += ", @paymentType = " + FilterString(paymentType);
        //    sql += ", @customerType = " + FilterString(customerType);
        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}




        //public DbResult Delete(string user, string stlId)
        //{
        //    string sql = "EXEC proc_sendTranLimit";
        //    sql += " @flag = 'd'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @stlId = " + FilterString(stlId);

        //    return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        //}

        //public DataRow SelectById(string user, string stlId)
        //{
        //    string sql = "EXEC proc_sendTranLimit";
        //    sql += " @flag = 'a'";
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @stlId = " + FilterString(stlId);

        //    DataSet ds = ExecuteDataset(sql);
        //    if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        //        return null;
        //    return ds.Tables[0].Rows[0];
        //}

        #endregion

        public DbResult Update(string user, string stlId, string agentId, string countryId, string userId,
                            string receivingCountry, string receivingAgent, string minLimitAmt, string maxLimitAmt, string currency, string collMode, string tranType,
                            string customerType)
        {
            string sql = "EXEC proc_sendTranLimit";
            sql += " @flag = " + (stlId == "0" || stlId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @stlId = " + FilterString(stlId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @receivingCountry = " + FilterString(receivingCountry);
            sql += ", @receivingAgent = " + FilterString(receivingAgent);
            sql += ", @minLimitAmt = " + FilterString(minLimitAmt);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @collMode = " + FilterString(collMode);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @customerType = " + FilterString(customerType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApplyForAllCountry(string user, string agentId, string countryId, string userId,
                               string receivingCountry, string minLimitAmt, string maxLimitAmt, string currency, string collMode,
                               string tranType, string customerType)
        {
            string sql = "EXEC proc_sendTranLimit";
            sql += " @flag = 'iall'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @receivingCountry = " + FilterString(receivingCountry);
            sql += ", @minLimitAmt = " + FilterString(minLimitAmt);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @collMode = " + FilterString(collMode);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @customerType = " + FilterString(customerType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult Delete(string user, string stlId)
        {
            string sql = "EXEC proc_sendTranLimit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @stlId = " + FilterString(stlId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string stlId)
        {
            string sql = "EXEC proc_sendTranLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @stlId = " + FilterString(stlId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}