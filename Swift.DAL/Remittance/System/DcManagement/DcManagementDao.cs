using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.DCManagement
{
    public class DcManagementDao : RemittanceDao
    {
        public DbResult Approve(string user, string requestId)
        {
            var sql = "EXEC proc_dcManagement @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @requestId = " + FilterString(requestId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string requestId)
        {
            var sql = "EXEC proc_dcManagement @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @requestId = " + FilterString(requestId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ClearDc(string user, string userId)
        {
            var sql = "EXEC proc_dcManagement @flag = 'dcClear-1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userId = " + FilterString(userId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RemoveDc(string user, string userId)
        {
            var sql = "EXEC proc_dcManagement @flag = 'dcRemove'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userId = " + FilterString(userId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
