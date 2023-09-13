using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;


namespace Swift.DAL.ApplicationLogs
{
    public class LogDAO : SwiftDao
    {
        public DataRow GetErrorDetails(string id)
        {
            var sql = "Exec proc_errorLogs @flag = 'a' ";
            sql += " ,@id = " + FilterString(id);
            return ExecuteDataRow(sql);
        }
    }
}
