using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomerIdentityDao : SwiftDao
    {
        public DbResult Update(string user, string cIdentityId, string idType, string idNumber, string customerId,string issueCountry,
                               string placeOfIssue, string issuedDate, string validDate, string isPrimary, string expiryType)
        {
            string sql = "EXEC proc_customerIdentity";
            sql += " @flag = " + (cIdentityId == "0" || cIdentityId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @cIdentityId = " + FilterString(cIdentityId);

            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNumber = " + FilterString(idNumber);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @issueCountry = " + FilterString(issueCountry);
            sql += ", @placeOfIssue = " + FilterString(placeOfIssue);
            sql += ", @issuedDate = " + FilterString(issuedDate);
            sql += ", @validDate = " + FilterString(validDate);
            sql += ", @expiryType = " + FilterString(expiryType);
            sql += ", @isPrimary = " + FilterString(isPrimary);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string cIdentityId)
        {
            string sql = "EXEC proc_customerIdentity";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cIdentityId = " + FilterString(cIdentityId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string cIdentityId)
        {
            string sql = "EXEC proc_customerIdentity";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cIdentityId = " + FilterString(cIdentityId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}