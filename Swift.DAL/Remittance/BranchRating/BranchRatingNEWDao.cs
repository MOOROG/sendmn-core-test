using System.Data;
using Swift.DAL.SwiftDAL;
using System.Text;

namespace Swift.DAL.BL.Remit.BranchRating
{
   public class BranchRatingNEWDao : RemittanceDao
    {
        public DbResult SaveBranchForRating(string user, string agentId, string fromDate, string toDate)
        {
            string sql = "EXEC proc_branchRatingNEW";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(agentId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @isActive='Y'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet ratingCriteria(string user, string branchId, string brDetailId)
        {
            string sql = "EXEC proc_branchRatingNEW";
            sql += " @flag = 'rc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @brDetailId = " + FilterString(brDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataSet SaveBranchRating(string user, StringBuilder sb, string branchId, string brDetailId, string isRatingCompleted, string ratingComment)
        {

            string sql = "EXEC proc_branchRatingNEW @flag='i-br'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + ", @branchId=" + FilterString(branchId);
            sql = sql + ", @brDetailId=" + FilterString(brDetailId);
            sql = sql + ", @isRatingCompleted=" + FilterString(isRatingCompleted);
            sql = sql + " ,@ratingComment=" + FilterString(ratingComment);
            sql = sql + ", @xml='" + sb + "'";

            return ExecuteDataset(sql);
        }
        public DbResult SaveRatingSummary(string user, StringBuilder sb, string brDetailId)
        {
            string sql = "EXEC proc_branchRatingNEW  @flag = 'summary'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + ", @brDetailId=" + FilterString(brDetailId);
            sql = sql + ", @xml='" + sb + "'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult SaveRatingReview(string user, string reviewerComment, string brDetailId)
        {
            string sql = "EXEC proc_branchRatingNEW  @flag = 'review'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@reviewerComment=" + FilterString(reviewerComment);
            sql = sql + ", @brDetailId=" + FilterString(brDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult ApproveBranchRating(string user, string approverComment, string brDetailId)
        {
            string sql = "EXEC proc_branchRatingNEW  @flag = 'approve'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@approverComment=" + FilterString(approverComment);
            sql = sql + ", @brDetailId=" + FilterString(brDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult InactiveBranchRating(string user, string brDetailId, string branchId)
        {
            string sql = "EXEC proc_branchRatingNEW";
            sql += " @flag = 'inactive'";
            sql += ", @user = " + FilterString(user);
            sql += ", @brDetailId = " + FilterString(brDetailId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @isActive='N'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult SaveBranchComment(string user, string comment, string brDetailId)
        {
            string sql = "EXEC proc_branchRatingNEW  @flag = 'branchcomment'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + " ,@ratingComment=" + FilterString(comment);
            sql = sql + ", @brDetailId=" + FilterString(brDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
