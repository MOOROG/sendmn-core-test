using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Amendment
{
   public class AmendmentDao : RemittanceDao
    {
        public DataSet GetAmendmentReport(string user, string customerId, string rowId,string changeType,string receiverId)
        {
            string sql = "EXEC PROC_AMENDMENTLIST";
            sql += " @flag = 'NEW-CHANGE'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @rowId= " + FilterString(rowId);
            sql += ", @changeType = " + FilterString(changeType);
            sql += ", @receiverId = " + FilterString(receiverId);

            return ExecuteDataset(sql);
        }
    }
}
