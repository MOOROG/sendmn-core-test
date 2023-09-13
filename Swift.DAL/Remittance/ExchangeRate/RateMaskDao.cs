using System.Data;
using log4net;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.SwiftDAL;


namespace Swift.DAL.BL.Remit.ExchangeRate {
  public class RateMaskDao : RemittanceDao {
    private readonly ILog _log = LogManager.GetLogger(typeof(RemittanceDao));

    public DbResult Update(string user, string ratemaskId, string baseCurrency, string currencyId, string mulBd, string mulAd, string divBd, string divAd, string cMin, string cMax, string pMin, string pMax) {
      string sql = "EXEC proc_rateMask";
      sql += " @flag = " + (ratemaskId == "0" || ratemaskId == "" ? "'i'" : "'u'");
      sql += ", @user = " + FilterString(user);
      sql += ", @rmID = " + FilterString(ratemaskId);
      sql += ", @baseCurrency = " + FilterString(baseCurrency);
      sql += ", @currency = " + FilterString(currencyId);
      sql += ", @rateMaskMulBd = " + FilterString(mulBd);
      sql += ", @rateMaskMulAd = " + FilterString(mulAd);
      sql += ", @rateMaskDivBd = " + FilterString(divBd);
      sql += ", @rateMaskDivAd = " + FilterString(divAd);
      sql += ", @cMin = " + FilterString(cMin);
      sql += ", @cMax = " + FilterString(cMax);
      sql += ", @pMin = " + FilterString(pMin);
      sql += ", @pMax = " + FilterString(pMax);
      //sql += ", @factor = " + FilterString(factor);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string currency) {
      var sql = "EXEC proc_rateMask @flag = 's'";
      sql += ", @user =   " + FilterString(user);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @currency = " + FilterString(currency);

      return ExecuteDataset(sql);
    }
  }

}
