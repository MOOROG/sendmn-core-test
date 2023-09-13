using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomerSetupIntlDao : RemittanceDao
    {
        public DbResult Update(string user
                             , string customerId
                             , string senderId
                             , string membershipId
                             , string firstName
                             , string middleName
                             , string lastName1
                             , string lastName2
                             , string country
                             , string address
                             , string state
                             , string zipCode
                             , string district
                             , string city
                             , string email
                             , string homePhone
                             , string workPhone
                             , string mobile
                             , string nativeCountry
                             , string dob
                             , string occupation
                             , string gender
                             , string customerType
                             , string isBlackListed
                             , string relationId
                             , string relativeFullname
                             , string companyName
                             , string isMemberIssued
                             , string agent
                             , string branch
                             , string idType
                             , string idNumber
          )
        {
            string sql = "EXEC proc_customers";
            sql += "  @flag = " + (customerId == "0" || customerId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName1 = " + FilterString(lastName1);
            sql += ", @lastName2 = " + FilterString(lastName2);
            sql += ", @country = " + FilterString(country);
            sql += ", @address = " + FilterString(address);
            sql += ", @state = " + FilterString(state);
            sql += ", @zipCode = " + FilterString(zipCode);
            sql += ", @district = " + FilterString(district);
            sql += ", @city = " + FilterString(city);
            sql += ", @email = " + FilterString(email);
            sql += ", @homePhone = " + FilterString(homePhone);
            sql += ", @workPhone = " + FilterString(workPhone);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @nativeCountry = " + FilterString(nativeCountry);
            sql += ", @dob = " + FilterString(dob);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @gender = " + FilterString(gender);
            sql += ", @customerType = " + FilterString(customerType);
            sql += ", @isBlackListed = " + FilterString(isBlackListed);
            sql += ", @relationId = " + FilterString(relationId);
            sql += ", @relativeName = " + FilterString(relativeFullname);
            sql += ", @companyName = " + FilterString(companyName);
            sql += ", @isMemberIssued = " + FilterString(isMemberIssued);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @branch = " + FilterString(branch);
            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNumber = " + FilterString(idNumber);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Verify(string user, string customerId)
        {
            string sql = "EXEC proc_customers";
            sql += " @flag = 'app'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string customerId)
        {
            string sql = "EXEC proc_customers";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public string GetCustomerName(string customerId)
        {
            var sql = "EXEC proc_customers @flag='sn', @customerId=" + FilterString(customerId);
            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return "";

            return ds.Tables[0].Rows[0][0].ToString();
        }

        public DbResult Delete(string user, string customerId)
        {
            string sql = "EXEC proc_customers";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}