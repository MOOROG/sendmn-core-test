using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class ContactCategory : SwiftDao
    {
        public DbResult Update(string user, string id, string categoryName, string categoryDesc)
        {
            string sql = "EXEC proc_categoryContact";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @categoryName = " + FilterString(categoryName);
            sql += ", @categoryDesc = " + FilterString(categoryDesc);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string id)
        {
            string sql = "EXEC proc_categoryContact";
            sql += " @flag = 'd'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DataRow SelectById(string user, string id)
        {
            string sql = "EXEC proc_categoryContact";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        //Contact Customer portion
        public DbResult UpdateCustomer(string user, string id, string catId, string customerName, string customerAddress, string mobile, string email)
        {
            string sql = "EXEC proc_categoryContact";
            sql += "  @flag = " + (id == "0" || id == "" ? "'ic'" : "'uc'");
            sql += ", @user = " + FilterString(user);
            sql += ", @catId = " + FilterString(catId);
            sql += ", @customerName = " + FilterString(customerName);
            sql += ", @customerAddress = " + FilterString(customerAddress);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @email = " + FilterString(email);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteCustomer(string user, string id)
        {
            string sql = "EXEC proc_categoryContact";
            sql += " @flag = 'dc'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DataRow SelectCustomerById(string user, string id)
        {
            string sql = "EXEC proc_categoryContact";
            sql += " @flag = 'ac'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

    }
}