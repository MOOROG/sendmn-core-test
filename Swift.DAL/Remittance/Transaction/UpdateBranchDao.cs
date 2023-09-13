using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.DAL.Remittance.Transaction
{
    public class UpdateBranchDao : RemittanceDao
    {
        public DataTable GetBranchByBankAndCountry(string user, string flag, string countryId, string bankId)
        {
            var sql = "EXEC Proc_UpdateBranchCode @flag =" + FilterString(flag);
            sql += ", @pcountryId = " + FilterString(countryId);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];

        }
        public DataTable UpdateBranch(string user, string flag, string countryId, string bankId, string branchId, string branchCode,string editedBranchName)
        {
            var sql = "EXEC Proc_UpdateBranchCode @flag =" + FilterString(flag);
            sql += ", @pcountryId = " + FilterString(countryId);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @branchCode = " + FilterString(branchCode);
            sql += ", @editedBranchName = " + FilterString(editedBranchName);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];

        }
        public DataTable InsertBranch(string user, string flag, string countryId, string bankId, string branchName, string branchCode)
        {
            var sql = "EXEC Proc_UpdateBranchCode @flag =" + FilterString(flag);
            sql += ", @pcountryId = " + FilterString(countryId);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @branchName = " + FilterString(branchName);
            sql += ", @branchCode = " + FilterString(branchCode);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];

        }
        public DataTable LoadBank(string sCountryid, string pCountry, string collMode, string agentId, string flag, string user)
        {
            //var sql = "EXEC proc_dropDownLists @flag = 'collModeByCountry'";
            //sql += ", @param = " + FilterString(pCountry);

            var sql = "EXEC proc_sendPageLoadData @flag =" + FilterString(flag);
            sql += ", @countryId = " + FilterString(sCountryid);
            sql += ", @pCountryId = " + FilterString(pCountry);
            sql += ", @param = " + FilterString(collMode);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @user = " + FilterString(user);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }
    }
}
