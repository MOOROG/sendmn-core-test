using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.UserManagement {
  public class ApplicationRoleDao : RemittanceDao {
    public DbResult Update(string roleId, string roleName, string roleDesc, string user, string isActive) {
      string sql = "exec [proc_applicationRoles]";
      sql += "  @flag =" + (roleId == "0" ? "'i'" : "'u'");
      sql += ", @roleId =" + FilterString(roleId);
      sql += ", @roleName =" + FilterString(roleName);
      sql += ", @roleType =" + FilterString(roleDesc);
      sql += ", @isActive =" + FilterString(isActive);
      sql += ", @user = " + FilterString(user);
      return ParseDbResult(sql);
    }

    public DataRow SelectById(string roleId, string user) {
      string sql = "Exec [proc_applicationRoles]";
      sql += " @flag ='a'";
      sql += ", @roleId=" + FilterString(roleId);
      sql += ", @user=" + FilterString(user);

      DataSet ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }
    public DbResult Delete(string roleId, string user) {
      string sql = "Exec [proc_applicationRoles]";
      sql += " @flag ='d'";
      sql += ", @roleId=" + FilterString(roleId);
      sql += ", @user=" + FilterString(user);
      return ParseDbResult(sql);
    }

    public DataTable GetRoleFunctionList(string roleId, string user) {
      string sql = "exec proc_applicationRoleFunction";
      sql += " @flag = 'rfl'";
      sql += ", @roleId =" + FilterString(roleId);
      sql += ", @user =" + FilterString(user);
      return ExecuteDataset(sql).Tables[0];
    }
    public DataTable ViewRoleFunctionList(string roleId, string user) {
      string sql = "exec proc_applicationRoleFunction";
      sql += " @flag = 'viewrole'";
      sql += ", @roleId =" + FilterString(roleId);
      sql += ", @user =" + FilterString(user);
      return ExecuteDataset(sql).Tables[0];
    }

    public DataTable GetUserFunctionList(string userName, string user) {
      string sql = "exec proc_applicationRoleFunction";
      sql += "  @flag = 'ufl'";
      sql += ", @userId =" + FilterString(userName);
      sql += ", @user =" + FilterString(user);

      return ExecuteDataset(sql).Tables[0];
    }

    public DbResult SaveRoleFunction(string functionIds, string roleId, string user) {
      string sql = "exec proc_applicationRoleFunction ";
      sql += "  @flag = 'rfi'";
      sql += ", @functionIds ='" + (functionIds) + "'";
      sql += ", @roleId =" + FilterString(roleId);
      sql += ", @user =" + FilterString(user);

      return ParseDbResult(sql);
    }

    public DbResult SaveUserFunction(string functionIds, string userId, string user) {
      string sql = "exec proc_applicationRoleFunction ";
      sql += "  @flag = 'ufi'";
      sql += ", @functionIds ='" + (functionIds) + "'";
      sql += ", @userId =" + FilterString(userId);
      sql += ", @user =" + FilterString(user);

      return ParseDbResult(sql);
    }

    public DbResult SaveUserRole(string roleIds, string userId, string user) {
      string sql = "exec proc_applicationRoleFunction ";
      sql += "  @flag = 'uri'";
      sql += ", @roleIds ='" + (roleIds) + "'";
      sql += ", @userId =" + FilterString(userId);
      sql += ", @user =" + FilterString(user);

      return ParseDbResult(sql);
    }

    public DataTable GetRoleList(string userId, string user) {
      string sql = " exec proc_applicationRoleFunction ";
      sql += "  @flag = 'rl'";
      sql += ", @userId = " + FilterString(userId);
      sql += ", @user =" + FilterString(user);
      return ExecuteDataset(sql).Tables[0];
    }
    public DbResult MenuDelete(string user, string functionId) {
      string sql = "EXEC proc_applicationRoleFunction @flag='menuDelete'";
      sql += ", @user=" + FilterString(user);
      sql += ", @functionId=" + FilterString(functionId);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
  }
}