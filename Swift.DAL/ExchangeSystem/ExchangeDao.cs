using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;
using Swift.API.Common;
using log4net;

namespace Swift.DAL.ExchangeSystem {
  public class ExchangeDao : RemittanceDao {
    private readonly ILog _log = LogManager.GetLogger(typeof(RemittanceDao));
    public ExchangeDao() {
    }
    public DataSet mntTbaListLoadGrid(string flag, string currency, string user, string pageNumber, string pageSize, string sortBy, string sortOrder) {
      var sql = "EXEC Proc_Currency_Exchange_List @flag = '"+flag+"'";
      sql += ", @user =   " + FilterString(user);
      sql += ", @currency = " + FilterString(currency);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @sortBy = " + FilterString(sortBy);
      return ExecuteDataset(sql);
    }
    public DbResult ExchangeControl(string flag, string id, string user) {
      string sql = "EXEC proc_currencyExchange";
      sql += " @Flag = " + FilterString(flag);
      sql += " ,@id=" + FilterString(id);
      sql += ", @user = " + FilterString(user);
      return ParseDbResult(sql);
    }

    public DbResult UploadCurrencyExchange(ExrateCurrency mod) {
      string sql = "EXEC proc_currencyExchange";
      sql += " @Flag ='i'";
      sql += ", @orderId = " + FilterString(mod.orderId);
      sql += ", @type = " + FilterString(mod.type);
      sql += ", @paymentMode = " + FilterString(mod.paymentMode);
      sql += ", @lastName = N" + FilterString(mod.lastName);
      sql += ", @middleName = " + FilterString(mod.middleName);
      sql += ", @firstName = N" + FilterString(mod.firstName);
      sql += ", @rd = N" + FilterString(mod.regNumber);
      sql += ", @mobile = " + FilterString(mod.mobile);
      sql += ", @accountNumber = " + FilterString(mod.accountNumber);
      sql += ", @cRate = " + FilterString(mod.cRate);
      sql += ", @pRate = " + FilterString(mod.pRate);
      sql += ", @cCur = " + FilterString(mod.cCur);
      sql += ", @pCur = " + FilterString(mod.pCur);
      sql += ", @cashAmount1 = " + FilterString(mod.cashAmount1);
      sql += ", @cashAmount2 = " + FilterString(mod.cashAmount2);
      sql += ", @accAmount = " + FilterString(mod.accAmount);
      sql += ", @mntVal = " + FilterString(mod.mntVal);
      sql += ", @curVal = " + FilterString(mod.curVal);
      sql += ", @agentId = " + FilterString(mod.agentId);
      sql += ", @user = " + FilterString(mod.user);
      sql += ", @customerRate = " + FilterString(mod.customerRate);
      sql += ", @dob = " + FilterString(mod.dob);
      return ParseDbResult(sql);
    }

    public DataSet RateListLoadGrid(string flag, string user, string account, string pageNumber, string pageSize, string sortBy, string sortOrder) {
      var sql = "EXEC Proc_Currency_Exchange_List @flag = '"+flag+"'";
      sql += ", @user =   " + FilterString(user);
      sql += ", @account =   " + FilterString(account);
      sql += ", @pageSize = " + FilterString(pageSize);
      sql += ", @pageNumber = " + FilterString(pageNumber);
      sql += ", @sortOrder = " + FilterString(sortOrder);
      sql += ", @sortBy = " + FilterString(sortBy);
      return ExecuteDataset(sql);
    }

    public DbResult NubiaRateUpdate(string flag, string user, string rateId, string buy, string sale) {
      string sql = "EXEC proc_currencyExchange";
      sql += " @flag = "+FilterString(flag);
      sql += ", @user = " + FilterString(user);
      sql += ", @id = " + FilterString(rateId);
      sql += ", @cAmount = " + buy;
      sql += ", @pAmount = " + sale;
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult NubiaReplenishment(ReplenishmentModel data) {
      string sql = "EXEC proc_currencyExchange";
      sql += " @flag = '" + data.flag + "'";
      sql += ", @accountNumber = " + FilterString(data.account);
      sql += ", @cCur = " + FilterString(data.currency);
      sql += ", @user = " + FilterString(data.user);
      sql += ", @mntVal = " + FilterString(data.topUp);
      sql += ", @curVal = " + FilterString(data.remove);
      sql += ", @closeVal = " + FilterString(data.closeBalance);
      _log.Info("replenishment update : " + sql);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

  }
}
