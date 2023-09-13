using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit
{
    public class CreditLimitDao : RemittanceDao
    {
        public DbResult Update(string user, string crLimitId, string agentId, string currency, string limitAmt,
                             string perTopUpAmt, string maxLimitAmt, string expiryDate, string todaysAddedMaxLimit,
                             string perToupRequest, string maxTopupRequest)
        {
            string sql = "EXEC proc_creditLimit";
            sql += " @flag = " + (crLimitId == "0" || crLimitId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @limitAmt = " + FilterString(limitAmt);
            sql += ", @perTopUpAmt = " + FilterString(perTopUpAmt);
            sql += ", @maxLimitAmt = " + FilterString(maxLimitAmt);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            sql += ", @todaysAddedMaxLimit = " + FilterString(todaysAddedMaxLimit);
            sql += ", @perToupRequest = " + FilterString(perToupRequest);
            sql += ", @maxTopupRequest = " + FilterString(maxTopupRequest);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string crLimitId)
        {
            string sql = "EXEC proc_creditLimit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string crLimitId)
        {
            string sql = "EXEC proc_creditLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crLimitId = " + FilterString(crLimitId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, 
            string sortOrder, string hasChanged, string agentName, string agentCountry, string agentDistrict)
        {
            var sql = "EXEC proc_creditLimit @flag = 'simpleGrid'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @hasChanged = " + FilterString(hasChanged);
            sql += ", @agentName = " + FilterString(agentName);
            sql += ", @agentCountry = " + FilterString(agentCountry);
            sql += ", @agentDistrict = " + FilterString(agentDistrict);

            return ExecuteDataset(sql);
        }

        public DataRow SelectAgentAcDetail(string user, string agentId)
        {
            string sql = "EXEC proc_creditLimit @flag = 'detail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet SelectCreditLimitAuthority(string user)
        {
            var sql = "EXEC proc_topUpLimit @flag = 'cla'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        //Extra Limit Dao
        public DbResult UpdateExtraLimit(string user, string agentId, string todaysAddedMaxLimit)
        {
            string sql = "EXEC proc_extraLimit";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @extraLimit = " + FilterString(todaysAddedMaxLimit);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        
        public DataRow SelectByIdForExtraLimit(string user, string agentId)
        {
            string sql = "EXEC proc_extraLimit";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet ShowPedningRequest(string user, string agentId)
        {
            var sql = "EXEC proc_extraLimit @flag='s1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult ApproveExtraLimit(string user, string id)
        {
            string sql = "EXEC proc_extraLimit";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectExtraLimit(string user, string id)
        {
            string sql = "EXEC proc_extraLimit";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}