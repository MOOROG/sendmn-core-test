using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using System.Text.RegularExpressions;
using Swift.API.ThirdPartyApiServices;
using System.Net.Http;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class APITokenGenerator : System.Web.UI.Page {
    private const string ViewFunctionId = "10121100";
    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly RemittanceDao obj = new RemittanceDao();
    XypGetDataService _tpApi = new XypGetDataService();

    private string passPhrase = GetStatic.ReadWebConfig("apiKeyPassPhrase", "");
    private string saltValue = GetStatic.ReadWebConfig("apiKeySaltValue", "");
    private string hashAlgorithm = GetStatic.ReadWebConfig("apiKeyHashAlgorithm", "");
    private string initVector = GetStatic.ReadWebConfig("apiKeyInitVector", "");
    private string fcmServerKey = GetStatic.ReadWebConfig("fcmServerKey", "");
    private const int passwordIterations = 2;
    private const int keySize = 256;

    public List<String[]> banners;

    private string ip_pattern = @"^(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))$";
    protected void Page_Load(object sender, EventArgs e) {
      string sql = "";
      DataSet ds = null;
      if (!IsPostBack) {
        Authenticate();

        sql = "SELECT agentName, agentCode FROM agentMaster WHERE agentCountry != 'Mongolia'";
        ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach (DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["agentCode"].ToString();
            listItem.Text = row["agentName"].ToString();
            agentName.Items.Add(listItem);
            agentNameIP.Items.Add(listItem);
          }
        }
        this.getAnnouncement();

        if (Request["deleteBannerId"] != null && Request["deleteBannerId"] != "") {
          this.removeBanner(Request["deleteBannerId"]);
        }
        countryDdl.Items.Clear();
        sql = "select countryId as code, concat(countryName,':',countryCode) name from countryMaster where isOperativeCountry = 'Y'";
        ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach (DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["code"].ToString();
            listItem.Text = row["name"].ToString();
            countryDdl.Items.Add(listItem);
          }
        }
        sql = "SELECT id, code, message as khaan, type as golomt FROM commonCode where code = 'BANK'";
        ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          DataRow row = ds.Tables[0].Rows[0];
          khanBankChkbx.Checked = row["khaan"].ToString().Equals("ON") ? true : false;
          glmtBankChkbx.Checked = row["golomt"].ToString().Equals("ON") ? true : false;
        }
      }
      this.getBanners();
      this.ResetAllControls();
    }

    private void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId);
    }

    protected void onAgentSelect(object sender, EventArgs e) {
      if (agentName.SelectedValue != "-1") {
        agentCode.Text = agentName.SelectedValue;
        apiKey.Text = keyGenerator(agentName.SelectedItem.Text, agentCode.Text);
      } else {
        agentCode.Text = "";
        apiKey.Text = "";
      }
    }

    protected void onAgentSelectIP(object sender, EventArgs e) {
      whitelistedIPs.Text = "";
      if (agentNameIP.SelectedValue != "-1") {
        populateIPs(agentNameIP.SelectedValue);
      }
    }

    protected void btnSaveWhitelistedIPs_Click(object sender, EventArgs e) {
      // Get current whitelisted IPs in DB
      List<string> ips = getIPs(agentNameIP.SelectedValue);

      // Process modified IP list
      string[] raw_ips = whitelistedIPs.Text.Split(new Char[] { ',', '\n', ';' });
      List<string> err_ips = new List<string>();
      HashSet<string> new_ips = new HashSet<string>();
      foreach (var r_ip in raw_ips) {
        string ip = r_ip.Trim();
        if (ip != "") {
          if (Regex.Match(ip, ip_pattern).Success) {
            new_ips.Add(ip);
          } else {
            err_ips.Add(ip);
          }
        }
      }

      List<string> ips_to_rm = ips.FindAll(ip => !new_ips.Contains(ip));
      List<string> ips_to_add = new_ips.ToList().FindAll(ip => !ips.Contains(ip));

      // Combine all delete operations to 1 sql query;
      if (ips_to_rm.Count > 0) {
        string sql = "DELETE FROM apiWhiteList WHERE ";
        foreach (var ip in ips_to_rm) {
          sql += $"(ip={obj.FilterString(ip)} AND agentCode={obj.FilterString(agentNameIP.SelectedItem.Value)}) OR ";
        }
        sql = sql.Substring(0, sql.Length - 4) + ";";
        DataSet ds = obj.ExecuteDataset(sql);
      }

      // Combine all insert operations to 1 sql query;
      if (ips_to_add.Count > 0) {
        string sql = "INSERT INTO apiWhiteList (ip, agentCode) VALUES ";
        foreach (var ip in ips_to_add) {
          sql += $"({obj.FilterString(ip)}, {obj.FilterString(agentNameIP.SelectedItem.Value)}),";
        }
        sql = sql.Substring(0, sql.Length - 1) + ";";
        DataSet ds = obj.ExecuteDataset(sql);
      }

      populateIPs(agentNameIP.SelectedItem.Value);

      // Inform that invalid IPs are removed from the list
      if (err_ips.Count > 0) {
        string err_ips_txt = "";
        err_ips.ForEach(ip => err_ips_txt += ip + "; ");
        GetStatic.AlertMessage(this, "Saved! Removed Invalid IP(s): " + err_ips_txt);
      } else {
        GetStatic.AlertMessage(this, "Saved!");
      }
    }

    protected List<string> getIPs(string agentCode) {
      List<string> ips = new List<string>();
      string sql = "SELECT ip FROM apiWhiteList WHERE agentCode = " + obj.FilterString(agentCode);
      DataSet ds = obj.ExecuteDataset(sql);
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        foreach (DataRow row in ds.Tables[0].Rows) {
          ips.Add(row["ip"].ToString().Trim());
        }
      }
      return ips;
    }

    protected void populateIPs(string agentCode) {
      whitelistedIPs.Text = "";
      string ips_text = "";
      foreach (var ip in getIPs(agentCode)) {
        ips_text += ip + "\n";
      }
      whitelistedIPs.Text = ips_text.Length > 0 ? ips_text.Substring(0, ips_text.Length - 1) : "";
    }

    protected string keyGenerator(string name, string code) {
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

    protected void btnSignature_Click(object sender, EventArgs e) {
      MD5 md5Hasher = MD5.Create();
      string s = requestValues.Text.Replace("\n", "");
      byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(s));
      StringBuilder sBuilder = new StringBuilder();
      for (int i = 0; i < data.Length; i++) {
        sBuilder.Append(data[i].ToString("x2"));
      }
      signature.Text = sBuilder.ToString();
    }

    protected void btnAnnouncement_Click(object sender, EventArgs e) {
      string sql = "DELETE FROM announcement WHERE type='NOTIFICATION'";
      obj.ExecuteDataset(sql);
      sql = "INSERT INTO announcement (title, content, date_from, date_to, type) VALUES (N" + obj.FilterString(announcementTitle.Text)
          + ",N" + obj.FilterString(announcementContent.Text)
          + "," + obj.FilterString(announcementDateFrom.Text.Replace("T", " "))
          + "," + obj.FilterString(announcementDateTo.Text.Replace("T", " "))
          + ",'NOTIFICATION')";
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, "Announcement: Saved!");
      this.getAnnouncement();
    }

    protected void btnBanner_Click(object sender, EventArgs e) {
      string custPhoto1 = "";
      if (adsPhoto.FileName != "")
        custPhoto1 = UploadImage(adsPhoto);
      string datetime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
      string sql = "INSERT INTO announcement (title, content, date_from, date_to, link,type) VALUES ("
        + (obj.FilterString(bannerLabel.Text) == "null" ? "null" : "N" + obj.FilterString(bannerLabel.Text))
        + "," + obj.FilterString(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + ResolveUrl("~/") + "customerIds/" + custPhoto1)
        + "," + obj.FilterString(datetime)
        + "," + obj.FilterString(datetime)
        + "," + (obj.FilterString(bannerLink.Text) == "null" ? "null" : "N" + obj.FilterString(bannerLink.Text))
        + ",'BANNER')";
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, "Banner: Saved!");
      this.getBanners();
    }

    protected void removeBanner(string id) {
      string sql = "DELETE FROM announcement WHERE id=" + obj.FilterString(id) + " AND type='BANNER'";
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, "Banner: Deleted!");
    }

    protected void getAnnouncement() {
      string sql = "SELECT TOP 1 id, title, content, FORMAT(date_from, 'yyyy-MM-ddTHH:mm:ss') AS date_from, FORMAT(date_to, 'yyyy-MM-ddTHH:mm:ss') AS date_to FROM announcement WHERE type='NOTIFICATION'";
      DataSet ds = obj.ExecuteDataset(sql);
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        DataRow dr = ds.Tables[0].Rows[0];
        announcementId.Text = dr["id"].ToString();
        announcementTitle.Text = dr["title"].ToString();
        announcementContent.Text = dr["content"].ToString();
        announcementDateFrom.Text = dr["date_from"].ToString();
        announcementDateTo.Text = dr["date_to"].ToString();
      }
    }

    protected void getBanners() {
      string sql = "SELECT id, title, content, link FROM announcement WHERE type='BANNER'";
      DataSet ds = obj.ExecuteDataset(sql);
      this.banners = new List<string[]>();
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        foreach (DataRow row in ds.Tables[0].Rows) {
          this.banners.Add(new string[] { row["id"].ToString(), row["title"].ToString(), row["link"].ToString(), row["content"].ToString() });
        }
      }
    }

    protected void btnSaveNotice_Click(object sender, EventArgs e) {
      string sql = "";
      if (string.IsNullOrEmpty(noticeArea.Text)) {
        sql = "update countryMaster set noticeTxt = null where countryId = " + countryDdl.SelectedItem.Value;
      } else {
        sql = "update countryMaster set noticeTxt = N" + obj.FilterString(noticeArea.Text) + " where countryId = " + countryDdl.SelectedItem.Value;
      }
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, "Saved!");
    }

    protected void bankSwitchBtn_Click(object sender, EventArgs e) {
      string sql = "";
      string khanBnk = khanBankChkbx.Checked ? "ON" : "OFF";
      string glmtBnk = glmtBankChkbx.Checked ? "ON" : "OFF";
      if (khanBnk.Equals("OFF") && glmtBnk.Equals("OFF"))
        khanBnk = "ON";
      sql = "update commonCode set message = '" + khanBnk + "', type = '" + glmtBnk + "' where code ='BANK'";
      obj.ExecuteDataset(sql);
      GetStatic.AlertMessage(this, "Saved!");
    }

    public string UploadImage(FileUpload doc) {
      try {
        string imgid = Guid.NewGuid().ToString();
        string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
        string folderPath = GetStatic.ReadWebConfig("customerIdsDocPath", "D:\\allIDS");
        if (!Directory.Exists(folderPath))
          Directory.CreateDirectory(folderPath);
        string fileName = imgid + fileExtension;
        string filePath = Path.Combine(folderPath, fileName);
        doc.SaveAs(filePath);
        return fileName;
      } catch (Exception) {
        return "";
      }
    }

    private void ResetAllControls() {
      foreach (System.Web.UI.Control ctrl in this.Controls) {
        if (ctrl.GetType() == typeof(TextBox)) {
          ((TextBox)(ctrl)).Text = string.Empty;
        } else if (ctrl.GetType() == typeof(Label)) {
          ((Label)(ctrl)).Text = string.Empty;
        } else if (ctrl.GetType() == typeof(DropDownList)) {
          ((DropDownList)(ctrl)).SelectedIndex = 0;
        } else if (ctrl.GetType() == typeof(CheckBox)) {
          ((CheckBox)(ctrl)).Checked = false;
        } else if (ctrl.GetType() == typeof(CheckBoxList)) {
          ((CheckBoxList)(ctrl)).ClearSelection();
        } else if (ctrl.GetType() == typeof(RadioButton)) {
          ((RadioButton)(ctrl)).Checked = false;
        } else if (ctrl.GetType() == typeof(RadioButtonList)) {
          ((RadioButtonList)(ctrl)).ClearSelection();
        }
      }
    }

    protected void hurCheckBtn_Click(object sender, EventArgs e) {
      
      GetStatic.AlertMessage(this, "Done!");
    }

    protected void btnSendAppNotif_Click(object sender, EventArgs args) {

      string title = NotifTitle.Text;
      string body = NotifDesc.Text;

      var payload = new {
        to = "/topics/allDevices",
        notification = new {
          title,
          body
        }
      };

      string payloadJson = Newtonsoft.Json.JsonConvert.SerializeObject(payload);

      using (HttpClient client = new HttpClient()) {
        client.DefaultRequestHeaders.TryAddWithoutValidation("Authorization", fcmServerKey);
        client.DefaultRequestHeaders.TryAddWithoutValidation("Content-Type", "application/json");

        var content = new StringContent(payloadJson, Encoding.UTF8, "application/json");
        var response = client.PostAsync("https://fcm.googleapis.com/fcm/send", content).Result;

        if (response.IsSuccessStatusCode) {
          GetStatic.AlertMessage(this, "Notification Sent to all Users!");
        } else {
          // Failed to send notification
          // You can handle the error or show a message to the user
        }
      }
    }
  }
}