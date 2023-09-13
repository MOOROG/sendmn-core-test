using System.Data;
using Swift.DAL.SwiftDAL;
using System.Text;

namespace Swift.DAL.BL.Remit.AgentRating
{
    public class AgentRatingDao : RemittanceDao
    {
        public DbResult SaveAgentForRating(string user, string agentId, string agentType, string fromDate, string toDate)
        {
            string sql = "EXEC proc_agentRating";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @agentType = " + FilterString(agentType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @isActive='Y'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet ratingCriteria(string user, string agentId, string agentType, string arDetailId)
        {
            string sql = "EXEC proc_agentRating";
            sql += " @flag = 'rc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @arDetailId = " + FilterString(arDetailId);
            sql += ", @agentType = " + FilterString(agentType);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet ratingCriteriaPreview(string user, string agentId, string agentType, string arDetailId, string actionType)
        {
            var flag = (actionType == "preview" || actionType == "rating") ? "rc-preview" : "rc";

            string sql = "EXEC proc_agentRating";
            sql += " @flag = " + FilterString(flag);
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @arDetailId = " + FilterString(arDetailId);
            sql += ", @agentType = " + FilterString(agentType);
            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet SaveAgentRating(string user, StringBuilder sb, string agentId, string agentType, string arDetailId, string isRatingCompleted, string ratingComment, string ratingBy)
        {

            string sql = "EXEC proc_agentRating @flag='i-ar'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + ", @agentId=" + FilterString(agentId);
            sql = sql + ", @agentType=" + FilterString(agentType);
            sql = sql + ", @arDetailId=" + FilterString(arDetailId);
            sql = sql + ", @isRatingCompleted=" + FilterString(isRatingCompleted);
            sql = sql + " ,@ratingComment=" + FilterString(ratingComment);
            sql = sql + " ,@ratingBy=" + FilterString(ratingBy);
            sql = sql + ", @xml='" + sb + "'";

            return ExecuteDataset(sql);
        }
        public DbResult SaveRatingSummary(string user, StringBuilder sb, string arDetailId, string agentType)
        {
            string sql = "EXEC proc_agentRating  @flag = 'summary'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + ", @arDetailId=" + FilterString(arDetailId);
            sql = sql + ", @agentType=" + FilterString(agentType);
            sql = sql + ", @xml='" + sb + "'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult SaveRatingReview(string user, string reviewerComment, string arDetailId)
        {
            string sql = "EXEC proc_agentRating  @flag = 'review'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@reviewerComment=" + FilterString(reviewerComment);
            sql = sql + ", @arDetailId=" + FilterString(arDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult SaveAgentComment(string user, string comment, string arDetailId)
        {
            string sql = "EXEC proc_agentRating  @flag = 'agentcomment'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@ratingComment=" + FilterString(comment);
            sql = sql + ", @arDetailId=" + FilterString(arDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult ApproveAgentRating(string user, string approverComment, string arDetailId)
        {
            string sql = "EXEC proc_agentRating  @flag = 'approve'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@approverComment=" + FilterString(approverComment);
            sql = sql + ", @arDetailId=" + FilterString(arDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult InactiveAgentRating(string user, string arDetailId, string agentId)
        {
            string sql = "EXEC proc_agentRating";
            sql += " @flag = 'inactive'";
            sql += ", @user = " + FilterString(user);
            sql += ", @arDetailId = " + FilterString(arDetailId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @isActive='N'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable GetAgentRatingInformation(string user, string ratingId)
        {
            string sql = "EXEC proc_agentRating";
            sql += " @flag = 'getArInfoByArdId'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ardId = " + FilterString(ratingId);
            return ExecuteDataTable(sql);
        }
    }
}
