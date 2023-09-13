using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.Remittance.CashAndVault
{
    public class CashAndVaultDao : RemittanceDao
    {
        public DataTable SaveCashAndVault(string user, string agentId, string cashLimit, string perTopUpLimitVal, string ruleType, string ruleId)
        {
            string sql = "EXEC PROC_CASHANDVAULT";
            sql += " @flag = " + ((string.IsNullOrEmpty(ruleId)) ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(@agentId);
            sql += ", @cashHoldLimit = " + FilterString(cashLimit);
            sql += ", @ruleType = " + FilterString(ruleType);
            sql += ", @cashHoldLimitId = " + FilterString(ruleId);

            return ExecuteDataTable(sql);
        }

        public DbResult SaveUserCashAndVault(string user, string agentId, string cashLimit, string perTopUpLimitVal, string ruleType, string branchRuleId, string userRuleId, string userId)
        {
            string sql = "EXEC PROC_CASHANDVAULT_USERWISE";
            if (userRuleId == "0")
            {
                sql += " @flag = 'i'";
            }
            else
            {
                sql += " @flag = 'u'";
            }
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(@agentId);
            sql += ", @cashHoldLimit = " + FilterString(cashLimit);
            sql += ", @ruleType = " + FilterString(ruleType);
            sql += ", @cashHoldLimitBranchId = " + FilterString(branchRuleId);
            sql += ", @cashHoldLimitId = " + FilterString(userRuleId);
            sql += ", @userId = " + FilterString(userId);

            return ParseDbResult(sql);
        }

        public DataTable GetCashAndVaultDetails(string cashHoldLimitId, string user, string agentId)
        {
            var sql = "EXEC PROC_CASHANDVAULT";
            sql += " @Flag ='CashAndVault-Details'";
            sql += ",@cashHoldLimitId =" + FilterString(cashHoldLimitId);
            sql += ",@user =" + FilterString(user);
            sql += ",@agentId =" + FilterString(agentId);

            return ExecuteDataTable(sql);
        }

        public DataTable GetUserDetails(string user, string branchRuleId, string userRuleId, string agentId, string userid)
        {
            var sql = "EXEC PROC_CASHANDVAULT_USERWISE";
            sql += " @Flag ='UserDetails'";
            sql += ",@cashHoldLimitBranchId =" + FilterString(branchRuleId);
            sql += ",@cashHoldLimitId =" + FilterString(userRuleId);
            sql += ",@agentId =" + FilterString(agentId);
            sql += ",@user =" + FilterString(user);
            sql += ",@userid =" + FilterString(userid);

            return ExecuteDataTable(sql);
        }

        public DataTable PopulateDdl(string user, string flag)
        {
            var sql = "EXEC PROC_CASHANDVAULT";
            sql += " @flag ='ddl'";
            sql += " ,@flag1 =" + FilterString(flag);
            sql += " ,@user =" + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public DataTable SaveTransferToVault(string user, string amount, string transferDate, string userId, string agentId)
        {
            var msg = "Transfer To Vault by user: " + user + " dated on: " + transferDate;

            string sql = "PROC_PUSH_CASH_IN_OUT";
            sql += " @flag ='OUT' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @amount = " + FilterString(@amount);
            sql += ", @tranDate = " + FilterString(transferDate);
            sql += ", @head  = 'Transfer To Vault'";
            sql += ", @remarks = " + FilterString(msg);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @branchId = " + FilterString(agentId);
            sql += ", @isAutoApprove = '0'";
            sql += ", @referenceId = '0'";

            return ExecuteDataTable(sql);
        }

        public DataTable SaveTransferToVaultNew(string user, string amount, string transferDate, string userId, string agentId
            , string mode, string fromAcc, string toAcc)
        {
            var msg = "Transfer To Vault by user: " + user + " dated on: " + transferDate;

            string sql = "PROC_PUSH_CASH_IN_OUT";
            sql += " @flag ='OUT' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @tranDate = " + FilterString(transferDate);
            sql += ", @head  = 'Transfer To Vault'";
            sql += ", @remarks = " + FilterString(msg);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @branchId = " + FilterString(agentId);
            sql += ", @mode = " + FilterString(mode);
            sql += ", @fromAcc = " + FilterString(fromAcc);
            sql += ", @toAcc = " + FilterString(toAcc);
            sql += ", @isAutoApprove = '0'";
            sql += ", @referenceId = '0'";

            return ExecuteDataTable(sql);
        }

        public DataTable TransferFromVault(string user, string amount, string transferDate, string userId, string agentId
            , string mode, string fromAcc, string toAcc)
        {
            var msg = "Transfer From Vault by user: " + user + " dated on: " + transferDate;
            string isAuto = (mode == "cv") ? "0" : "1";

            string sql = "PROC_PUSH_CASH_IN_OUT";
            sql += " @flag ='OUT-TRANS' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @tranDate = " + FilterString(transferDate);
            sql += ", @head  = 'Transfer From Vault'";
            sql += ", @remarks = " + FilterString(msg);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @branchId = " + FilterString(agentId);
            sql += ", @mode = " + FilterString(mode);
            sql += ", @fromAcc = " + FilterString(fromAcc);
            sql += ", @toAcc = " + FilterString(toAcc);
            sql += ", @isAutoApprove = '" + isAuto + "'";
            sql += ", @referenceId = '0'";

            return ExecuteDataTable(sql);
        }

        public DataRow GetUserIdAndBranchList(string user)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='getUserIdAndBranchId-list'";
            sql += ",@user =" + FilterString(user);

            return ExecuteDataRow(sql);
        }

        public DbResult CheckIfAnyUnapprovedTransaction(string user)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='anyPendingTransactions'";
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataRow GetUserIdAndBranch(string user, string amountVal, string showLimit)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='getUserIdAndBranchId'";
            sql += ",@user =" + FilterString(user);
            sql += ",@transferAmt =" + FilterString(amountVal);
            sql += ",@param1 =" + FilterString(showLimit);

            return ExecuteDataRow(sql);
        }

        public DataRow GetBranchCashDetails(string user, string branch, string flag)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='" + flag + "'";
            sql += ",@user =" + FilterString(user);
            sql += ",@agentId =" + FilterString(branch);

            return ExecuteDataRow(sql);
        }

        public DbResult InsertBranchRuleId(string user, string agentId)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='InsertBranchRuleId'";
            sql += ",@user =" + FilterString(user);
            sql += ",@agentId =" + FilterString(agentId);

            return ParseDbResult(sql);
        }

        public DbResult UpdateActiveInActiveStatus(string user, string activeStatus, string cashholdLimitIdVal, string BranchOrUser)
        {
            var sql = "EXEC PROC_VAULTTRANSFER";
            sql += " @flag ='updateActiveStatus'";
            sql += ",@user =" + FilterString(user);
            sql += ",@activeStatus =" + FilterString(activeStatus);
            sql += ",@cashholdLimitId =" + FilterString(cashholdLimitIdVal);
            sql += ",@updateBranchOrUser =" + FilterString(BranchOrUser);

            return ParseDbResult(sql);
        }
    }
}