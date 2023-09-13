using Newtonsoft.Json;
using Swift.API.Common;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.Services;
using static Swift.DAL.Model.Monpep;

namespace Swift.web {
  [WebService(Namespace = "http://tempuri.org/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [System.Web.Script.Services.ScriptService]
  public class Autocomplete : System.Web.Services.WebService {
    private RemittanceDao swift = null;
    private SwiftDao _acntDao = null;

    public Autocomplete() {
      swift = new RemittanceDao();
      _acntDao = new SwiftDao();
    }

    [WebMethod]
    public string[] GetAccountList(string prefixText, int count) {
      var sql = "Select acct_name +'|'+ acct_num as acct_name,acct_num from ac_master with(nolock) where  acct_name like'" + prefixText + "'+'%' order by acct_id";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        items.SetValue(dr["acct_name"].ToString(), i);
        i++;
      }
      return items;
    }

    [WebMethod]
    public List<AutoCompleteItem> GetAgentListForRiskProfiling(string keywordStartsWith) {
      var output = new List<AutoCompleteItem>();
      var sql = "EXEC proc_agentRiskProfiling @flag='l1', @agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      foreach(DataRow dr in dt.Rows) {
        output.Add(new AutoCompleteItem(dr["agentId"].ToString(), dr["agentName"].ToString()));
      }
      return output;
    }

    [WebMethod]
    public string[] GetAgentList(string prefixText, int count) {
      var sql = "Select agentName +'|'+ CAST(agentId AS VARCHAR) AS agentName, agentId from agentMaster with(nolock) WHERE isSettlingAgent = 'Y' AND agentName LIKE'" + prefixText + "'+'%' order by agentName";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        items.SetValue(dr["agentName"].ToString(), i);
        i++;
      }
      return items;
    }

    [WebMethod]
    public string[] GetSendingList(string prefixText, int count) {
      var sql =
          "SELECT agentName + '|' + CAST(agentId AS VARCHAR) AS agentName,agentId FROM agentMaster WITH(NOLOCK) WHERE agentName LIKE '" +
          prefixText + "' + '%' ORDER BY agentId";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        items.SetValue(dr["agentName"].ToString(), i);
        i++;
      }
      return items;
    }

    [WebMethod]
    public string[] GetGLCode(string keywordStartsWith) {
      var sql =
          "SELECT gl_name+'|'+CAST(gl_code AS VARCHAR) as gl_name, gl_code FROM dbo.GL_GROUP WITH(NOLOCK) WHERE gl_name LIKE '" +
          keywordStartsWith + "' + '%' ORDER BY gl_code";
      var dt = _acntDao.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        items.SetValue(dr["gl_name"].ToString(), i);
        i++;
      }
      return items;
    }

    #region all domstic agent part

    [WebMethod]
    public IList<string> GetDomesticAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='dAgent',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetDomesticAgentNameOnly(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_autocomplete @category='d-agentname-only',@searchText='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetPrivateAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='privateAgent',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetBankList(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='dBank',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetCashPayAllowedAgent(string keywordStartsWith, string controlNo) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='privateAgent',@controlNo='" + controlNo + "',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetAccountDepositAllowedBank(string keywordStartsWith, string controlNo) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='acdepositbank',@controlNo='" + controlNo + "',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetDomesticAgentWithMapCode(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='dAgent2',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        //+ "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetAllDomPayAgent(string keywordStartsWith) {
      // dummy implementation
      IList<string> output = new List<string>();

      var sql = "select agentName, agentId from agentMaster WHERE agentCountry='Nepal' and agentName like '" + keywordStartsWith + "%' order by agentName";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString() + "-" + dr["agentId"].ToString());
        i++;
      }

      return output;
    }

    #endregion all domstic agent part

    [WebMethod]
    public string[] GetBillByBillAcc(string prefixText, int count, string contextKey) {
      string[] a = contextKey.Split('|');
      string accontNo = a[0];
      string sessionId = a[1];

      var sql = "Exec [procBillByBillRunningBalanceList]  @BILL_REF = " + swift.FilterString(prefixText.Trim()) + ",@sessionID=" + swift.FilterString(sessionId) + " ,@acct_num=" + swift.FilterString(accontNo);
      var dt = swift.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        string concateValue = dr["BILL_REF"].ToString() + '-' + GetStatic.ShowDecimal(dr["REMAIN_AMT"].ToString()) + '-' + dr["PART_TRN_TYPE"].ToString() + '-' + '(' + dr["TRN_DATE"].ToString() + ')';
        items.SetValue(concateValue, i);
        i++;
      }

      return items;
    }

    [WebMethod]
    public string[] GetBillRefAcc(string prefixText, int count) {
      var sql = "Select b.bill_ref +' | '+ acct_name as acc_name from ac_master a with(nolock) inner join BILL_BY_BILL b on b.ACC_NUM = a.acct_num where acct_name like '" + prefixText + "%' and b.BILL_REF<>'null' order by acct_id";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      string[] items = new string[dt.Rows.Count];
      var i = 0;

      foreach(DataRow dr in dt.Rows) {
        items.SetValue(dr["acc_name"].ToString(), i);
        i++;
      }
      return items;
    }

    [WebMethod]
    public IList<string> GetAllAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "EXEC proc_agentSearchAutocomplete @FLAG='A',@searchField=" + swift.FilterString(keywordStartsWith) + "";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"] + "-" + dr["agentId"]);
        i++;
      }
      return output;
    }

    [WebMethod]
    public IList<string> GetBranchAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "EXEC proc_agentSearchAutocomplete @FLAG='b',@searchField=" + swift.FilterString(keywordStartsWith) + "";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        i++;
      }
      return output;
    }

    [WebMethod]
    public IList<string> GetIMEPrivateAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "EXEC proc_agentSearchAutocomplete @FLAG='c',@searchField=" + swift.FilterString(keywordStartsWith) + "";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        i++;
      }
      return output;
    }

    [WebMethod]
    public IList<string> GetPrivateAgentV2(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "EXEC proc_agentSearchAutocomplete @FLAG='cv2',@searchField=" + swift.FilterString(keywordStartsWith) + "";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        i++;
      }
      return output;
    }

    [WebMethod]
    public IList<string> GetAgentNameList(string keywordStartsWith) {
      IList<string> output = new List<string>();
      var sql = "EXEC proc_dropDownLists @flag = 'agentList', @param =" + swift.FilterString(keywordStartsWith);

      var dt = swift.ExecuteDataset(sql).Tables[0];

      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
      }
      return output;
    }

    [WebMethod]
    public IList<string> GetSchoolCollegeAgent(string keywordStartsWith) {
      IList<string> output = new List<string>();

      var sql = "exec proc_agentPicker @flag='dAgent3',@agentName='" + keywordStartsWith + "%'";
      var dt = swift.ExecuteDataset(sql).Tables[0];

      string[] items = new string[dt.Rows.Count];

      var i = 0;
      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
        i++;
      }

      return output;
    }

    [WebMethod]
    public IList<string> GetAgentNameListFilter(string keywordStartsWith) {
      IList<string> output = new List<string>();
      var sql = "EXEC proc_dropDownLists @flag = 'agentListAll', @param =" + swift.FilterString(keywordStartsWith);

      var dt = swift.ExecuteDataset(sql).Tables[0];

      foreach(DataRow dr in dt.Rows) {
        output.Add(dr["agentName"].ToString());
      }
      return output;
    }

    [WebMethod]
    public string GetErrorTransactionList() {
      var sql = "select * from remitTran where payStatus = 'Post' and tranStatus = 'Payment' and ISNULL(DATEDIFF(minute,postedDate,GETDATE()),'0') > 10";

      var dt = swift.ExecuteDataset(sql).Tables[0];

      if(dt.Rows.Count > 0) {
        return "You have pending trx : " + dt.Rows.Count;
      }
      return "";
    }

    [WebMethod]
    public string GetNotice(int cntryId) {
      var sql = "select noticeTxt from countryMaster where countryId = " + cntryId;
      string retVal = swift.GetSingleResult(sql);
      return retVal;
    }

    [WebMethod]
    public string GetCustomer(string register) {
      Customer customer = new Customer();
      var sql = "Select b.customerId,b.rd,b.ovog,b.ner,b.huis,b.aimag,b.sum,b.hayag,b.birthday,b.phones,b.photo1,b.photo2,b.photo3,b.photo4," +
                "b.photo5,c.countryId nationality,b.email from branchCustomer b left join countryMaster c on b.nationality = c.countryId where rd = N'" + register + "'";
      var dt = swift.ExecuteDataset(sql).Tables[0];
      customer.folderPath = GetStatic.ReadWebConfig("customerIdsDocPath", "");
      foreach(DataRow dr in dt.Rows) {
        customer.customerId = dr["customerId"].ToString();
        customer.register = dr["rd"].ToString();
        customer.firstName = dr["ner"].ToString();
        customer.lastName = dr["ovog"].ToString();
        customer.aimag = dr["aimag"].ToString();
        customer.sum = dr["sum"].ToString();
        customer.address = dr["hayag"].ToString();
        customer.phones = dr["phones"].ToString();
        customer.photo1 = dr["photo1"].ToString();
        customer.photo2 = dr["photo2"].ToString();
        customer.photo3 = dr["photo3"].ToString();
        customer.photo4 = dr["photo4"].ToString();
        customer.photo5 = dr["photo5"].ToString();
        customer.nationality = dr["nationality"].ToString();
        customer.email = dr["email"].ToString();
      }
      return JsonConvert.SerializeObject(customer);
    }

    public class Customer {
      public string customerId { get; set; }
      public string register { get; set; }
      public string firstName { get; set; }
      public string lastName { get; set; }
      public string gender { get; set; }
      public string aimag { get; set; }
      public string sum { get; set; }
      public string address { get; set; }
      public string birthday { get; set; }
      public string phones { get; set; }
      public string photo1 { get; set; }
      public string photo2 { get; set; }
      public string photo3 { get; set; }
      public string photo4 { get; set; }
      public string photo5 { get; set; }
      public string folderPath { get; set; }
      public string nationality { get; set; }
      public string email { get; set; }
    }

    [WebMethod]
    public object UpdateBlacklist(string cusId, string reasonTxt, string holdFlg, string accNum, string mobile) {
      string retVal = "";
      string sql = "Exec [proc_updateBlacklisted]";
      sql += " @cusId=" + swift.FilterString(cusId);
      sql += ", @reasonTxt=" + swift.FilterString(reasonTxt);
      sql += ", @holdFlg=" + swift.FilterString(holdFlg);
      sql += ", @accNum=" + swift.FilterString(accNum);
      sql += ", @mobile=" + swift.FilterString(mobile);
      DataTable dt = swift.ExecuteDataset(sql).Tables[0];
      //foreach (DataRow dr in dt.Rows) {
      //  retVal = "{descr : " + dr["descr"].ToString() + ", isActive:" + dr["isActive"].ToString() + "}";
      //}
      return dataTableToJSON(dt);
    }

    [WebMethod]
    public string UpdateAbsence(string id, int flg) {
      var sql = "";
      if(flg == 0) {
        sql = "update employeeAbsence set approve = 1 where id = " + id;
      } else {
        sql = "update employeeAbsence set approves = 1  where id = " + id;
      }
      swift.ExecuteDataset(sql);
      return "success";
    }

    [WebMethod]
    public string EnableDisable(string id, int flg) {
      var sql = "update blacklistedAccounts set is_active = " + flg + " where id = " + id;
      swift.ExecuteDataset(sql);
      return "success";
    }

    [WebMethod]
    public object GetAbsenceList(string month) {
      DateTime dts = DateTime.Parse(month);
      var sql = "select id, uid, reason as title,format(fromDt, 'yyyy-MM-dd') as start,format(DATEADD(day, 1, toDt), 'yyyy-MM-dd') as 'end',approve,approves, " +
                "case when toDt < GETDATE() then 'gray' " +
                "else " +
                "case when (approve is null and approves is null) then 'red' " +
                "else 'green' end " +
                "end as absColor from employeeAbsence where MONTH(fromDt) = " + dts.Month;
      var dt = swift.ExecuteDataset(sql).Tables[0];
      return dataTableToJSON(dt);
    }

    public static object dataTableToJSON(DataTable table) {
      var list = new List<Dictionary<string, object>>();
      foreach(DataRow row in table.Rows) {
        var dict = new Dictionary<string, object>();
        foreach(DataColumn col in table.Columns) {
          dict[col.ColumnName] = (Convert.ToString(row[col]));
        }
        list.Add(dict);
      }
      JavaScriptSerializer serializer = new JavaScriptSerializer();
      return serializer.Serialize(list);
    }

    [WebMethod]
    public string SaveFileToServer(string imageData, string fileName) {
      string path = @"D:\downloads\" + fileName;
      string fileNameWitPath = path + "-" + DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").Replace("/", "").Replace(" ", "").Replace(":", "") + ".png";
      string stampImg = @"D:\downloads\SanhuuTamga.png";
      using(FileStream fs = new FileStream(fileNameWitPath, FileMode.Create)) {
        using(BinaryWriter bw = new BinaryWriter(fs)) {
          byte[] data = Convert.FromBase64String(imageData);
          bw.Write(data);
          bw.Close();
        }
      }

      Image bitmap = (System.Drawing.Image)Bitmap.FromFile(fileNameWitPath);
      Image bitmaps = (System.Drawing.Image)Bitmap.FromFile(stampImg);
      Image btmp = new Bitmap(bitmap.Width, bitmap.Height);

      using(Graphics gr = Graphics.FromImage(btmp)) {
        gr.DrawImage(bitmap, new Point(0, 0));
        gr.DrawImage(bitmaps, new Point(1200, 300));
      }
      bitmap.Dispose();
      if(File.Exists(fileNameWitPath)) {
        File.Delete(fileNameWitPath);
      }

      btmp.Save(fileNameWitPath, ImageFormat.Png);
      return "Saved";
    }

    [WebMethod]
    public string ApproveDocument(int id, string userId) {
      var sql = "update customerMaster set AuditDate = getDate(), AuditBy = '" + userId + "', isLocked = 'N'  where customerId = " + id;
      swift.ExecuteDataset(sql);
      return "success";
    }

    [WebMethod]
    public string MonpepDataSearch(string userName) {
      using(var client = RestApiClient.CallThirdParty()) {
        JsonResponse jsonResponse = new JsonResponse();
        var jbdContent = new StringContent("{\"q\": \"" + userName + "\"}", Encoding.UTF8, "application/json");
        try {
          var URL = "api/v1/TP/monPep";

          HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
          string resultData = resp.Content.ReadAsStringAsync().Result;
          if(resp.IsSuccessStatusCode) {
            jsonResponse = JsonConvert.DeserializeObject<JsonResponse>(resultData);
            SearchEntityResponse ser = JsonConvert.DeserializeObject<SearchEntityResponse>(jsonResponse.Data.ToString());
            if(ser.results.Count > 0) {
              var aa = ser.results[0].properties;
              return JsonConvert.SerializeObject(aa);
            }
          } else {
            jsonResponse.ResponseCode = "999";
            jsonResponse.Msg = "Алдаа! " + resultData;
          }
        } catch(Exception ex) {
          jsonResponse = new JsonResponse() {
            ResponseCode = "1",
            Msg = (ex.InnerException == null ? ex.Message : ex.InnerException.Message)
          };
        }
      }
      return "";
    }

    [WebMethod]
    public string keyGenerator(string name, string code) {
      string passPhrase = "Pas5pr@se";
      string saltValue = "s@1tValue";
      string hashAlgorithm = "MD5";
      string initVector = "@1B2c3D4e5F6g7H8";
      const int passwordIterations = 2;
      const int keySize = 256;
      string s = code + ":" + name;
      byte[] initVectorBytes = Encoding.ASCII.GetBytes(initVector);
      byte[] saltValueBytes = Encoding.ASCII.GetBytes(saltValue);
      byte[] plainTextBytes = Encoding.UTF8.GetBytes(s);
      PasswordDeriveBytes password = new PasswordDeriveBytes(passPhrase, saltValueBytes, hashAlgorithm, passwordIterations);
      byte[] keyBytes = password.GetBytes(keySize / 8);
      RijndaelManaged symmetricKey = new RijndaelManaged();
      symmetricKey.Mode = CipherMode.CBC;
      ICryptoTransform encryptor = symmetricKey.CreateEncryptor(keyBytes, initVectorBytes);
      MemoryStream memoryStream = new MemoryStream();
      CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write);
      cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length);
      cryptoStream.FlushFinalBlock();
      byte[] cipherTextBytes = memoryStream.ToArray();
      memoryStream.Close();
      cryptoStream.Close();
      string cipherText = Convert.ToBase64String(cipherTextBytes);
      return cipherText;
    }

    [WebMethod]
    public string GolomtWalletCharge(string id, int flg) {
      string sql = "update walletFromGolomt set isDone = " + 1 + " where id = " + id;
      if (flg.Equals("1"))
        sql = "update walletFromGolomt set isDeleted = " + 1 + " where id = " + id;
      swift.ExecuteDataset(sql);
      return "success";
    }
  }
}