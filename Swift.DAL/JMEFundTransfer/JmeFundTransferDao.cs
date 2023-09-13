using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.JMEFundTransfer
{
    public class JmeFundTransferDao : SwiftDao
    {
        public DbResult SaveSetting(string user, string description, string currency, string debitAc, string CreditAc)
        {
            string sql = "EXEC PROC_FUNDTRANSFER";
            sql = sql + " @flag = 'save'";
            sql = sql + ",@description=" + FilterString(description);
            sql = sql + ",@currency=" + FilterString(currency);
            sql = sql + ",@debitAc=" + FilterString(debitAc);
            sql = sql + ",@creditAc=" + FilterString(CreditAc);

            DbResult res = ParseDbResult(sql);
            return res;
        }
        public DataRow GetData(string user, string RowId)
        {
            string sql = "EXEC PROC_FUNDTRANSFER";
            sql += " @flag = 'getData'";
            sql += ",@rowId =" + FilterString(RowId);

            return ExecuteDataRow(sql);
        }
        public DbResult SaveFundTranfer(string user, string date, string description, string currency, string amount)
        {
            string sql = "EXEC PROC_FUNDTRANSFER";
            sql += " @flag = 'saveFundTransfer'";
            sql += ",@user = " + FilterString(user);
            sql += ",@date = " + FilterString(date);
            sql += ",@SETTINGS_ID = " + FilterString(description);
            sql += ",@currency = " + FilterString(currency);
            sql += ",@amount = " + FilterString(amount);
            return ParseDbResult(sql);
        }
    }
}
