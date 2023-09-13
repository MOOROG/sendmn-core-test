using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission
{
    public class AgentCommissionDao : RemittanceDao
    {
        public DbResult Update(string user, string id, string packageId, string ruleId)
        {
            string sql = "EXEC proc_agentCommissionRule";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @agentId = " + FilterString(packageId);
            sql += ", @ruleId = " + FilterString(ruleId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string id)
        {
            string sql = "EXEC proc_agentCommissionRule";
            sql += " @flag = 'd'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_agentCommissionRule";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult AddCommissionRule(string user, string agentId, string ruleId, string ruleType)
        {
            string sql = "EXEC proc_agentCommissionRuleAdd";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @ruleId = " + FilterString(ruleId);
            sql += ", @ruleType = " + FilterString(ruleType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet SelectForViewChanges(string user, string agentId)
        {
            var sql = "EXEC proc_agentCommissionRule @flag = 'vc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;

            return ExecuteDataset(sql);
        }

        public DataRow GetAgentCommissionAuditLog(string user, string agentId)
        {
            var sql = "EXEC proc_agentCommissionRule @flag = 'pal'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult ApprovePackage(string user, string agentId)
        {
            var sql = "EXEC proc_agentCommissionRuleAdd @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectPackage(string user, string agentId)
        {
            var sql = "EXEC proc_agentCommissionRuleAdd @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        // dao for group commission mapping
        public DbResult UpdateGroup(string user, string id, string packageId, string groupId)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += "  @flag = " + (id == "0" || id == "" ? "'ig'" : "'ug'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @packageId = " + FilterString(packageId);
            sql += ", @groupId = " + FilterString(groupId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteGroup(string user, string id)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += " @flag = 'dg'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdGroup(string user, string id)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += " @flag = 'ag'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet IntlRuleDisplay(string user, string packageId)
        {
            var sql = "EXEC proc_agentCommissionRule @flag = 'ic'";
            sql += ", @agentId = " + FilterString(packageId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds;
        }

        public DataSet PackageDisplay(string user, string groupId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 'pd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @groupId = " + FilterString(groupId);

            return ExecuteDataset(sql);
        }
    }
}
