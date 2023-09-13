using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Transaction.CustomerSoa
{
    public class CustomerSoaDao : RemittanceDao
    {
        public DataSet GetCustomerSao(string fromDate, string toDate, string email, string reportType)
        {
            string sql = "EXEC proc_CustomerSoa";
            sql += " @flag =" + FilterString(reportType);
            sql += " , @fromDate =" + FilterString(fromDate);
            sql += " , @toDate =" + FilterString(toDate);
            sql += "  ,@cusEmail =" + FilterString(email);

            return ExecuteDataset(sql);
        }
    }
}