using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class DeRateDao : SwiftDao
    {
        public DbResult Update(string user, string deRateId, string hub, string country, string baseCurrency, string localCurrency, string cost, string margin, string ve, string ne, string spFlag, string isEnable)
        {
            var sql = "EXEC proc_deRate";
            sql += "  @flag = " + (deRateId == "0" || deRateId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @deRateId = " + FilterString(deRateId);
            sql += ", @hub = " + FilterString(hub);
            sql += ", @country = " + FilterString(country);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @localCurrency = " + FilterString(localCurrency);
            sql += ", @cost = " + FilterString(cost);
            sql += ", @margin = " + FilterString(margin);
            sql += ", @ve = " + FilterString(ve);
            sql += ", @ne = " + FilterString(ne);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string deRateId)
        {
            var sql = "EXEC proc_deRate";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @deRateId = " + FilterString(deRateId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string deRateId)
        {
            var sql = "EXEC proc_deRate";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @deRateId = " + FilterString(deRateId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];

        } 
    }
}
