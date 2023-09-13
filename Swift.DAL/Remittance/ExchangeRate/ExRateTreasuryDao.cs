using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
  public class ExRateTreasuryDao : RemittanceDao
  {
    public DbResult Insert(string user, string tranType, string cCurrency, string cCountry, string cAgent, string pCurrency, string pCountry, string pAgent
        , string tolerance, string cHoMargin, string cAgentMargin, string pHoMargin, string pAgentMargin, string sharingType, string sharingValue
        , string toleranceOn, string agentTolMin, string agentTolMax, string customerTolMin, string customerTolMax)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'i'";
      sql += ", @user = " + FilterString(user);
      sql += ", @tranType = " + FilterString(tranType);
      sql += ", @cCurrency = " + FilterString(cCurrency);
      sql += ", @cCountry = " + FilterString(cCountry);
      sql += ", @cAgent = " + FilterString(cAgent);
      sql += ", @pCurrency = " + FilterString(pCurrency);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @pAgent = " + FilterString(pAgent);
      sql += ", @tolerance = " + FilterString(tolerance);
      sql += ", @cHoMargin = " + FilterString(cHoMargin);
      sql += ", @cAgentMargin = " + FilterString(cAgentMargin);
      sql += ", @pHoMargin = " + FilterString(pHoMargin);
      sql += ", @pAgentMargin = " + FilterString(pAgentMargin);
      sql += ", @sharingType = " + FilterString(sharingType);
      sql += ", @sharingValue = " + FilterString(sharingValue);
      sql += ", @toleranceOn = " + FilterString(toleranceOn);
      sql += ", @agentTolMin = " + FilterString(agentTolMin);
      sql += ", @agentTolMax = " + FilterString(agentTolMax);
      sql += ", @customerTolMin = " + FilterString(customerTolMin);
      sql += ", @customerTolMax = " + FilterString(customerTolMax);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Update(string user, string exRateTreasuryId, string tolerance, string cHoMargin, string cAgentMargin, string pHoMargin, string pAgentMargin
                        , string sharingType, string sharingValue, string toleranceOn, string agentTolMin, string agentTolMax, string customerTolMin, string customerTolMax
                        , string crossRate, string agentCrossRateMargin, string customerRate, string isUpdated)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'u'";
      sql += ", @user = " + FilterString(user);
      sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);
      sql += ", @tolerance = " + FilterString(tolerance);
      sql += ", @cHoMargin = " + FilterString(cHoMargin);
      sql += ", @cAgentMargin = " + FilterString(cAgentMargin);
      sql += ", @pHoMargin = " + FilterString(pHoMargin);
      sql += ", @pAgentMargin = " + FilterString(pAgentMargin);
      sql += ", @sharingType = " + FilterString(sharingType);
      sql += ", @sharingValue = " + FilterString(sharingValue);
      sql += ", @toleranceOn = " + FilterString(toleranceOn);
      sql += ", @agentTolMin = " + FilterString(agentTolMin);
      sql += ", @agentTolMax = " + FilterString(agentTolMax);
      sql += ", @customerTolMin = " + FilterString(customerTolMin);
      sql += ", @customerTolMax = " + FilterString(customerTolMax);
      sql += ", @crossRate = " + FilterString(crossRate);
      sql += ", @agentCrossRateMargin = " + FilterString(agentCrossRateMargin);
      sql += ", @customerRate = " + FilterString(customerRate);
      sql += ", @isUpdated = " + FilterString(isUpdated);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public string UpdateXml(string user, string xml)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'uxml'";
      sql += ", @user = " + FilterString(user);
      sql += ", @xml = " + FilterString(xml);

      return GetSingleResult(sql);
    }

    public string UpdateXmlRia(string user, string xml)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'uxmlRia'";
      sql += ", @user = " + FilterString(user);
      sql += ", @xml = " + FilterString(xml);

      return GetSingleResult(sql);
    }

    public DbResult UpdateRateFromMaster(string user, string exRateTreasuryIds)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'ufm'";
      sql += ", @user = " + FilterString(user);
      sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataSet LoadGridAfterCostChange(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string defExRateId, string cRateId, string pRateId, string isUpdated, string haschanged, string isActive)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 's2'";
      sql += ", @user = " + FilterString(user);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @isUpdated = " + FilterString(isUpdated);
      sql += ", @hasChanged = " + FilterString(haschanged);
      sql += ", @isActive = " + FilterString(isActive);
      sql += ", @defExRateId = " + FilterString(defExRateId);
      sql += ", @cRateId = " + FilterString(cRateId);
      sql += ", @pRateId = " + FilterString(pRateId);

      return ExecuteDataset(sql);
    }

    public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType, string isUpdated, string haschanged, string isActive, string cRateId, string pRateId, string filterByPCountryOnly)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 's'";
      sql += ", @user = " + FilterString(user);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @cCountry = " + FilterString(cCountry);
      sql += ", @cAgent = " + FilterString(cAgent);
      sql += ", @cCurrency = " + FilterString(cCurrency);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @pAgent = " + FilterString(pAgent);
      sql += ", @pCurrency = " + FilterString(pCurrency);
      sql += ", @tranType = " + FilterString(tranType);
      sql += ", @isUpdated = " + FilterString(isUpdated);
      sql += ", @hasChanged = " + FilterString(haschanged);
      sql += ", @isActive = " + FilterString(isActive);
      sql += ", @cRateId = " + FilterString(cRateId);
      sql += ", @pRateId = " + FilterString(pRateId);
      sql += ", @filterByPCountryOnly = " + FilterString(filterByPCountryOnly);

      return ExecuteDataset(sql);
    }

    public DataSet LoadGridApprove(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string hasChanged, string cCountry, string cAgent, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'm'";
      sql += ", @user = " + FilterString(user);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @cCountry = " + FilterString(cCountry);
      sql += ", @cAgent = " + FilterString(cAgent);
      sql += ", @cCurrency = " + FilterString(cCurrency);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @pAgent = " + FilterString(pAgent);
      sql += ", @pCurrency = " + FilterString(pCurrency);
      sql += ", @tranType = " + FilterString(tranType);
      sql += ", @hasChanged = " + FilterString(hasChanged);

      return ExecuteDataset(sql);
    }

    public DataSet LoadGridReject(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string hasChanged, string cCountry, string cAgent, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'rl'";
      sql += ", @user = " + FilterString(user);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @cCountry = " + FilterString(cCountry);
      sql += ", @cAgent = " + FilterString(cAgent);
      sql += ", @cCurrency = " + FilterString(cCurrency);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @pAgent = " + FilterString(pAgent);
      sql += ", @pCurrency = " + FilterString(pCurrency);
      sql += ", @tranType = " + FilterString(tranType);
      sql += ", @hasChanged = " + FilterString(hasChanged);

      return ExecuteDataset(sql);
    }

    public DataSet LoadMyChangesList(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string hasChanged, string cCountry, string cAgent, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'mcl'";
      sql += ", @user = " + FilterString(user);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @sortBy = " + FilterString(sortBy);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @cCountry = " + FilterString(cCountry);
      sql += ", @cAgent = " + FilterString(cAgent);
      sql += ", @cCurrency = " + FilterString(cCurrency);
      sql += ", @pCountry = " + FilterString(pCountry);
      sql += ", @pAgent = " + FilterString(pAgent);
      sql += ", @pCurrency = " + FilterString(pCurrency);
      sql += ", @tranType = " + FilterString(tranType);
      sql += ", @hasChanged = " + FilterString(hasChanged);

      return ExecuteDataset(sql);
    }

    public DbResult Approve(string user, string exRateTreasuryIds)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'approve'";
      sql += ", @user = " + FilterString(user);
      sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult Reject(string user, string exRateTreasuryIds)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'reject'";
      sql += ", @user = " + FilterString(user);
      sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DataRow SelectCurrencyRate(string user, string currency, string country, string agent, string rateType)
    {
      var sql = "EXEC proc_exRateTreasury";
      sql += "  @flag = 'cr'";
      sql += ", @user = " + FilterString(user);
      sql += ", @currency = " + FilterString(currency);
      sql += ", @country = " + FilterString(country);
      sql += ", @agent = " + FilterString(agent);
      sql += ", @rateType = " + FilterString(rateType);

      var ds = ExecuteDataset(sql);
      if(ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        return null;
      return ds.Tables[0].Rows[0];
    }

    public DbResult MarkAsActiveInactive(string user, string exRateTreasuryIds, string isActive)
    {
      var sql = "EXEC proc_exRateTreasury @flag = 'ai'";
      sql += ", @user = " + FilterString(user);
      sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);
      sql += ", @isActive = " + FilterString(isActive);

      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
  }
}
