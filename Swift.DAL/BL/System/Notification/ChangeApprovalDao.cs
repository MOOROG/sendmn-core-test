using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Notification
{
    public class ChangeApprovalDao : SwiftDao
    {
        public DataRow SelectById(string functionId)
        {
            string sql = "SELECT * FROM changesApprovalSettings WITH(NOLOCK) WHERE functionId = " +
                         FilterString(functionId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectLogHeadById(string functionId, string id)
        {
            DataRow dr = SelectById(functionId);
            if (dr == null)
                return null;


            string mainTable = dr["mainTable"].ToString();
            string modTable = dr["modTable"].ToString();
            string pkField = dr["pkField"].ToString();

            string sql =
                @"SELECT
                             createdBy  = ISNULL(MAX(mode.createdBy), MAX(main.createdBy))
                            ,createdDate  = ISNULL(MAX(mode.createdDate), MAX(main.createdDate))
                        FROM " +
                mainTable + @" main WITH(NOLOCK)
                        FULL JOIN " + modTable +
                @" mode WITH(NOLOCK) ON main." + pkField + " = mode." + pkField +
                @"
                        WHERE main." + pkField + " = " + FilterString(id) + @" OR mode." + pkField +
                " = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectLogHeadByIdUR(string functionId, string id)
        {
            string sql =
                @"SELECT
                             createdBy = ISNULL(MAX(mode.createdBy), MAX(main.createdBy))
                            ,createdDate = ISNULL(MAX(mode.createdDate), MAX(main.createdDate))
                        FROM applicationUserRoles main WITH(NOLOCK)
                        FULL JOIN applicationUserRolesMod mode WITH(NOLOCK) ON main.userId = mode.userId
                        AND main.userId = " +
                FilterString(id) + @" AND mode.userId = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectLogHeadByIdUF(string functionId, string id)
        {
            string sql =
                @"SELECT
                             createdBy = ISNULL(MAX(mode.createdBy), MAX(main.createdBy))
                            ,createdDate = ISNULL(MAX(mode.createdDate), MAX(main.createdDate))
                        FROM applicationUserFunctions main WITH(NOLOCK)
                        FULL JOIN applicationUserFunctionsMod mode WITH(NOLOCK) ON main.userId = mode.userId
                        AND main.userId = " +
                FilterString(id) + @" AND mode.userId = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectLogHeadByIdRC(string functionId, string id)
        {
            string sql =
                @"SELECT
                             createdBy = ISNULL(MAX(mode.createdBy), MAX(main.createdBy))
                            ,createdDate = ISNULL(MAX(mode.createdDate), MAX(main.createdDate))
                        FROM csCriteria main WITH(NOLOCK)
                        LEFT JOIN csCriteriaHistory mode WITH(NOLOCK) ON main.csdetailId = mode.csdetailId
                        AND main.csdetailId = " +
                FilterString(id) + @" AND mode.csdetailId = " + FilterString(id) +
                @"
                        AND mode.approvedBy IS NULL";

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string functionId, string id)
        {
            DataRow dr = SelectById(functionId);
            if (dr == null)
                return (new DbResult());

            string spName = dr["spName"].ToString();
            string pkField = dr["pkField"].ToString();

            string sql = spName + " @flag = 'approve', @user=" + FilterString(user) + ", @" + pkField + " = " +
                         FilterString(id);
            if (functionId == "20131030" ||
                functionId == "20131130" ||
                functionId == "20131230" ||
                functionId == "20131330" ||
                functionId == "20601030" ||
                functionId == "20601130")
                sql = spName + " @flag = 'approveAll', @user=" + FilterString(user) + ", @" + pkField + " = " +
                      FilterString(id);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult Reject(string user, string functionId, string id)
        {
            DataRow dr = SelectById(functionId);
            if (dr == null)
                return (new DbResult());

            string spName = dr["spName"].ToString();
            string pkField = dr["pkField"].ToString();

            string sql = spName + " @flag = 'reject', @user=" + FilterString(user) + ", @" + pkField + " = " +
                         FilterString(id);
            if (functionId == "20141030" ||
                functionId == "20141130" ||
                functionId == "20131030" ||
                functionId == "20131130" ||
                functionId == "20131230" ||
                functionId == "20131330" ||
                functionId == "20601030")
                sql = spName + " @flag = 'rejectAll', @user=" + FilterString(user) + ", @" + pkField + " = " +
                      FilterString(id);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectUR(string user, string functionId, string id)
        {
            string sql =
                "[proc_applicationRoleFunction] @flag = 'reject', @roleIds = '1', @functionIds = NULL, @user = " +
                FilterString(user) + ", @userId = " + FilterString(id);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectUF(string user, string functionId, string id)
        {
            string sql =
                "[proc_applicationRoleFunction] @flag = 'reject', @roleIds = NULL, @functionIds = '1', @user = " +
                FilterString(user) + ", @userId = " + FilterString(id);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string[] GetChangeList(string functionId, string id)
        {
            DataRow dr = SelectById(functionId);
            if (dr == null)
                return new[] {"", ""};

            string mainTable = dr["mainTable"].ToString();
            string modTable = dr["modTable"].ToString();
            string pkField = dr["pkField"].ToString();
            string pageName = dr["pageName"].ToString();

            string changeType = "";

            string sql = "SELECT 'x' FROM " + mainTable + " WHERE approvedBy IS NULL AND " + pkField + " = " +
                         FilterString(id);
            string res = GetSingleResult(sql);
            if (res == "x")
            {
                changeType = "Insert";
            }


            sql = "SELECT modType FROM " + modTable + " WHERE " + pkField + " = " + FilterString(id);

            if ((mainTable + "History").ToUpper() == modTable.ToUpper())
            {
                sql = sql + " AND approvedBy IS NULL ";
            }
            res = GetSingleResult(sql);

            if (res.ToUpper() == "U")
            {
                changeType = "Update";
            }
            else if (res.ToUpper() == "D")
            {
                changeType = "Delete";
            }

            string oldValue = "";
            string newValue = "";

            if (changeType == "Insert")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(mainTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);
                newValue = GetSingleResult(sql);
            }

            if (changeType == "Update")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(modTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                newValue = GetSingleResult(sql);
            }

            if (changeType == "Update" || changeType == "Delete")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(mainTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                oldValue = GetSingleResult(sql);
            }

            return new[] {oldValue, newValue, pageName, changeType};
        }

        public string[] GetChangeListUR(string functionId, string id)
        {
            string mainTable = "applicationUserRoles";
            string modTable = "applicationUserRolesMod";
            string pkField = "userId";
            string pageName = "User Roles";

            string changeType = "";

            string sql = "SELECT modType FROM " + modTable + " WHERE " + pkField + " = " + FilterString(id);
            string res = GetSingleResult(sql);

            if (res.ToUpper() == "U")
            {
                changeType = "Update";
            }


            string oldValue = "";
            string newValue = "";


            if (changeType == "Update")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(modTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                newValue = GetSingleResult(sql);

                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(mainTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                oldValue = GetSingleResult(sql);
            }

            return new[] {oldValue, newValue, pageName, changeType};
        }

        public string[] GetChangeListUF(string functionId, string id)
        {
            string mainTable = "applicationUserFunctions";
            string modTable = "applicationUserFunctionsMod";
            string pkField = "userId";
            string pageName = "User Functions";

            string changeType = "";

            string sql = "SELECT modType FROM " + modTable + " WHERE " + pkField + " = " + FilterString(id);
            string res = GetSingleResult(sql);

            if (res.ToUpper() == "U")
            {
                changeType = "Update";
            }

            string oldValue = "";
            string newValue = "";


            if (changeType == "Update")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(modTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                newValue = GetSingleResult(sql);

                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(mainTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                oldValue = GetSingleResult(sql);
            }

            return new[] {oldValue, newValue, pageName, changeType};
        }

        public string[] GetChangeListRC(string functionId, string id)
        {
            string mainTable = "";
            string modTable = "";
            string pkField = "";
            string pageName = "";

            string changeType = "";

            switch (functionId)
            {
                case "20601035":
                    mainTable = "csCriteria";
                    modTable = "csCriteriaHistory";
                    pkField = "csDetailId";
                    pageName = "Rule Criteria";
                    break;
                case "20601135":
                    mainTable = "cisCriteria";
                    modTable = "cisCriteriaHistory";
                    pkField = "cisDetailId";
                    pageName = "ID Criteria";
                    break;
            }

            string sql = "SELECT modType FROM " + modTable + " WHERE " + pkField + " = " + FilterString(id) +
                         " AND approvedBy IS NULL";
            string res = GetSingleResult(sql);

            if (res.ToUpper() == "U")
            {
                changeType = "Update";
            }

            string oldValue = "";
            string newValue = "";


            if (changeType == "Update")
            {
                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(modTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                newValue = GetSingleResult(sql);

                sql = "EXEC [proc_GetColumnToRow] @returnTable = 'Y'";
                sql += ",@tableName = " + FilterString(mainTable);
                sql += ",@fieldName = " + FilterString(pkField);
                sql += ",@dataId = " + FilterString(id);

                oldValue = GetSingleResult(sql);
            }

            return new[] {oldValue, newValue, pageName, changeType};
        }

        public DataRow CheckApprovalApi(string user, string functionId, string id)
        {
            string sql = "EXEC [proc_errPaidTranAPI] @flag = 'c'";
            sql += ",@user = " + FilterString(user);
            sql += ",@functionId = " + FilterString(functionId);
            sql += ",@id = " + FilterString(id);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}