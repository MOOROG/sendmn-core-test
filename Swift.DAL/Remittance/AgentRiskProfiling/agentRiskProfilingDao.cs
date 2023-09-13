using System.Data;
using Swift.DAL.SwiftDAL;
using System.Text;

namespace Swift.DAL.BL.Remit.AgentRiskProfiling
{
    public class agentRiskProfilingDao : RemittanceDao
    {
        public DataSet profilingCriteria(string user, string agentId, string assessementId)
        {
            string sql = "EXEC proc_agentRiskProfiling";
            sql += " @flag = 'pc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentID = " + FilterString(agentId);
            sql += ", @assessementId = " + FilterString(assessementId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        //public DataSet profilingCriteriaReview(string user,string agentId,string assessementId)
        //{
        //    string sql = "EXEC proc_agentRiskProfiling";
        //    sql += " @flag = 'pc-review'";          
        //    sql += ", @user = " + FilterString(user);
        //    sql += ", @agentID = " + FilterString(agentId);
        //    sql += ", @assessementId = " + FilterString(assessementId);

        //    DataSet ds = ExecuteDataset(sql);
        //    if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        //        return null;
        //    return ds;
        //}
        public DbResult SaveRiskProfilingAgent(string user, string agentId, string assesementdate)
        {
            string sql = "EXEC proc_agentRiskProfiling";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentID = " + FilterString(agentId);
            sql += ", @assessementDate = " + FilterString(assesementdate);
            sql += ", @createdBy=" + FilterString(user);
            sql += ", @isActive='Y'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult InactiveProfilingAgent(string user, string agentId, string assessementId)
        {
            string sql = "EXEC proc_agentRiskProfiling";
            sql += " @flag = 'inactive'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentID = " + FilterString(agentId);
            sql += ", @assessementId = " + FilterString(assessementId);
            sql += ", @createdBy=" + FilterString(user);
            sql += ", @isActive='N'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult SaveReview(string user, string agentId, string assessementId, string reviewerComment)
        {
            string sql = "EXEC proc_agentRiskProfiling";
            sql += " @flag = 'i-r'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentID = " + FilterString(agentId);
            sql += ", @assessementId = " + FilterString(assessementId);
            sql += ", @reviewedBy=" + FilterString(user);
            sql += ", @reviewerComment=" + FilterString(reviewerComment);            

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult SaveRiskProfiling(string user,StringBuilder sb,string assessementId,string rating,decimal totalScore)
        {          

            string sql = "EXEC proc_agentRiskProfiling @flag='i-rp'";
            sql = sql + " ,@user=" + FilterString(user);
            sql = sql + ", @score="+ FilterString(totalScore.ToString());
            sql = sql + ", @rating=" + FilterString(rating);
            sql = sql + ", @assessementId=" + FilterString(assessementId);
            sql = sql + ", @xml='" + sb + "'";

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
