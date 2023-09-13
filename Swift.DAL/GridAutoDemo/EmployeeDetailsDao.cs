using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.GridAutoDemo
{
    public class EmployeeDetailsDao : RemittanceDao
    {
        public DbResult EmployeeRegister(EmployeeModel employee)
        {
            var sql = "EXEC Pro_EmployeeDetails ";
            sql += "@flag=" + FilterString(employee.Flag);
            sql += ",@Id =" + FilterString(employee.Id.ToString());
            sql += ",@Name =" + FilterString(employee.Name);
            sql += ",@Address = " + FilterString(employee.Address);
            sql += ",@CompanyJoinDate=" + FilterString(employee.CompanyJoinDate.ToString());
            sql += ",@DepartName=" + FilterString(employee.DepartName);
            sql += ",@Description=" + FilterString(employee.Description);
            sql += ",@DOB=" + FilterString(employee.DOB.ToString());
            sql += ",@Email=" + FilterString(employee.Email);
            sql += ",@MobileNo=" + FilterString(employee.MobileNo);
            sql += ",@WorkDayOnWeek=" + FilterString(employee.WorkDayOnWeek.ToString());
            return ParseDbResult(sql);
        }

        public DataRow GetEmployeeDetails(string Id)
        {
            var sql = "EXEC Pro_EmployeeDetails";
            sql += " @Flag ='S'";
            sql += ",@Id =" + FilterString(Id);
            return ExecuteDataRow(sql);
        }

        public DbResult Delete(string id)
        {
            var sql = "EXEC Pro_EmployeeDetails";
            sql += " @Flag ='D'";
            sql += ",@Id =" + FilterString(id);
            return ParseDbResult(sql);
        }
    }
}