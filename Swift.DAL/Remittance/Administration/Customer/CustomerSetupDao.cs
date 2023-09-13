using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.AgentPanel.Administration.Customer
{
    public class CustomerSetupDao : RemittanceDao
    {
        public DataTable Update(string user
                              , string customerId
                              , string firstName
                              , string middleName
                              , string lastName1
                              , string lastName2
                              , string country
                              , string customerIdType
                              , string customerIdNo
                              , string custIdValidDate
                              , string custDOB
                              , string custTelNo
                              , string custMobile
                              , string custCity
                              , string custPostal
                              , string companyName
                              , string custAdd1
                              , string custAdd2
                              , string custNativeCountry
                              , string custEmail
                              , string custGender
                              , string custSalary
                              , string memberId
                              , string occupation
                              , string isMemberIssued
                              , string agent
                              , string branch
                              )
        {
            string sql = "EXEC proc_customerSetup";
            sql += "  @flag = " + (customerId == "" || customerId == "0" ? "'i'" : "'u'");
            sql += ", @user = " + FilterStringNative(user);
            sql += ", @customerId = " + FilterStringNative(customerId);
            sql += ", @firstName = " + FilterStringNative(firstName);
            sql += ", @middleName = " + FilterStringNative(middleName);
            sql += ", @lastName1 = " + FilterStringNative(lastName1);
            sql += ", @lastName2 = " + FilterStringNative(lastName2);
            sql += ", @country = " + FilterStringNative(country);
            sql += ", @customerIdType = " + FilterStringNative(customerIdType);
            sql += ", @customerIdNo = " + FilterStringNative(customerIdNo);
            sql += ", @custIdValidDate = " + FilterStringNative(custIdValidDate);
            sql += ", @custDOB = " + FilterStringNative(custDOB);
            sql += ", @custTelNo = " + FilterStringNative(custTelNo);
            sql += ", @custMobile = " + FilterStringNative(custMobile);
            sql += ", @custCity = " + FilterStringNative(custCity);
            sql += ", @custPostal = " + FilterStringNative(custPostal);
            sql += ", @companyName = " + FilterStringNative(companyName);
            sql += ", @custAdd1 = " + FilterStringNative(custAdd1);
            sql += ", @custAdd2 = " + FilterStringNative(custAdd2);
            sql += ", @custNativecountry = " + FilterStringNative(custNativeCountry);
            sql += ", @custEmail = " + FilterStringNative(custEmail);
            sql += ", @custGender = " + FilterStringNative(custGender);
            sql += ", @custSalary = " + FilterStringNative(custSalary);
            sql += ", @memberId = " + FilterStringNative(memberId);
            sql += ", @occupation = " + FilterStringNative(occupation);
            sql += ", @isMemberIssued = " + FilterStringNative(isMemberIssued);
            sql += ", @agent = " + FilterStringNative(agent);
            sql += ", @branch = " + FilterStringNative(branch);
            return ExecuteDataset(sql).Tables[0];
        }

        public DbResult Delete(string user, string customerId)
        {
            string sql = "EXEC proc_customerSetup @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            return ParseDbResult(sql);
        }

        public DataRow SelectById(string user, string customerId)
        {
            string sql = "EXEC proc_customerSetup @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            return ExecuteDataset(sql).Tables[0].Rows[0];
        }

        public DataRow GetCustImageFileName(string user , string customerId)
        {
            string sql = "EXEC proc_customerSetup @flag = 'custImage'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            if (ExecuteDataset(sql).Tables[0].Rows.Count == 0 )
                return null;
            return ExecuteDataset(sql).Tables[0].Rows[0];
        }
    }
}
