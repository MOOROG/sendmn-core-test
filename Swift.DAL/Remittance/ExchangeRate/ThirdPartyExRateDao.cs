using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.ExchangeRate
{
   public class ThirdPartyExRateDao : RemittanceDao
    {
        public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string countryName, string agent)
        {
            var sql = "EXEC Proc_ThirdPartyExRate @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @countryName = " + FilterString(countryName);
            sql += ", @agentName = " + FilterString(agent);

            return ExecuteDataset(sql);
        }
        public DbResult Update(string user, string settlementRate,
                                 string jmeMarginRate,
                                 string rateMarginOverTFRate,
                                 string customerRate,string overrideTFCustRate,
                                 string enableDisable,string rowId)
        {
            var sql = "EXEC Proc_ThirdPartyExRate @flag = 'update'";
            sql += ", @user = " + FilterString(user);
            sql += ", @settlementRate = " + FilterString(settlementRate);
            sql += ", @jmeMarginRate = " + FilterString(jmeMarginRate);
            sql += ", @rateMarginOverTFRate = " + FilterString(rateMarginOverTFRate);
            sql += ", @customerRate = " + FilterString(customerRate);
            sql += ", @overrideTFCustRate = " + FilterString(overrideTFCustRate);
            sql += ", @EnableDisable = " + FilterString(enableDisable);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(sql);
        }
    }
}
