using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomerInfoDao : RemittanceDao
    {
        public DbResult Update(string user, string customerInfoId, string customerId, string date, string subject,
                               string description, string setPrimary)
        {
            string sql = "EXEC proc_customerInfo";
            sql += " @flag = " + (customerInfoId == "0" || customerInfoId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @customerInfoId = " + FilterString(customerInfoId);

            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @date = " + FilterString(date);
            sql += ", @subject = " + FilterString(subject);
            sql += ", @description = " + FilterString(description);
            sql += ", @setPrimary = " + FilterString(setPrimary);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string customerInfoId)
        {
            string sql = "EXEC proc_customerInfo";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerInfoId = " + FilterString(customerInfoId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string customerInfoId)
        {
            string sql = "EXEC proc_customerInfo";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerInfoId = " + FilterString(customerInfoId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}