using System;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.UserMatrix
{
    public partial class Input : System.Web.UI.Page
    {
        StaticDataDdl sl = new StaticDataDdl();
        private const string ViewFunctionId = "10101400";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            GetStatic.SetActiveMenu(ViewFunctionId);
            PopulateDll();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDll()
        {
            var sql = "EXEC proc_MatrixReport @flag = 'nrl', @user = " + sl.FilterString(GetStatic.GetUser()) ;
            sl.SetDDL(ref role, sql, "roleId", "roleName", "", "");

            sql = "EXEC proc_MatrixReport @flag = 'nfl', @user = " + sl.FilterString(GetStatic.GetUser());
            sl.SetDDL(ref function, sql, "functionId", "functionName", "", "");

        }
    }
}