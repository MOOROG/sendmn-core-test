using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup
{
    public class CommGroupMappingDao : RemittanceDao
    {
        public DbResult Update(string user, string id, string packageId, string ruleId)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @packageId = " + FilterString(packageId);
            sql += ", @ruleId = " + FilterString(ruleId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet LoadGrid(string user, string scMasterId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 's'";
            sql = sql + ", @user =   " + FilterString(user);
            sql = sql + ", @scMasterId =   " + FilterString(scMasterId);
            return ExecuteDataset(sql);
        }

        public DbResult Delete(string user, string id)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += " @flag = 'd'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_commissionGroupMapping";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult AddCommissionRule(string user, string packageId, string ruleId, string ruleType)
        {
            string sql = "EXEC proc_commissionRuleAdd";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @packageId = " + FilterString(packageId);
            sql += ", @ruleId = " + FilterString(ruleId);
            sql += ", @ruleType = " + FilterString(ruleType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet SelectForViewChanges(string user, string packageId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 'vc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @packageId = " + FilterString(packageId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;

            return ExecuteDataset(sql);
        }

        public DataRow GetPackageAuditLog(string user, string packageId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 'pal'";
            sql += ", @user = " + FilterString(user);
            sql += ", @packageId = " + FilterString(packageId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult ApprovePackage(string user, string packageId)
        {
            var sql = "EXEC proc_commissionRuleAdd @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @packageId = " + FilterString(packageId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectPackage(string user, string packageId)
        {
            var sql = "EXEC proc_commissionRuleAdd @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @packageId = " + FilterString(packageId);

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
            var sql = "EXEC proc_commissionGroupMapping @flag = 'ic'";
            sql += ", @packageId = " + FilterString(packageId);
            sql += ", @user = " + FilterString(user);

            return ExecuteDataset(sql);
        }

        public DataTable DomesticRuleDisplay(string user, string packageId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 'ds'";
            sql += ", @packageId = " + FilterString(packageId);
            sql += ", @user = " + FilterString(user);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataSet PackageDisplay(string user, string groupId)
        {
            var sql = "EXEC proc_commissionGroupMapping @flag = 'pd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @groupId = " + FilterString(groupId);

            return ExecuteDataset(sql);
        }
        
        //// FOR ADDING COMMISSION GROUP 
        public DbResult AddCommissionGroup(string user, string groupId, string packageId)
        {
            string sql = "EXEC proc_commissionPackageAdd";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @groupId = " + FilterString(groupId);
            sql += ", @packageId = " + FilterString(packageId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
