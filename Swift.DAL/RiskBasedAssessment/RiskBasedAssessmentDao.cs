using System.Data;
using Swift.DAL.SwiftDAL;
using System.Collections.Generic;
namespace Swift.DAL.RiskBasedAssessment
{
    public class RiskBasedAssessmentDao : SwiftDao
    {
        RemittanceDao obj = new RemittanceDao();

        //public DbResult saveCriteria(List<RbaCriteria> _RbaCriteria)
        //{
        //    DbResult db=null;
        //    foreach (var item in _RbaCriteria)
        //    {

        //        string sql = "EXEC proc_riskAssessment";
        //        sql += "  @flag = 'criteria'";
        //        sql += ", @criteriaID=" + FilterString(item.CriteriaID);
        //        sql += ", @fatfCriteria = " + FilterString(item.FatfCriteria);
        //        sql += ", @rbaId =null ";
        //        sql += ", @condition = " + FilterString(item.Condition);
        //        sql += ", @criteriaCountry = " + FilterString(item.CriteriaCountry);
        //        sql += ", @valueFrom = " + FilterString(item.ValueFrom);
        //        sql += ", @valueTo = " + FilterString(item.ValueTo);
        //        sql += ", @weight = " + FilterString(item.Weight);
        //        sql += ", @createdBy = " + FilterString(item.User);

        //        DataRow dr = obj.ExecuteDataRow(sql);
        //        string rbaId;
        //        if (dr == null)
        //        {
        //            return null;
        //        }
        //        rbaId = dr["id"].ToString();
        //        foreach (RbaCriteriaCondition rbacondition in item.RbaCriteriaCondition)
        //        {
        //            string sqlcondition = "EXEC proc_riskAssessment";
        //            sqlcondition += "  @flag = 'criteria-condtition'";
        //            sql += ", @criteriaID=null";
        //            sqlcondition += ", @fatfCriteria = null" ;
        //            sqlcondition += ", @rbaId = " + FilterString(rbaId);
        //            sqlcondition += ", @condition = " + FilterString(rbacondition.CriCondition);
        //            sqlcondition += ", @criteriaCountry =" + FilterString(rbacondition.CriCountry);
        //            sqlcondition += ", @valueFrom = " + FilterString(rbacondition.CriValueFrom);
        //            sqlcondition += ", @valueTo = " + FilterString(rbacondition.CriValueTo);
        //            sqlcondition += ", @weight = " + FilterString(rbacondition.CriWeight);
        //            sqlcondition += ", @createdBy = " + FilterString(rbacondition.CriUser);
                    
        //            db =ParseDbResult(obj.ExecuteDataset(sqlcondition).Tables[0]);
        //        }

        //    }

        //    return db;
        //}
        public DataTable getCondition()
        {
            
            string sql = "EXEC proc_rbaMaster";
            sql += "  @FLAG = 'condition'";
            return obj.ExecuteDataTable(sql);
           

        }
        public DataTable GetRiskAssessment(string flag, string criterialD)
        {
            string sql = "EXEC proc_rbaMaster";
            sql += "  @flag =" + FilterString(flag);
            sql += ", @criteria =" + FilterString(criterialD);
            return obj.ExecuteDataTable(sql);
        }
        
        public DbResult SaveRiskAssessment(string flag,string criteriaID, string criteria, string condition, string criteriaDetail1, string criteriaDetail2, string result, string weight,string user)
        {
            string sql = "exec [proc_rbaMaster]";
            sql += "  @flag =" + FilterString(flag);
            sql += ", @ID =" + FilterString(criteriaID);
            sql += ", @criteria =" + FilterString(criteria);
            sql += ", @condition =" + FilterString(condition);
            sql += ", @criteriaDetail1 =" + FilterString(criteriaDetail1);
            sql += ", @criteriaDetail2 =" + FilterString(criteriaDetail2);
            sql += ", @result =" + FilterString(result);
            sql += ", @weight = " + FilterString(weight);
            sql+= ",@createdBy="+ FilterString(user);
            return obj.ParseDbResult(sql);
        }
        
        public DbResult DeleteRow(string flag, string criteriaID, string user)
        {
            string sql = "exec [proc_rbaMaster]";
            sql += "  @flag =" + FilterString(flag);
            sql += ", @ID =" + FilterString(criteriaID);
            sql += ",@modifiedBy=" + FilterString(user);
            return obj.ParseDbResult(sql);
        }
    }
}
