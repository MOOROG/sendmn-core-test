using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class RemitCardDao:SwiftDao
    {
        public DbResult RequestCardReIssue(string user, string id, string oldRemitCardNo, string newRemitCardNo, string remark, string requestFor)
        {
            string sql = "EXEC proc_imeRemitCardReIssue";
            sql += " @flag = " + ((string.IsNullOrWhiteSpace(id) || id.Equals("0") ? "'i'" : "'u'"));
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);
            sql += ", @oldRemitCardNo = " + FilterString(oldRemitCardNo);
            sql += ", @newRemitCardNo = " + FilterString(newRemitCardNo);          
            sql += ", @remark = " + FilterString(remark);
            sql += ", @requestFor = " + FilterString(requestFor);            
            return ParseDbResult(sql);
        }

        public DataRow SelectCardReIssueById(string user, string id)
        {
            string sql = "EXEC proc_imeRemitCardReIssue";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);

            return ExecuteDataRow(sql);
        }

        public DataRow SelectCardReIssueByImeRemitCard(string user, string imeRemitCardNo)
        {
            string sql = "EXEC proc_imeRemitCardReIssue";
            sql += "  @flag = 'a-agent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @oldRemitCardNo = " + FilterString(imeRemitCardNo);

            return ExecuteDataRow(sql);
        }
        

        public DbResult DeleteCardReIssueRequest(string user, string id)
        {
            string sql = "EXEC proc_imeRemitCardReIssue";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);

            return ParseDbResult(sql);
        }

        public DbResult ApproveCardReIssue(string user, string id)
        {
            string sql = "EXEC proc_imeRemitCardReIssue";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(id);

            return ParseDbResult(sql);
        }
    }
}
