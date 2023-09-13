using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomerDao : SwiftDao
    {
        public DbResult Update(string user, string customerId, string customerName, string customerCode,
                               string customerPhone1, string customerPhone2, string customerMobile1,
                               string customerMobile2, string customerEmail1, string customerEmail2,
                               string customerFax1, string customerFax2, string customerAddressPermanent,
                               string permanentCity, string permanentCountry, string customerAddressTemp,
                               string tempCity, string tempCountry, string dob, string gender,
                               string customerPassportNo, string passportIssueDate, string passportExpireDate,
                               string salary, string salaryCurrency, string designation, string jobNature,
                               string contactPerson1,
                               string contactPerson1Address, string contactPerson1Phone, string contactPerson1Mobile,
                               string contactPerson1Fax, string contactPerson1Email, string contactPerson2,
                               string contactPerson2Address, string contactPerson2Phone, string contactPerson2Mobile,
                               string contactPerson2Fax, string contactPerson2Email, string contactPerson3,
                               string contactPerson3Address, string contactPerson3Phone, string contactPerson3Fax,
                               string contactPerson3Mobile, string contactPerson3Email, string isActive)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = " + (customerId == "0" || customerId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            sql += ", @customerName = " + FilterString(customerName);
            sql += ", @customerCode = " + FilterString(customerCode);
            sql += ", @customerPhone1 = " + FilterString(customerPhone1);
            sql += ", @customerPhone2 = " + FilterString(customerPhone2);
            sql += ", @customerMobile1 = " + FilterString(customerMobile1);
            sql += ", @customerMobile2 = " + FilterString(customerMobile2);
            sql += ", @customerEmail1 = " + FilterString(customerEmail1);
            sql += ", @customerEmail2 = " + FilterString(customerEmail2);
            sql += ", @customerFax1 = " + FilterString(customerFax1);
            sql += ", @customerFax2 = " + FilterString(customerFax2);
            sql += ", @customerAddressPermanent = " + FilterString(customerAddressPermanent);
            sql += ", @permanentCity = " + FilterString(permanentCity);
            sql += ", @permanentCountry = " + FilterString(permanentCountry);
            sql += ", @customerAddressTemp = " + FilterString(customerAddressTemp);
            sql += ", @tempCity = " + FilterString(tempCity);
            sql += ", @tempCountry = " + FilterString(tempCountry);
            sql += ", @dob = " + FilterString(dob);
            sql += ", @gender = " + FilterString(gender);
            sql += ", @customerPassportNo = " + FilterString(customerPassportNo);
            sql += ", @passportIssueDate = " + FilterString(passportIssueDate);
            sql += ", @passportExpireDate = " + FilterString(passportExpireDate);
            sql += ", @salary = " + FilterString(salary);
            sql += ", @salaryCurrency = " + FilterString(salaryCurrency);
            sql += ", @designation = " + FilterString(designation);
            sql += ", @jobNature = " + FilterString(jobNature);
            sql += ", @contactPerson1 = " + FilterString(contactPerson1);
            sql += ", @contactPerson1Address = " + FilterString(contactPerson1Address);
            sql += ", @contactPerson1Phone = " + FilterString(contactPerson1Phone);
            sql += ", @contactPerson1Mobile = " + FilterString(contactPerson1Mobile);
            sql += ", @contactPerson1Fax = " + FilterString(contactPerson1Fax);
            sql += ", @contactPerson1Email = " + FilterString(contactPerson1Email);
            sql += ", @contactPerson2 = " + FilterString(contactPerson2);
            sql += ", @contactPerson2Address = " + FilterString(contactPerson2Address);
            sql += ", @contactPerson2Phone = " + FilterString(contactPerson2Phone);
            sql += ", @contactPerson2Mobile = " + FilterString(contactPerson2Mobile);
            sql += ", @contactPerson2Fax = " + FilterString(contactPerson2Fax);
            sql += ", @contactPerson2Email = " + FilterString(contactPerson2Email);
            sql += ", @contactPerson3 = " + FilterString(contactPerson3);
            sql += ", @contactPerson3Address = " + FilterString(contactPerson3Address);
            sql += ", @contactPerson3Phone = " + FilterString(contactPerson3Phone);
            sql += ", @contactPerson3Fax = " + FilterString(contactPerson3Fax);
            sql += ", @contactPerson3Mobile = " + FilterString(contactPerson3Mobile);
            sql += ", @contactPerson3Email = " + FilterString(contactPerson3Email);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}