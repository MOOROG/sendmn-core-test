using Microsoft.SqlServer.Management.Smo;
using Swift.DAL.Common;
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

namespace Swift.DAL.SwiftDAL {
  public class LogDbDao {
    private SqlConnection _connection;

    public LogDbDao() {
      Init();
    }

    private void Init() {
      _connection = new SqlConnection(GetConnectionString());
    }

    private void OpenConnection() {
      if (_connection.State == ConnectionState.Open)
        _connection.Close();
      _connection.Open();
    }

    private void CloseConnection() {
      if (_connection.State == ConnectionState.Open)
        this._connection.Close();
    }

    private string GetConnectionString() {
      return ConfigurationSettings.AppSettings["LogConnectionString"].ToString();
    }

    public DataSet ExecuteDataset(string sql) {
      var ds = new DataSet();
      SqlDataAdapter da;

      try {
        OpenConnection();
        da = new SqlDataAdapter(sql, _connection);
        da.SelectCommand.CommandTimeout = 230;

        da.Fill(ds);
        da.Dispose();
        CloseConnection();
      } catch (Exception ex) {
        throw ex;
      } finally {
        da = null;
        CloseConnection();
      }
      return ds;
    }

    public DataTable ExecuteDataTable(string sql) {
      using (var ds = ExecuteDataset(sql)) {
        if (ds == null || ds.Tables.Count == 0)
          return null;

        return ds.Tables[0];
      }
    }

    public DataRow ExecuteDataRow(string sql) {
      using (var ds = ExecuteDataset(sql)) {
        if (ds == null || ds.Tables.Count == 0)
          return null;

        if (ds.Tables[0].Rows.Count == 0)
          return null;

        return ds.Tables[0].Rows[0];
      }
    }

    public String GetSingleResult(string sql) {
      try {
        var ds = ExecuteDataset(sql);
        if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
          return "";

        return ds.Tables[0].Rows[0][0].ToString();
      } catch (Exception ex) {
        throw ex;
      } finally {
        CloseConnection();
      }
    }

    public String FilterStringForXml(string strVal) {
      var str = FilterQuote(strVal);

      if (str.ToLower() == "null")
        str = "";

      //str = "'" + str + "'";

      return str;
    }

    public String FilterString(string strVal) {
      var str = FilterQuote(strVal);

      if (str.ToLower() != "null")
        str = "'" + str + "'";

      return str;
    }

    public String FilterStringUnicode(string strVal) {
      var str = FilterQuote(strVal);

      if (str.ToLower() != "null")
        str = "N'" + str + "'";

      return str;
    }

    public String FilterQuoteNative(string strVal) {
      if (string.IsNullOrEmpty(strVal)) {
        strVal = "";
      }
      var str = Encode(strVal.Trim());

      if (!string.IsNullOrEmpty(str)) {
        str = str.Replace(";", "");
        //str = str.Replace(",", "");
        str = str.Replace("--", "");
        str = str.Replace("'", "");

        str = str.Replace("/*", "");
        str = str.Replace("*/", "");

        str = str.Replace(" select ", "");
        str = str.Replace(" insert ", "");
        str = str.Replace(" update ", "");
        str = str.Replace(" delete ", "");

        str = str.Replace(" drop ", "");
        str = str.Replace(" truncate ", "");
        str = str.Replace(" create ", "");

        str = str.Replace(" begin ", "");
        str = str.Replace(" end ", "");
        str = str.Replace(" char(", "");

        str = str.Replace(" exec ", "");
        str = str.Replace(" xp_cmd ", "");

        str = str.Replace("<script", "");
      } else {
        str = "null";
      }
      return str;
    }

    private string Encode(string strVal) {
      var sb = new StringBuilder(HttpUtility.HtmlEncode(HttpUtility.JavaScriptStringEncode(strVal)));
      // Selectively allow <b> and <i>
      sb.Replace("&lt;b&gt;", "<b>");
      sb.Replace("&lt;/b&gt;", "");
      sb.Replace("&lt;i&gt;", "<i>");
      sb.Replace("&lt;/i&gt;", "");
      return sb.ToString();
    }

    public String FilterStringNativeTrim(string strVal) {
      var str = FilterQuoteNative(strVal);

      if (str.ToLower() != "null")
        str = "'" + str + "'";
      else
        str = "";

      return str;
    }

    public String FilterStringNative(string strVal) {
      var str = FilterQuoteNative(strVal);

      if (str.ToLower() != "null")
        str = "'" + str + "'";

      return str;
    }

    public string SingleQuoteToDoubleQuote(string strVal) {
      strVal = strVal.Replace("\"", "");
      return strVal.Replace("'", "\"");
    }

    public String FilterQuote(string strVal) {
      if (string.IsNullOrEmpty(strVal)) {
        strVal = "";
      }
      var str = strVal/*.Trim()*/;

      if (!string.IsNullOrEmpty(str)) {
        str = str.Replace(";", "");
        //str = str.Replace(",", "");
        str = str.Replace("--", "");
        str = str.Replace("'", "");

        str = str.Replace("/*", "");
        str = str.Replace("*/", "");

        str = str.Replace(" select ", "");
        str = str.Replace(" insert ", "");
        str = str.Replace(" update ", "");
        str = str.Replace(" delete ", "");

        str = str.Replace(" drop ", "");
        str = str.Replace(" truncate ", "");
        str = str.Replace(" create ", "");

        str = str.Replace(" begin ", "");
        str = str.Replace(" end ", "");
        str = str.Replace(" char(", "");

        str = str.Replace(" exec ", "");
        str = str.Replace(" xp_cmd ", "");

        str = str.Replace("<script", "");
      } else {
        str = "null";
      }
      return str;
    }

    public DbResult ParseDbResultV2(string sql) {
      return ParseDbResult(ExecuteDatasetV2(sql).Tables[0]);
    }

    public DataSet ExecuteDatasetV2(string sql) {
      var ds = new DataSet();
      using (var _connection = new SqlConnection(GetConnectionString())) {
        using (var cmd = new SqlCommand(sql, _connection)) {
          cmd.CommandTimeout = GetCommandTimeOut();
          SqlDataAdapter da;
          try {
            //OpenConnection();
            da = new SqlDataAdapter(cmd);
            da.Fill(ds);
            da.Dispose();
            //CloseConnection();
          } catch (Exception ex) {
            throw ex;
          } finally {
            da = null;
            //cmd.Dispose();
            //CloseConnection();
          }
        }
      }
      return ds;
    }

    private int GetCommandTimeOut() {
      int cto = 0;
      try {
        int.TryParse(ConfigurationSettings.AppSettings["eto"].ToString(), out cto);
        if (cto == 0)
          cto = 30;
      } catch (Exception) {
        cto = 30;
      }
      return cto;
    }

    public DbResult ParseDbResult(DataTable dt) {
      var res = new DbResult();
      if (dt.Rows.Count > 0) {
        res.ErrorCode = dt.Rows[0][0].ToString();
        res.Msg = dt.Rows[0][1].ToString();
        res.Id = dt.Rows[0][2].ToString();
      }
      if (dt.Columns.Count > 3) {
        res.Extra = dt.Rows[0][3].ToString();
      }
      if (dt.Columns.Count > 4) {
        res.Extra2 = dt.Rows[0][4].ToString();
      }
      if (dt.Columns.Count > 5) {
        res.Extra2 = dt.Rows[0][5].ToString();
      }
      return res;
    }

    public DbResult ParseDbResult(string sql) {
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }

    public DbResult ExecuteJob(string jobName) {
      Server server = new Server("10.90.77.61");
      server.ConnectionContext.LoginSecure = false;
      server.ConnectionContext.Login = "Arjun";
      server.ConnectionContext.Password = "@RjUn@jM3rEm!TdB@J@pAn#$Jm3";
      server.ConnectionContext.Connect();
      //server.JobServer.Jobs["Txn Sync"]?.Start();

      var job = server.JobServer.Jobs[jobName];
      if (job.CurrentRunStatus.ToString() == "Idle") {
        job.Start();
      }
      DbResult _resp = new DbResult();
      _resp.Msg = (job.CurrentRunStatus.ToString() == "Idle") ? "Job started successfully" : "Job is already running";
      _resp.ErrorCode = (job.CurrentRunStatus.ToString() == "Idle") ? "0" : "1"; ;

      //Console.WriteLine(job.CurrentRunStatus.ToString()); // Current running status

      return _resp;
    }

    public UserDetails ParseLoginResult(DataTable dt, Location location = null) {
      var res = new UserDetails();

      if (dt.Rows.Count > 0) {
        var row = dt.Rows[0];
        res.ErrorCode = (row[0] ?? "").ToString();
        res.Msg = (row[1] ?? "").ToString();
        res.logId = (row["rowId"] ?? "").ToString();

        if (res.ErrorCode == "0") {
          res.UserId = (row["UserId"] ?? "").ToString();
          res.FullName = (row["fullName"] ?? "").ToString();
          res.Address = (row["address"] ?? "").ToString();
          res.LastLoginTs = (row["LastLoginTs"] ?? "").ToString();
          res.UserAccessLevel = (row["userAccessLevel"] ?? "").ToString();
          res.Branch = (row["branchId"] ?? "").ToString();
          res.BranchName = (row["BRANCH_NAME"] ?? "").ToString();
          res.UserType = (row["UserType"] ?? "").ToString();
          res.isForcePwdChanged = (row["isForcePwdChanged"] ?? "").ToString();
          res.sessionTimeOut = row["sessionTimeOutPeriod"].ToString();
          res.UserUniqueKey = row["UserUniqueKey"].ToString();
          res.LoggedInCountry = location.CountryName + " (" + location.CountryCode + ")";
          res.LoginAddress = location.Region + ", " + location.City + ", " + location.ZipCode;
        }
      }
      return res;
    }

    public UserDetails ParseAgentLoginResult(DataTable dt, Location location = null) {
      var res = new UserDetails();

      if (dt.Rows.Count > 0) {
        var row = dt.Rows[0];
        res.Id = (row["Id"] ?? "").ToString();
        res.ErrorCode = (row["ErrorCode"] ?? "").ToString();
        res.Msg = (row["Mes"] ?? "").ToString();
        res.logId = (row["rowId"] ?? "").ToString();

        if (res.ErrorCode == "2") {
          res.AttemptCount = Convert.ToInt16((row["ac"] ?? "0").ToString());
        }

        if (dt.Columns.Count > 5) {
          res.UserId = (row["UserId"] ?? "").ToString();
          res.LastLoginTs = (row["lastLoginTs"] ?? "").ToString();
          res.FullName = (row["fullName"] ?? "").ToString();
          res.UserAccessLevel = (row["userAccessLevel"] ?? "").ToString();
          res.sessionTimeOut = (row["sessionTimeOutPeriod"] ?? "").ToString();
          res.Country = (row["country"] ?? "").ToString();
          res.CountryId = (row["countryId"] ?? "").ToString();
          res.Branch = (row["branch"] ?? "").ToString();
          res.BranchName = (row["branchName"] ?? "").ToString();
          res.Agent = (row["agent"] ?? "").ToString();
          res.AgentName = (row["agentName"] ?? "").ToString();
          res.SuperAgent = (row["superAgent"] ?? "").ToString();
          res.SuperAgentName = (row["superAgentName"] ?? "").ToString();
          res.SettlingAgent = (row["settlingAgent"] ?? "").ToString();
          res.MapCodeInt = (row["mapCodeInt"] ?? "").ToString();
          res.ParentMapCodeInt = (row["parentMapCodeInt"] ?? "").ToString();
          res.MapCodeDom = (row["mapCodeDom"] ?? "").ToString();
          res.AgentType = (row["agentType"] ?? "").ToString();
          res.IsActAsBranch = (row["isActAsBranch"] ?? "").ToString();
          res.FromSendTrnTime = (row["fromSendTrnTime"] ?? "").ToString();
          res.ToSendTrnTime = (row["toSendTrnTime"] ?? "").ToString();
          res.FromPayTrnTime = (row["fromSendTrnTime"] ?? "").ToString();
          res.ToPayTrnTime = (row["toPayTrnTime"] ?? "").ToString();
          res.UserType = (row["userType"] ?? "").ToString();
          res.IsHeadOffice = (row["isHeadOffice"] ?? "").ToString();
          res.AgentLocation = (row["agentLocation"] ?? "").ToString();
          res.AgentGrp = (row["agentGrp"] ?? "").ToString();
          res.AgentEmail = (row["agentEmail"] ?? "").ToString();
          res.AgentPhone = (row["agentPhone"] ?? "").ToString();
          res.isForcePwdChanged = (row["isForcePwdChanged"] ?? "").ToString();
          res.UserUniqueKey = (row["UserUniqueKey"] ?? "").ToString();

          res.LoggedInCountry = location.CountryName + " (" + location.CountryCode + ")";
          res.LoginAddress = location.Region + ", " + location.City + ", " + location.ZipCode;

          if (row.Table.Columns.Contains("newBranchId")) {
            res.newBranchId = (row["newBranchId"] ?? "").ToString();
          }
        }
      }
      return res;
    }

    #region ParseReportResult

    public ReportResult ParseReportResult(DataSet ds, string sql) {
      var res = new ReportResult();

      res.Sql = sql;
      res.Result = ds;

      if (ds == null || ds.Tables.Count == 0)
        return res;

      var tableCount = ds.Tables.Count;

      if (tableCount > 3) {
        res.ReportHead = ds.Tables[tableCount - 1].Rows[0][0].ToString();
      }

      if (tableCount > 2) {
        var html = new StringBuilder("");
        var hasFilters = false;
        foreach (DataRow dr in ds.Tables[tableCount - 2].Rows) {
          html.Append(" | " + dr[0] + "=" + dr[1]);
          hasFilters = true;
        }

        res.Filters = hasFilters ? html.ToString().Substring(2) : "";
      }

      if (tableCount > 1) {
        var pos = tableCount - 3;
        if (pos < 1)
          pos = 1;

        var dbresult = ParseDbResult(ds.Tables[pos]);
        res.ErrorCode = dbresult.ErrorCode;
        res.Msg = dbresult.Msg;
        res.Id = dbresult.Id;
        res.ResultSet = ds.Tables[0];
      }

      return res;
    }

    public ReportResult ParseReportResult(string sql) {
      var ds = ExecuteDataset(sql);
      return ParseReportResult(ds, sql);
    }

    public ReportResult ParseReportResult(DataSet ds) {
      return ParseReportResult(ds, "");
    }

    #endregion ParseReportResult

    public DataTable GetTable2(string sql) {
      return ExecuteDataset(sql).Tables[1];
    }

    protected string ParseData(string data) {
      return data.Replace("\"", "").Replace("'", "").Trim();
    }

    public string AutoSelect(string str1, string str2) {
      if (str1.ToLower() == str2.ToLower())
        return "selected=\"selected\"";

      return "";
    }

    protected string ParseDate(string data) {
      data = FilterString(data);
      if (data.ToUpper() == "NULL")
        return data;
      data = data.Replace("'", "");
      var dateParts = data.Split('/');
      if (dateParts.Length < 3)
        return "NULL";
      var m = dateParts[0];
      var d = dateParts[1];
      var y = dateParts[2];

      return "'" + y + "-" + (m.Length == 1 ? "0" + m : m) + "-" + (d.Length == 1 ? "0" + d : d) + "'";
    }

    public DataTable GetTable(string sql) {
      var ds = new DataSet();
      SqlDataAdapter da;

      try {
        OpenConnection();
        da = new SqlDataAdapter(sql, _connection);

        da.Fill(ds);
        da.Dispose();
        CloseConnection();
      } catch (Exception ex) {
        throw ex;
      } finally {
        da = null;
        CloseConnection();
      }
      return ds.Tables[0];
    }

    public void ExecuteProcedure(string spName, SqlParameter[] param) {
      try {
        OpenConnection();
        SqlCommand command = new SqlCommand(spName, _connection);
        command.CommandType = CommandType.StoredProcedure;

        foreach (SqlParameter p in param) {
          command.Parameters.Add(p);
        }
        command.ExecuteNonQuery();
      } catch (Exception ex) {
        throw ex;
      } finally {
        CloseConnection();
      }
    }

    public string DataTableToText(ref DataTable dt, string delemeter, Boolean includeColHeader) {
      var sb = new StringBuilder();
      var del = "";
      var rowcnt = 0;
      if (includeColHeader) {
        foreach (DataColumn col in dt.Columns) {
          sb.Append(del);
          sb.Append(col.ColumnName);
          del = delemeter;
        }
        rowcnt++;
      }

      foreach (DataRow row in dt.Rows) {
        if (rowcnt > 0) {
          sb.AppendLine();
        }
        del = "";
        foreach (DataColumn col in dt.Columns) {
          sb.Append(del);
          sb.Append(row[col.ColumnName].ToString());
          del = delemeter;
        }
        rowcnt++;
      }
      return sb.ToString();
    }

    public string DataTableToText(ref DataTable dt, string delemeter) {
      return DataTableToText(ref dt, delemeter, true);
    }

    public string DataTableToHTML(ref DataTable dt, Boolean includeColHeader) {
      var sb = new StringBuilder("<table>");

      if (includeColHeader) {
        sb.AppendLine("<tr>");
        foreach (DataColumn col in dt.Columns) {
          sb.Append("<th>" + col.ColumnName + "</th>");
        }
        sb.AppendLine("</tr>");
      }

      foreach (DataRow row in dt.Rows) {
        sb.AppendLine("<tr>");
        foreach (DataColumn col in dt.Columns) {
          sb.Append("<td>" + row[col.ColumnName].ToString() + "</td>");
        }
        sb.AppendLine("</tr>");
      }
      sb.AppendLine("</table>");
      return sb.ToString();
    }

    public string DataTableToHTML(ref DataTable dt) {
      return DataTableToHTML(ref dt, true);
    }

    public DbResult TryParseSQL(string sql) {
      var dr = new DbResult();
      try {
        OpenConnection();
        using (SqlCommand command = new SqlCommand()) {
          command.Connection = _connection;
          command.CommandType = CommandType.Text;
          command.CommandText = "SET NOEXEC ON " + sql + " SET NOEXEC OFF"; ;
          command.ExecuteNonQuery();
          dr.ErrorCode = "0";
          dr.Msg = "Success";
        }
        return dr;
      } catch (Exception ex) {
        dr.ErrorCode = "1";
        dr.Msg = FilterQuote(ex.Message);
        return dr;
      } finally {
        CloseConnection();
      }
    }

    public DataTable DecodeLogData(DataTable logTable) {
      var data = GetDataTemplete(logTable);
      if (string.IsNullOrWhiteSpace(data)) {
        return null;
      }

      var fieldList = new ArrayList();
      fieldList.Add("Table");
      fieldList.Add("ChangedDate");
      fieldList.Add("ChangedBy");
      fieldList.Add("ChangedType");
      fieldList.Add("DataID");

      var dt = CreateDataTableFromLogData(data, fieldList);

      foreach (DataRow row in logTable.Rows) {
        DataRow newRow = dt.NewRow();
        newRow["Table"] = row["tableName"].ToString();
        newRow["ChangedDate"] = row["createdDate"].ToString();
        newRow["ChangedBy"] = row["createdBy"].ToString();
        newRow["ChangedType"] = row["logType"].ToString();
        newRow["DataID"] = row["dataId"].ToString();

        CreateDataRowFromLogData(ref newRow, row["newData"].ToString());
        dt.Rows.Add(newRow);
      }

      return dt;
    }

    #region Helper

    private string GetDataTemplete(DataTable dt) {
      var data = "";
      foreach (DataRow row in dt.Rows) {
        data = row["OldData"].ToString();
        if (string.IsNullOrWhiteSpace(data)) {
          data = row["OldData"].ToString();
        }
        if (!string.IsNullOrWhiteSpace(data)) {
          return data;
        }
      }
      return data;
    }

    private DataTable CreateDataTableFromLogData(string data, ArrayList defaultFields) {
      var dt = new DataTable();

      foreach (var fld in defaultFields) {
        dt.Columns.Add(fld.ToString());
      }

      var stringSeparators = new[] { "-:::-" };
      var dataList = data.Split(stringSeparators, StringSplitOptions.None);
      const string seperator = "=";
      foreach (var itm in dataList) {
        var seperatorPos = itm.IndexOf(seperator);
        if (seperatorPos > -1) {
          var field = itm.Substring(0, seperatorPos - 1).Trim();
          dt.Columns.Add(field);
        }
      }
      return dt;
    }

    private void CreateDataRowFromLogData(ref DataRow row, string data) {
      var stringSeparators = new[] { "-:::-" };
      var dataList = data.Split(stringSeparators, StringSplitOptions.None);

      const string seperator = "=";
      foreach (var itm in dataList) {
        var seperatorPos = itm.IndexOf(seperator);
        if (seperatorPos > -1) {
          var field = itm.Substring(0, seperatorPos - 1).Trim();
          var value = itm.Substring(seperatorPos + 1).Trim();

          row[field] = value;
        }
      }
    }

    public DataTable getTable(string sql) {
      return ExecuteDataTable(sql);
    }

    public DbResult DeleteLoanState(string id) {
      string sql = "Exec [proc_loanState]";
      sql += " @flg ='delete'";
      sql += ", @loanStateID=" + FilterString(id);
      return ParseDbResult(sql);
    }
    #endregion Helper
  }
}