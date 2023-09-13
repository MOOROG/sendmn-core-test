using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.UserManagement
{
    public class UserMatrixDao : RemittanceDao
    {
        public ReportResult GetReport(string user, string userName)
        {
            var sql = "EXEC proc_MatrixReport";
            sql += " @flag = 'report'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userName = " + FilterString(userName);
            return ParseReportResult(sql);
        }

        public ReportResult GetReportRole(string user, string roleId)
        {
            var sql = "EXEC proc_MatrixReport";
            sql += " @flag = 'nrlReport'";
            sql += ", @user = " + FilterString(user);
            sql += ", @roleId = " + FilterString(roleId);
            return ParseReportResult(sql);
        }

        public ReportResult GetReportRole2(string user, string roleId)
        {
            var sql = "EXEC proc_MatrixReport";
            sql += " @flag = 'nrlReport2'";
            sql += ", @user = " + FilterString(user);
            sql += ", @roleId = " + FilterString(roleId);
            return ParseReportResult(sql);
        }

        public ReportResult GetReportFunction(string user, string functionId)
        {
            var sql = "EXEC proc_MatrixReport";
            sql += " @flag = 'nflReport'";
            sql += ", @user = " + FilterString(user);
            sql += ", @functionId = " + FilterString(functionId);
            return ParseReportResult(sql);
        }
    }
}
