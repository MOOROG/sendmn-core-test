using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class FieldSettingDao:SwiftDao
    {
        public DbResult Update(string user,string rowId,string country,string agent,string customerRegistration,string newCustomer,string collection,string id,
            string idIssueDate,string iDValidDate,string dOB,string address,string city,string contact,string occupation,string company,string salaryRange,string purposeofRemittance,
            string sourceofFund,string rId,string rPlaceOfIssue,string raddress,string rcity,string rContact,string rRelationShip, string rDOB,string rIdValidDate,string nativeCountry,
            string tXNHistory,string opeType)
        {
            var sql = "EXEC proc_sendPayTable";
            sql += "  @flag=" + (rowId == "0" || rowId=="" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @country = " + FilterString(country);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @customerRegistration = " + FilterString(customerRegistration);
            sql += ", @newCustomer = " + FilterString(newCustomer);
            sql += ", @collection = " + FilterString(collection);
            sql += ", @id = " + FilterString(id);
            sql += ", @idIssueDate = " + FilterString(idIssueDate);
            sql += ", @iDValidDate = " + FilterString(iDValidDate);
            sql += ", @dOB = " + FilterString(dOB);
            sql += ", @address = " + FilterString(address);
            sql += ", @city = " + FilterString(city);
            sql += ", @contact = " + FilterString(contact);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @company = " + FilterString(company);
            sql += ", @salaryRange = " + FilterString(salaryRange);
            sql += ", @purposeofRemittance = " + FilterString(purposeofRemittance);
            sql += ", @sourceofFund = " + FilterString(sourceofFund);
            sql += ", @rId = " + FilterString(rId);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @raddress = " + FilterString(raddress);
            sql += ", @rcity = " + FilterString(rcity);
            sql += ", @rContact = " + FilterString(rContact);
            sql += ", @rRelationShip = " + FilterString(rRelationShip);
            sql += ", @rDOB = " + FilterString(rDOB);
            sql += ", @rIdValidDate = " + FilterString(rIdValidDate);
            sql += ", @nativeCountry = " + FilterString(nativeCountry);
            sql += ", @tXNHistory = " + FilterString(tXNHistory);
            sql += ", @opeType = " + FilterString(opeType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult CopySetting(string user, string rowId, string country, string agent, string customerRegistration, string newCustomer, string collection, string id,
          string idIssueDate, string iDValidDate, string dOB, string address, string city, string contact, string occupation, string company, string salaryRange, string purposeofRemittance,
          string sourceofFund, string rId, string rPlaceOfIssue, string raddress, string rcity, string rContact, string rRelationShip, string rDOB, string rIdValidDate, string nativeCountry,
          string tXNHistory, string opeType)
        {
            var sql = "EXEC proc_sendPayTable";
            sql += "  @flag=" + (rowId == "0" || rowId == "" ? "'copy'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @country = " + FilterString(country);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @customerRegistration = " + FilterString(customerRegistration);
            sql += ", @newCustomer = " + FilterString(newCustomer);
            sql += ", @collection = " + FilterString(collection);
            sql += ", @id = " + FilterString(id);
            sql += ", @idIssueDate = " + FilterString(idIssueDate);
            sql += ", @iDValidDate = " + FilterString(iDValidDate);
            sql += ", @dOB = " + FilterString(dOB);
            sql += ", @address = " + FilterString(address);
            sql += ", @city = " + FilterString(city);
            sql += ", @contact = " + FilterString(contact);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @company = " + FilterString(company);
            sql += ", @salaryRange = " + FilterString(salaryRange);
            sql += ", @purposeofRemittance = " + FilterString(purposeofRemittance);
            sql += ", @sourceofFund = " + FilterString(sourceofFund);
            sql += ", @rId = " + FilterString(rId);
            sql += ", @rPlaceOfIssue = " + FilterString(rPlaceOfIssue);
            sql += ", @raddress = " + FilterString(raddress);
            sql += ", @rcity = " + FilterString(rcity);
            sql += ", @rContact = " + FilterString(rContact);
            sql += ", @rRelationShip = " + FilterString(rRelationShip);
            sql += ", @rDOB = " + FilterString(rDOB);
            sql += ", @rIdValidDate = " + FilterString(rIdValidDate);
            sql += ", @nativeCountry = " + FilterString(nativeCountry);
            sql += ", @tXNHistory = " + FilterString(tXNHistory);
            sql += ", @opeType = " + FilterString(opeType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult Update(string user,string rowId,string country,string agent,string id, string dOB,string address,string city,string contact,
            string nativeCountry,string tXNHistory,string opeType)
        { 
          return  Update( user, rowId, country, agent,"","","", id,"", "", dOB, address, city, contact,"","","","","","","","","","","","","", nativeCountry,
             tXNHistory, opeType);
        }

        public DbResult CopySetting(string user, string rowId, string country, string agent, string id, string dOB, string address, string city, string contact,
           string nativeCountry, string tXNHistory, string opeType)
        {
            return CopySetting(user, rowId, country, agent, "", "", "", id, "", "", dOB, address, city, contact, "", "", "", "", "", "", "", "", "", "", "", "", "", nativeCountry,
               tXNHistory, opeType);
        }


        public DataRow SelectById(string user, string rowId, string opeType)
        {
            var sql = "EXEC proc_sendPayTable";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @opeType = " + FilterString(opeType);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_sendPayTable";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
