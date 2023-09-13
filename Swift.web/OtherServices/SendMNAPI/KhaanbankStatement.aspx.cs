using log4net.Util.TypeConverters;
using Newtonsoft.Json;
using Swift.API.Common;
using Swift.API.Common.SyncModel.Bank;
using Swift.API.Common.SyncModel.Polaris;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Linq;
using System.Security.Cryptography;
using System.Web.DynamicData;
using System.Web.UI.WebControls;
using static Swift.API.ThirdPartyApiServices.SyncBankAndBranchService;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class KhaanbankStatement : System.Web.UI.Page {
    private readonly RemittanceLibrary sl = new RemittanceLibrary();
    private readonly RemittanceDao rDao = new RemittanceDao();
    PolarisDictionary pdict = new PolarisDictionary();
    Dictionary<string, Dictionary<string, string>> pd = new Dictionary<string, Dictionary<string, string>>();
    Dictionary<string, string> pd8601 = new Dictionary<string, string>();
    Dictionary<string, string> pd9572 = new Dictionary<string, string>();
    List<string> sendmnAccounts = new List<string>();
    static List<Statements> lstStat = new List<Statements>();
    static List<Ntry> lstGlmt = new List<Ntry>();
    static List<RemainingList> listRemain = new List<RemainingList>();
    private const string ViewFunctionId = "10112201";
    List<string> accRemains = new List<string>();
    static List<SbStatementsRes> stSt = new List<SbStatementsRes>();
    static List<XacStatementsResDtl> stXac = new List<XacStatementsResDtl>();
    static List<Ntry> stTDB = new List<Ntry>();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        //dtWhen.ReadOnly = true;
        //dtWhen.Text = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
        khaanStDateStart.Text = DateTime.Now.ToString("yyyy-MM-dd");
        khaanStDateEnd.Text = DateTime.Now.ToString("yyyy-MM-dd");
        TextBox2.Text = DateTime.Now.ToString("yyyy-MM-dd");
        glmtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        stateStDateStart.Text = DateTime.Now.ToString("yyyy-MM-dd");
        stateStDateEnd.Text = DateTime.Now.ToString("yyyy-MM-dd");
        xacDateFr.Text = DateTime.Now.ToString("yyyy-MM-dd");
        xacDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
        TDBDateFr.Text = DateTime.Now.ToString("yyyy-MM-dd");
        TDBDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
        Authenticate();
      }
      if (Request.Form[hdnCurrentTab.UniqueID] != null) {
        hdnCurrentTab.Value = Request.Form[hdnCurrentTab.UniqueID];
      } else {
        hdnCurrentTab.Value = "menu";
      }
      DataTable showheader = new DataTable();

      stateGrid.DataSource = showheader; //MB: ShowHeaderWhenEmpty need to have empty DB to appear
      stateGrid.DataBind();
      GlmtGrid.DataSource = showheader;
      GlmtGrid.DataBind();
      grdJSON2Grid.DataSource = showheader;
      grdJSON2Grid.DataBind();
      xacGrid.DataSource = showheader;
      xacGrid.DataBind();
      TDBGrid.DataSource = showheader;
      TDBGrid.DataBind();
      sendmnAccounts.Add("5163358601");
      sendmnAccounts.Add("5176019572");
      sendmnAccounts.Add("5163260456");
      sendmnAccounts.Add("5163322299");
      sendmnAccounts.Add("1605129074");
      sendmnAccounts.Add("5111730446");
    }
    protected void OnRowDataBound(object sender, GridViewRowEventArgs e) {
      if (e.Row.RowType == DataControlRowType.Header) {
        foreach (TableCell cell in e.Row.Cells) {
          ((DataControlFieldHeaderCell)cell).Scope = TableHeaderScope.NotSet;
        }
      }
    }
    private void Authenticate() {
      sl.CheckAuthentication(ViewFunctionId);
    }
    protected void getStatement_Click(object sender, EventArgs e) {
      if (!khanpass.Text.Equals("khanpassaaa")) {
        string script = "alert('wrong pass');";
        System.Web.UI.ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Test", script, true);
        return;
      }
      GetStatus gs = new GetStatus() {
        ControlNo = accounts.SelectedValue.Split(':')[0],
        fromDt = khaanStDateStart.Text.Replace("-", ""),
        toDt = khaanStDateEnd.Text.Replace("-", "")
      };
      if (khaanPageSize.SelectedItem.Text == "All") {
        stateGrid.AllowPaging = false;
      } else {
        stateGrid.AllowPaging = true;
        stateGrid.PageSize = Convert.ToInt32(khaanPageSize.SelectedItem.Text);
      }
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      var response = serviceObj.GetBankStatement(gs);
      if (response.ResponseCode.Equals("0") && response.Msg.Equals("Success!")) {
        var responseData = response.Data;
        lstStat = (List<Statements>)responseData;
        if (lstStat.Count > 0) {
          syncToPolaris.Visible = false; //MB: Was true
        } else {
          syncToPolaris.Visible = false;
        }
        var xml = ApiUtility.ObjectToXML(responseData);
        int cntGme = 0, cntContact = 0, cntHanpass = 0, cntGmoney = 0, cntWallet = 0, cntShimtgel = 0, cntOthers = 0;
        double monGme = 0, monContact = 0, monHanpass = 0, monGmoney = 0, monWallet = 0, monOthers = 0, monShimtgel = 0;
        double deb = 0, cred = 0;
        foreach (Statements stts in lstStat) {
          if (stts.description == null) {
            cntShimtgel += 1;
            monShimtgel += Convert.ToDouble(stts.amount);
          } else if (stts.description.StartsWith("1 ")) {
            cntGme += 1;
            monGme += Convert.ToDouble(stts.amount);
          } else if ((stts.description.StartsWith("3 ") && stts.description.Contains("(R) #101")) || stts.description.Contains("(R) #101") || stts.description.Contains("(R) #SMN")) {
            cntGmoney += 1;
            monGmoney += Convert.ToDouble(stts.amount);
          } else if (stts.description.StartsWith("4 ") || stts.description.Contains("#201") || (stts.description.StartsWith("3 ") && !stts.description.Contains("#101"))) {
            cntContact += 1;
            monContact += Convert.ToDouble(stts.amount);
          } else if (stts.description.StartsWith("5 ")) {
            cntHanpass += 1;
            monHanpass += Convert.ToDouble(stts.amount);
          } else if (stts.description.Contains("(W)")) {
            cntWallet += 1;
            monWallet += Convert.ToDouble(stts.amount);
          } else {
            cntOthers += 1;
            monOthers += Convert.ToDouble(stts.amount);
          }
          if (lstStat.First() != stts) {
            if (stts.dbOrCr == "zarlaga") {
              cred += Convert.ToDouble(stts.amount);
            } else if (stts.dbOrCr == "orlogo") {
              deb += Convert.ToDouble(stts.amount);
            }
          }
          stts.tranDate = stts.tranDate + " " + stts.time.Substring(0, 2) + ":" + stts.time.Substring(2, 2) + ":" + stts.time.Substring(4, 2);
        }
        balance.Text = string.Format("{0:n}", lstStat.Last().balanceMoneyFormat);
        debit.Text = string.Format("{0:n}", deb);
        credit.Text = string.Format("{0:n}", cred);


        gme.Text = "GME : " + cntGme + ": Amount : " + monGme;
        gmoney.Text = "GMon : " + cntGmoney + ": Amount : " + monGmoney;
        contact.Text = "Cont : " + cntContact + ": Amount : " + monContact;
        hanpass.Text = "Han : " + cntHanpass + ": Amount : " + monHanpass;
        wallet.Text = "Wallet : " + cntWallet + ": Amount : " + monWallet;
        others.Text = "Other : " + cntOthers + ": Amount : " + monOthers;
        shimtgel.Text = "Shitgel : " + cntShimtgel + ": Amount : " + monShimtgel;
        totalCnt.Text = "Total : " + lstStat.Count;
        stateGrid.DataSource = lstStat;
        stateGrid.DataBind();
      }
    }
    protected void stateGrid_PageIndexChanging(Object sender, GridViewPageEventArgs e) {
      DataView tableSortedView = (DataView)Session["khaanSortedView"];
      if (tableSortedView == null) {
        stateGrid.DataSource = lstStat;
      } else {
        stateGrid.DataSource = tableSortedView;
      }
      if (e.NewPageIndex == -1) {
        double pageCount = lstStat.Count / stateGrid.PageSize;
        stateGrid.PageIndex = (int)Math.Round(pageCount);
      } else {
        stateGrid.PageIndex = e.NewPageIndex;
      }
      stateGrid.DataBind();
    }
    protected void GlmtGrid_PageIndexChanging(Object sender, GridViewPageEventArgs e) {
      DataView tableSortedView = (DataView)Session["glmtSortedView"];
      if (tableSortedView == null) {
        GlmtGrid.DataSource = lstGlmt;
      } else {
        GlmtGrid.DataSource = tableSortedView;
      }
      if (e.NewPageIndex == -1) {
        double pageCount = lstGlmt.Count / GlmtGrid.PageSize;
        GlmtGrid.PageIndex = (int)Math.Round(pageCount);
      } else {
        GlmtGrid.PageIndex = e.NewPageIndex;
      }
      GlmtGrid.DataBind();
    }
    protected void TDBGrid_PageIndexChanging(Object sender, GridViewPageEventArgs e) {
      DataView tableSortedView = (DataView)Session["TDBSortedView"];
      if (tableSortedView == null) {
        TDBGrid.DataSource = stTDB;
      } else {
        TDBGrid.DataSource = tableSortedView;
      }
      if (e.NewPageIndex == -1) {
        double pageCount = stTDB.Count / TDBGrid.PageSize;
        TDBGrid.PageIndex = (int)Math.Round(pageCount);
      } else {
        TDBGrid.PageIndex = e.NewPageIndex;
      }
      TDBGrid.DataBind();
    }
    protected void xacGrid_PageIndexChanging(Object sender, GridViewPageEventArgs e) {
      DataView tableSortedView = (DataView)Session["xacSortedView"];
      if (tableSortedView == null) {
        xacGrid.DataSource = stXac;
      } else {
        xacGrid.DataSource = tableSortedView;
      }
      if (e.NewPageIndex == -1) {
        double pageCount = stXac.Count / xacGrid.PageSize;
        xacGrid.PageIndex = (int)Math.Round(pageCount);
      } else {
        xacGrid.PageIndex = e.NewPageIndex;
      }
      xacGrid.DataBind();
    }

    protected void syncToPolaris_Click(object sender, EventArgs e) {
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      string fromAccount = accounts.SelectedValue;
      List<PolarisModels> listPmdls = new List<PolarisModels>();
      pd = pdict.AcctDictionary();
      pd8601 = pdict.Acct8601();
      pd9572 = pdict.Acct5176019572();
      if (fromAccount.StartsWith("5163260456")) {
        listPmdls = Account5163260456();
      } else if (fromAccount.StartsWith("5163358601")) {
        listPmdls = Account5163358601();
      } else if (fromAccount.StartsWith("5176019572")) {
        listPmdls = Account5176019572();
      } else if (fromAccount.StartsWith("5163322299")) {
        listPmdls = Account5163322299();
      }
      var response = serviceObj.SyncWithPolaris(listPmdls);
      string sql = "";
      foreach (string ss in accRemains) {
        sql = "insert into remainingStatement (account, tranDate, description) values ('" + accounts.SelectedValue + "','" + khaanStDateEnd.Text + "',N'" + ss + "')";
        rDao.ExecuteDataset(sql);
      }
      accRemains.Clear();
      if (response.ResponseCode.Equals("0") && response.Msg.Equals("Success!")) {
        var responseData = response.Data;
        lstStat = (List<Statements>)responseData;
        if (lstStat.Count > 0) {
          syncToPolaris.Visible = true;
        } else {
          syncToPolaris.Visible = false;
        }
        var xml = ApiUtility.ObjectToXML(responseData);
      }
    }

    private List<PolarisModels> Account5163260456() {
      List<PolarisModels> retLst = new List<PolarisModels>();
      string debitAcc = "";
      string creditAcc = "";
      foreach (Statements stts in lstStat) {
        PolarisModels retSngl = new PolarisModels();
        string[] splitFrst = stts.description.Split('x');
        if (splitFrst.Count() == 1)
          splitFrst = stts.description.Split('X');

        if (splitFrst.Count() == 1) {
          accRemains.Add(stts.description + " :: " + stts.amount);
          continue;
        }
        List<string> currCurrAmount = splitFrst[0].Split(new char[] { ' ' }, 3).ToList();
        currCurrAmount.RemoveAt(currCurrAmount.Count - 1);
        string mergedStr = String.Join("", currCurrAmount); // agent+currency
        string rateFromSendmn = splitFrst[0].Split(' ')[2]; // rate
        string key = pd.Keys.FirstOrDefault(x => x.Contains(accounts.SelectedValue));
        mergedStr = mergedStr.Replace("EB-", "").ToUpper();
        Dictionary<string, string> dictFiltered = pd[key];

        if (!dictFiltered.ContainsKey(mergedStr)) {
          continue;
        }

        if (Convert.ToDouble(stts.amount) > 0) {
          debitAcc = accounts.SelectedValue.Split(':')[1];
          creditAcc = dictFiltered[mergedStr];
        } else {
          creditAcc = accounts.SelectedValue.Split(':')[1];
          debitAcc = dictFiltered[mergedStr];
        }
        double amountTrans = Convert.ToDouble(stts.amount) / Convert.ToDouble(rateFromSendmn);
        double positiveAmount = Convert.ToDouble(stts.amount) < 0 ? -1 * Convert.ToDouble(stts.amount) : Convert.ToDouble(stts.amount);
        amountTrans = amountTrans < 0 ? -1 * amountTrans : amountTrans;
        retSngl = new PolarisModels() {
          txnAcntCode = debitAcc,
          txnAmount = amountTrans.ToString(),
          rate = rateFromSendmn,
          contAcntCode = creditAcc,
          txnDesc = stts.description,
          contAmount = positiveAmount.ToString(),
          contRate = "1",
          isPreview = "0",
          isPreviewFee = "0",
          isTmw = "0",
          rateTypeId = "59",
          tCustType = "1",
          tcustRegister = "6052363",
          tcustRegisterMask = "3"
        };
        retLst.Add(retSngl);
      }
      return retLst;
    }
    private List<PolarisModels> Account5163322299() {
      List<PolarisModels> retLst = new List<PolarisModels>();
      string debitAcc = "";
      string creditAcc = "";
      foreach (Statements stts in lstStat) {
        PolarisModels retSngl = new PolarisModels();
        string[] splitFrst = stts.description.Split('x');
        if (splitFrst.Count() == 1)
          splitFrst = stts.description.Split('X');

        if (splitFrst.Count() == 1) {
          accRemains.Add(stts.description + " :: " + stts.amount);
          continue;
        }
        List<string> currCurrAmount = splitFrst[0].Split(new char[] { ' ' }, 3).ToList();
        currCurrAmount.RemoveAt(currCurrAmount.Count - 1);
        string mergedStr = String.Join("", currCurrAmount); // agent+currency
        string rateFromSendmn = splitFrst[0].Split(' ')[2]; // rate
        string key = pd.Keys.FirstOrDefault(x => x.Contains(accounts.SelectedValue));
        mergedStr = mergedStr.Replace("EB-", "").ToUpper();
        Dictionary<string, string> dictFiltered = pd[key];

        if (!dictFiltered.ContainsKey(mergedStr))
          continue;

        if (Convert.ToDouble(stts.amount) > 0) {
          debitAcc = accounts.SelectedValue.Split(':')[1];
          creditAcc = dictFiltered[mergedStr];
        } else {
          creditAcc = accounts.SelectedValue.Split(':')[1];
          debitAcc = dictFiltered[mergedStr];
        }
        double amountTrans = Convert.ToDouble(stts.amount) / Convert.ToDouble(rateFromSendmn);
        double positiveAmount = Convert.ToDouble(stts.amount) < 0 ? -1 * Convert.ToDouble(stts.amount) : Convert.ToDouble(stts.amount);
        amountTrans = amountTrans < 0 ? -1 * amountTrans : amountTrans;
        retSngl = new PolarisModels() {
          txnAcntCode = debitAcc,
          txnAmount = amountTrans.ToString(),
          rate = rateFromSendmn,
          contAcntCode = creditAcc,
          txnDesc = stts.description,
          contAmount = positiveAmount.ToString(),
          contRate = "1",
          isPreview = "0",
          isPreviewFee = "0",
          isTmw = "0",
          rateTypeId = "59",
          tCustType = "1",
          tcustRegister = "6052363",
          tcustRegisterMask = "3"
        };
        retLst.Add(retSngl);
      }
      return retLst;
    }
    private List<PolarisModels> Account5176019572() {
      List<PolarisModels> retLst = new List<PolarisModels>();
      PolarisModels retSnglQpay = null;
      retSnglQpay = new PolarisModels() {
        txnAcntCode = "17400001121002",
        txnAmount = "0",
        contAcntCode = "107427070100000001",//pd9572["qpay"],
        txnDesc = "QPAY",
        contAmount = "0",
        rate = "1",
        contRate = "1",
        isPreview = "0",
        isPreviewFee = "0",
        isTmw = "0",
        rateTypeId = "58",
        tCustType = "1",
        tcustRegister = "6052363",
        tcustRegisterMask = "3"
      };
      double qpayAmount = 0;
      int qpayCntr = 0;
      foreach (Statements stts in lstStat) {
        PolarisModels retSngl = new PolarisModels();
        if (stts.description.Contains("qpay")) {
          qpayAmount += Convert.ToDouble(stts.amount);
          qpayCntr++;
        } else {
          if (!stts.description.Contains("EB-E")) {
            accRemains.Add(stts.description + " :: " + stts.amount);
            continue;
          }

          string desc = stts.description.Replace("EB-", "").Substring(0, 2);
          string fromAcc, toAcc;
          double amt = Convert.ToDouble(stts.amount);
          if (amt > 0) {
            fromAcc = "17400001121002";
            toAcc = pd9572[desc];
          } else {
            fromAcc = pd9572[desc];
            toAcc = "17400001121002";
          }
          amt = amt < 0 ? -1 * amt : amt;
          retSngl = new PolarisModels() {
            txnAcntCode = fromAcc,
            txnAmount = amt.ToString(),
            contAcntCode = toAcc,
            txnDesc = stts.description,
            contAmount = amt.ToString(),
            rate = "1",
            contRate = "1",
            isPreview = "0",
            isPreviewFee = "0",
            isTmw = "0",
            rateTypeId = "58",
            tCustType = "1",
            tcustRegister = "6052363",
            tcustRegisterMask = "3"
          };
          retLst.Add(retSngl);
        }
      }
      if (retSnglQpay != null) {
        qpayAmount = qpayAmount + qpayCntr * 100;
        retSnglQpay.txnAmount = qpayAmount.ToString();
        retSnglQpay.contAmount = qpayAmount.ToString();
        retLst.Add(retSnglQpay);
      }
      return retLst;
    }
    private List<PolarisModels> Account5163358601() {
      Dictionary<string, Dictionary<string, string>> AllList = new Dictionary<string, Dictionary<string, string>>();
      Dictionary<string, string> GMEList = new Dictionary<string, string>();
      Dictionary<string, string> GMEListMinus = new Dictionary<string, string>();
      Dictionary<string, string> GMoneyList = new Dictionary<string, string>();
      Dictionary<string, string> GMoneyListMinus = new Dictionary<string, string>();
      Dictionary<string, string> FinHanTranList = new Dictionary<string, string>();
      Dictionary<string, string> WalletList = new Dictionary<string, string>();
      Dictionary<string, string> OthersList = new Dictionary<string, string>();
      Dictionary<string, string> RiaList = new Dictionary<string, string>();
      Dictionary<string, string> ShimtgelList = new Dictionary<string, string>();
      List<PolarisModels> listPmdls = new List<PolarisModels>();
      foreach (Statements stts in lstStat) {
        if (stts.description != null) {
          if (stts.description.StartsWith("1 ")) { // GME
            if (Convert.ToInt32(Convert.ToDouble(stts.amount)) > 0) {
              if (GMEList.Count == 0) {
                GMEList.Add("GME orlogo", stts.amount);
              } else {
                GMEList["GME orlogo"] = (Convert.ToDouble(GMEList["GME orlogo"]) + Convert.ToDouble(stts.amount)).ToString();
              }
            } else {
              if (GMEListMinus.Count == 0) {
                GMEListMinus.Add("GME zarlaga", stts.amount);
              } else {
                GMEListMinus["GME zarlaga"] = (Convert.ToDouble(GMEListMinus["GME zarlaga"]) + Convert.ToDouble(stts.amount)).ToString();
              }
            }
          } else if (stts.description.StartsWith("4 ") || stts.description.Contains("#201") || (stts.description.StartsWith("3 ") && !stts.description.Contains("#101"))) { //Finshot, Tranglo
            double amountFin = Math.Round(Convert.ToDouble(stts.amount) / 2840, 2);
            if (FinHanTranList.Count == 0) {
              FinHanTranList.Add("Finshot", amountFin.ToString());
            } else {
              if (FinHanTranList.ContainsKey("Finshot")) {
                FinHanTranList["Finshot"] = (Convert.ToDouble(FinHanTranList["Finshot"]) + amountFin).ToString();
              } else {
                FinHanTranList.Add("Finshot", amountFin.ToString());
              }
            }
          } else if (stts.description.StartsWith("5 ")) { // Hanpass
            double amountHan = Math.Round(Convert.ToDouble(stts.amount) / 2840, 4);
            if (FinHanTranList.Count == 0) {
              FinHanTranList.Add("Hanpass", amountHan.ToString());
            } else {
              if (FinHanTranList.ContainsKey("Hanpass")) {
                FinHanTranList["Hanpass"] = (Convert.ToDouble(FinHanTranList["Hanpass"]) + amountHan).ToString();
              } else {
                FinHanTranList.Add("Hanpass", amountHan.ToString());
              }
            }
          } else if ((stts.description.StartsWith("3 ") && stts.description.Contains("(R) #101")) || stts.description.Contains("(R) #101") || stts.description.Contains("(R) #SMN")) { //GMoney
            if (Convert.ToInt32(Convert.ToDouble(stts.amount)) > 0) {
              if (GMoneyList.ContainsKey("GMoney orlogo")) {
                GMoneyList["GMoney orlogo"] = (Convert.ToDouble(GMoneyList["GMoney orlogo"]) + Convert.ToDouble(stts.amount)).ToString();
              } else {
                GMoneyList.Add("GMoney orlogo", stts.amount);
              }
            } else {
              if (GMoneyListMinus.ContainsKey("GMoney zarlaga")) {
                GMoneyListMinus["GMoney zarlaga"] = (Convert.ToDouble(GMoneyListMinus["GMoney zarlaga"]) + Convert.ToDouble(stts.amount)).ToString();
              } else {
                GMoneyListMinus.Add("GMoney zarlaga", stts.amount);
              }
            }

          } else if (stts.description.Contains("#12")) { //Ria
            if (RiaList.Count == 0) {
              RiaList.Add("RiaCollection", stts.amount);
            } else {
              RiaList["RiaCollection"] = (Convert.ToDouble(RiaList["RiaCollection"]) + Convert.ToDouble(stts.amount)).ToString();
            }
          } else if (stts.description.Contains("(W)")) { //Wallet uglug
            if (WalletList.Count == 0) {
              WalletList.Add("Wallet", stts.amount);
            } else {
              WalletList["Wallet"] = (Convert.ToDouble(WalletList["Wallet"]) + Convert.ToDouble(stts.amount)).ToString();
            }
          } else {
            if (OthersList.ContainsKey(stts.description)) {
              OthersList[stts.description] = (Convert.ToDouble(OthersList[stts.description]) + Convert.ToDouble(stts.amount)).ToString();
            } else {
              OthersList.Add(stts.description, stts.amount);
            }
            accRemains.Add(stts.description + " :: " + stts.amount);
          }
        } else {
          if (ShimtgelList.Count == 0) {
            ShimtgelList.Add("Shimtgel", stts.amount);
          } else {
            ShimtgelList["Shimtgel"] = (Convert.ToDouble(ShimtgelList["Shimtgel"]) + Convert.ToDouble(stts.amount)).ToString();
          }
        }
      }

      AllList.Add("107423110900000001", GMEListMinus);
      AllList.Add("107423111610000001", GMoneyListMinus);
      AllList.Add("107427070100000001", WalletList);
      AllList.Add("17400111142001", FinHanTranList);
      AllList.Add("17400005230001", ShimtgelList);

      foreach (var s in AllList.Keys) {
        PolarisModels retSngl = new PolarisModels();
        if (AllList[s].Count > 0) {
          if (AllList[s].Count == 1) {
            double amountD = Convert.ToDouble(AllList[s].ElementAt(0).Value);
            amountD = amountD < 0 ? -1 * amountD : amountD;
            if (amountD < 0)
              amountD = amountD * -1;
            retSngl = new PolarisModels() {
              txnAcntCode = s,
              txnAmount = amountD.ToString(),
              rate = "1",
              contAcntCode = "107411210230000001",
              txnDesc = AllList[s].ElementAt(0).Key,
              contAmount = amountD.ToString(),
              contRate = "1",
              isPreview = "0",
              isPreviewFee = "0",
              isTmw = "0",
              rateTypeId = "1",
              tCustType = "1",
              tcustRegister = "6052363",
              tcustRegisterMask = "3"
            };
            listPmdls.Add(retSngl);
          } else {
            foreach (var ss in AllList[s].Keys) {
              double amountF = Convert.ToDouble(AllList[s][ss]);
              amountF = amountF < 0 ? -1 * amountF : amountF;
              retSngl = new PolarisModels() {
                txnAcntCode = s,
                txnAmount = "" + amountF,
                rate = "2840",
                contAcntCode = "107411210230000001",
                txnDesc = ss,
                contAmount = "" + amountF * 2840,
                contRate = "1",
                isPreview = "0",
                isPreviewFee = "0",
                isTmw = "0",
                rateTypeId = "59",
                tCustType = "1",
                tcustRegister = "6052363",
                tcustRegisterMask = "3"
              };
              listPmdls.Add(retSngl);
            }
          }
        }
      }

      int contactCnt = Convert.ToInt32(contact.Text.Split(':')[1].Trim()) * 2 + Convert.ToInt32(hanpass.Text.Split(':')[1].Trim()) * 2;

      listPmdls.Add(new PolarisModels() {
        txnAcntCode = "17400114423001",
        txnAmount = "" + Convert.ToInt32(gmoney.Text.Split(':')[1].Trim()) * 2,
        rate = "1",
        contAcntCode = "107417111710170001",
        txnDesc = "Gmoney 2usd",
        contAmount = "" + Convert.ToInt32(gmoney.Text.Split(':')[1].Trim()) * 2,
        contRate = "1",
        isPreview = "0",
        isPreviewFee = "0",
        isTmw = "0",
        rateTypeId = "59",
        tCustType = "1",
        tcustRegister = "6052363",
        tcustRegisterMask = "3"
      });
      listPmdls.Add(new PolarisModels() {
        txnAcntCode = "17400114423001",
        txnAmount = "" + contactCnt,
        rate = "1",
        contAcntCode = "107417111710170001",
        txnDesc = "Contact 2usd",
        contAmount = "" + contactCnt,
        contRate = "1",
        isPreview = "0",
        isPreviewFee = "0",
        isTmw = "0",
        rateTypeId = "59",
        tCustType = "1",
        tcustRegister = "6052363",
        tcustRegisterMask = "3"
      });
      string lastone = "";
      return listPmdls;
    }

    protected void golomtStatement_Click(object sender, EventArgs e) {
      if (!glmtpass.Text.Equals("glmtpasscode")) {
        string script = "alert('wrong pass');";
        System.Web.UI.ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Test", script, true);
        return;
      }
      GetStatus gs = new GetStatus() {
        ControlNo = glmtAccount.SelectedValue.Split(':')[0],
        TranFlag = "golomtTranHistory",
        fromDt = TextBox2.Text,
        toDt = glmtDate.Text,

      };
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      var response = serviceObj.GetGlmtBankStatement(gs);
      if (response.ResponseCode.Equals("SUCCESS")) {
        var responseData = response.Data;
        lstGlmt = (List<Ntry>)responseData;
        GlmtGrid.DataSource = lstGlmt;
        GlmtGrid.DataBind();
      }
    }
    protected void TDBStatement_Click(object sender, EventArgs e) {
      if (!TDBPassword.Text.Equals("tdb")) {
        string script = "alert('wrong pass');";
        System.Web.UI.ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Test", script, true);
        return;
      }
      GetStatus gs = new GetStatus() {
        ControlNo = TDBAccountList.SelectedValue.Split(':')[0],
        TranFlag = "tdbTranHistory",
        //fromDt = glmtDate.Text,
        fromDt = TDBDateFr.Text,
        toDt = TDBDateTo.Text,
      };
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      var response = serviceObj.GetTDBStatement(gs);
      if (response.ResponseCode.Equals("SUCCESS")) {
        var responseData = response.Data;
        stTDB = (List<Ntry>)responseData;
        TDBGrid.DataSource = stTDB;
        TDBGrid.DataBind();
      }
    }

    protected void remainBtn_Click(object sender, EventArgs e) {
      string dt = khaanStDateEnd.Text.Replace("-", "");
      string accNumber = AccountList.SelectedValue;
      string sql = "select account, tranDate, description from remainingStatement where account = '" + accNumber + "' and tranDate = '" + dt + "'";
      DataTable dtt = rDao.ExecuteDataTable(sql);
      string serializeddt = JsonConvert.SerializeObject(dtt, Formatting.Indented);
      listRemain = JsonConvert.DeserializeObject<List<RemainingList>>(serializeddt, new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore });
      remainGrid.DataSource = listRemain;
      remainGrid.DataBind();
    }

    protected void srchValue_Click(object sender, EventArgs e) {
      string sval = "";
      //if (hdnCurrentTab.Value.Equals("menu"))
      //{
      //  if (!string.IsNullOrEmpty(sval))
      //  {
      //    List<Statements> lstStatNew = lstStat;
      //    sval = filterBx.Text.ToUpper();
      //    lstStatNew = lstStatNew.Where(x => (x.description != null && x.description.ToUpper().Contains(sval)) || x.amount.Contains(sval)).ToList();
      //    stateGrid.DataSource = lstStatNew;
      //    stateGrid.DataBind();
      //  }
      //}
      if (hdnCurrentTab.Value.Equals("menu2")) {
        if (!string.IsNullOrEmpty(remTextbx.Text)) {
          sval = remTextbx.Text.ToUpper();
          List<RemainingList> listRemainNew = listRemain;
          listRemainNew = listRemainNew.Where(x => x.account.Contains(sval) || x.description.ToUpper().ToString().Contains(sval)).ToList();
          remainGrid.DataSource = listRemainNew;
          remainGrid.DataBind();
        }
      }

      //if (hdnCurrentTab.Value.Equals("menu1"))
      //{
      //  if (!string.IsNullOrEmpty(glmtTxtbox.Text))
      //  {
      //    sval = glmtTxtbox.Text.ToUpper();
      //    List<Ntry> lstGlmtNew = lstGlmt;
      //    lstGlmtNew = lstGlmtNew.Where(x => x.TxAddInf.ToString().ToUpper().Contains(sval) || x.Amt.ToString().Contains(sval)).ToList();
      //    GlmtGrid.DataSource = lstGlmtNew;
      //    GlmtGrid.DataBind();
      //  }
      //}
      //if (hdnCurrentTab.Value.Equals("menu3"))
      //{
      //  if (!string.IsNullOrEmpty(stateSearchBox.Text))
      //  {
      //    sval = stateSearchBox.Text.ToUpper();
      //    List<SbStatementsRes> lstStateNew = stSt;
      //    lstStateNew = lstStateNew.Where(x => x.TxnDesc.ToString().ToUpper().Contains(sval) || x.Amount.ToString().Contains(sval)).ToList();
      //    grdJSON2Grid.DataSource = lstStateNew;
      //    grdJSON2Grid.DataBind();
      //  }
      //}
      //if (hdnCurrentTab.Value.Equals("menu4"))
      //{
      //  if (!string.IsNullOrEmpty(xacSearch.Text))
      //  {
      //    sval = xacSearch.Text.ToUpper();
      //    List<XacStatementsResDtl> lstStateNew = stXac;
      //    lstStateNew = lstStateNew.Where(x => x.DESCRIPTION.ToString().ToUpper().Contains(sval)).ToList();
      //    xacGrid.DataSource = lstStateNew;
      //    xacGrid.DataBind();
      //  }
      //}
    }

    private object StatebankStatement() {

      string startDate = Convert.ToDateTime(stateStDateStart.Text).ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'");
      startDate = "2023-02-01T07:07:21";
      //startDate = "2023-02-01T07:07:21.000Z";
      //string startDate = stateStDateEnd.Text.Replace("-", "/");
      System.Diagnostics.Debug.WriteLine(startDate);
      string endDate = stateStDateEnd.Text.Replace("-", "/");
      endDate = "2023-02-20T07:07:21";
      //endDate = "2023-02-20T07:07:21.000Z";
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      JsonResponse response = serviceObj.GetStateBankStatement(startDate, endDate);
      System.Diagnostics.Debug.WriteLine(response.Msg);
      return response.Data;
    }

    protected void stateStatement_Click(object sender, EventArgs e) {
      if (!statePwd.Text.Equals("statepasscode")) {
        string script = "alert('wrong pass');";
        System.Web.UI.ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Test", script, true);
        return;
      }
      if (statePageSize.SelectedItem.Text == "All") {
        grdJSON2Grid.AllowPaging = false;
      } else {
        grdJSON2Grid.AllowPaging = true;
        grdJSON2Grid.PageSize = Convert.ToInt32(statePageSize.SelectedItem.Text);
      }
      stSt = (List<SbStatementsRes>)StatebankStatement();
      int cntGme = 0, cntContact = 0, cntHanpass = 0, cntGmoney = 0, cntWallet = 0, cntShimtgel = 0, cntOthers = 0;
      double monGme = 0, monContact = 0, monHanpass = 0, monGmoney = 0, monWallet = 0, monOthers = 0, monShimtgel = 0;
      double deb = 0, cred = 0;
      foreach (SbStatementsRes stts in stSt) {
        if (stSt.First() != stts) {
          if (stts.TxnType == "1") {
            cred += stts.Amount;
          } else if (stts.TxnType == "0") {
            deb += stts.Amount;
          }
        }
      }
      stateBalance.Text = string.Format("{0:n}", stSt.Last().Balance);
      stateDebit.Text = string.Format("{0:n}", deb);
      stateCredit.Text = string.Format("-{0:n}", cred);
      grdJSON2Grid.DataSource = stSt;
      grdJSON2Grid.DataBind();
    }
    protected void stateStGrid_PageIndexChanging(Object sender, GridViewPageEventArgs e) {
      DataView tableSortedView = (DataView)Session["tableSortedView"];
      if (tableSortedView == null) {
        grdJSON2Grid.DataSource = stSt;
      } else {
        grdJSON2Grid.DataSource = tableSortedView;
      }
      if (e.NewPageIndex == -1) {
        double pageCount = stSt.Count / grdJSON2Grid.PageSize;
        grdJSON2Grid.PageIndex = (int)Math.Round(pageCount);
      } else {
        grdJSON2Grid.PageIndex = e.NewPageIndex;
      }
      grdJSON2Grid.DataBind();
    }
    public SortDirection direction {
      get {
        if (ViewState["directionState"] == null) {
          ViewState["directionState"] = SortDirection.Ascending;
        }
        return (SortDirection)ViewState["directionState"];
      }
      set {
        ViewState["directionState"] = value;
      }
    }
    protected string getSortDirectionString(SortDirection sortDirection) {
      string newSortDirection = String.Empty;
      if (direction == SortDirection.Ascending) {
        direction = SortDirection.Descending;
        newSortDirection = "DESC";
      } else {
        direction = SortDirection.Ascending;

        newSortDirection = "ASC";
      }

      return newSortDirection;
    }
    protected void khaanStGrid_Sorting(object sender, GridViewSortEventArgs e) {
      stateGrid.AllowPaging = false;
      stateGrid.DataSource = lstStat;
      stateGrid.DataBind();
      DataTable dt = new DataTable();
      dt.Columns.AddRange(new DataColumn[6] {new DataColumn("amountMoneyFormat",typeof(double)),
                        new DataColumn("balanceMoneyFormat",typeof(double)),
                        new DataColumn("description",typeof(string)),
                        new DataColumn("tranDate",typeof(string)),
                        new DataColumn("journal", typeof(int)),
                        new DataColumn("relatedAccount",typeof(long))});

      foreach (GridViewRow row in stateGrid.Rows) {
        DataRow dr = dt.NewRow();
        for (int j = 0; j < stateGrid.Columns.Count; j++) {
          String boundFields = String.Empty;
          DataControlField field = stateGrid.Columns[j];
          BoundField bfield = field as BoundField;
          boundFields = bfield.DataField;
          if (row.Cells[j].Text.Equals("&nbsp;")) {
            dr[bfield.DataField] = DBNull.Value;
          } else if (row.Cells[j].Text.Replace(",", "").Replace(".", "").All(char.IsDigit)) {
            if (bfield.HeaderText == "Journal" || bfield.HeaderText == "Related Account") {
              bfield.DataFormatString = "{0:D}";
            } else {
              bfield.DataFormatString = "{0:n}";
            }
            System.Diagnostics.Debug.WriteLine("help");

            System.Diagnostics.Debug.WriteLine(Convert.ToDouble(row.Cells[j].Text.Replace(",", "")));

            dr[bfield.DataField] = Convert.ToDouble(row.Cells[j].Text.Replace(",", ""));
          } else {
            dr[bfield.DataField] = row.Cells[j].Text;
          }
          //System.Diagnostics.Debug.WriteLine(row.Cells[j].Text);
        }

        dt.Rows.Add(dr);
      }
      DataSet ds = new DataSet();
      DataTable dtGridData = stateGrid.DataSource as DataTable;
      if (dt != null) {
        DataView dvSortedView = new DataView(dt);
        dvSortedView.Sort = e.SortExpression + " " + getSortDirectionString(e.SortDirection);

        stateGrid.AllowPaging = true;
        Session["khaanSortedView"] = dvSortedView;
        stateGrid.DataSource = dvSortedView;
        stateGrid.DataBind();
      }
    }
    protected void xacGrid_Sorting(object sender, GridViewSortEventArgs e) {
      xacGrid.AllowPaging = false;
      xacGrid.DataSource = stXac;
      xacGrid.DataBind();
      DataTable dt = new DataTable();
      dt.Columns.AddRange(new DataColumn[6] {new DataColumn("CREDITAMOUNT",typeof(double)),
                        new DataColumn("CLOSINGBALANCE",typeof(double)),
                        new DataColumn("DESCRIPTION",typeof(string)),
                        new DataColumn("OPENDATE",typeof(string)),
                        new DataColumn("CUSTOMERID", typeof(int)),
                        new DataColumn("ACCOUNTID",typeof(long))});

      foreach (GridViewRow row in xacGrid.Rows) {
        DataRow dr = dt.NewRow();
        for (int j = 0; j < xacGrid.Columns.Count; j++) {
          String boundFields = String.Empty;
          DataControlField field = xacGrid.Columns[j];
          BoundField bfield = field as BoundField;
          boundFields = bfield.DataField;
          if (row.Cells[j].Text.Equals("&nbsp;")) {
            dr[bfield.DataField] = DBNull.Value;
          } else if (row.Cells[j].Text.Replace(",", "").Replace(".", "").All(char.IsDigit)) {
            if (bfield.HeaderText == "Account ID" || bfield.HeaderText == "Customer ID") {
              bfield.DataFormatString = "{0:D}";
            } else {
              bfield.DataFormatString = "{0:n}";
            }
            System.Diagnostics.Debug.WriteLine("help");

            System.Diagnostics.Debug.WriteLine(Convert.ToDouble(row.Cells[j].Text.Replace(",", "")));

            dr[bfield.DataField] = Convert.ToDouble(row.Cells[j].Text.Replace(",", ""));
          } else {
            dr[bfield.DataField] = row.Cells[j].Text;
          }
          //System.Diagnostics.Debug.WriteLine(row.Cells[j].Text);
        }

        dt.Rows.Add(dr);
      }
      DataSet ds = new DataSet();
      DataTable dtGridData = xacGrid.DataSource as DataTable;
      if (dt != null) {
        DataView dvSortedView = new DataView(dt);
        dvSortedView.Sort = e.SortExpression + " " + getSortDirectionString(e.SortDirection);

        xacGrid.AllowPaging = true;
        Session["xacSortedView"] = dvSortedView;
        xacGrid.DataSource = dvSortedView;
        xacGrid.DataBind();
      }
    }
    protected void statePageSize_SelectedIndexChanged(object sender, EventArgs e) {
      if (statePageSize.SelectedItem.Text == "All") {
        grdJSON2Grid.AllowPaging = false;
      } else {
        grdJSON2Grid.AllowPaging = true;
        grdJSON2Grid.PageSize = Convert.ToInt32(statePageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("STATE PAGE SIZE CHANGED {0}", statePageSize.SelectedItem.Text);
    }
    protected void khaanPageSize_SelectedIndexChanged(object sender, EventArgs e) {
      if (khaanPageSize.SelectedItem.Text == "All") {

        stateGrid.AllowPaging = false;
      } else {
        stateGrid.AllowPaging = true;
        stateGrid.PageSize = Convert.ToInt32(khaanPageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("KHAAN PAGE SIZE CHANGED {0}", statePageSize.SelectedItem.Text);

    }
    protected void xacPageSize_SelectedIndexChanged(object sender, EventArgs e) {
      if (xacPageSize.SelectedItem.Text == "All") {

        xacGrid.AllowPaging = false;
      } else {
        xacGrid.AllowPaging = true;
        xacGrid.PageSize = Convert.ToInt32(xacPageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("KHAAN PAGE SIZE CHANGED {0}", xacPageSize.SelectedItem.Text);

    }
    protected void GlmtGrid_SelectedIndexChanged(object sender, EventArgs e) {
      if (golomtPageSize.SelectedItem.Text == "All") {

        GlmtGrid.AllowPaging = false;
      } else {
        GlmtGrid.AllowPaging = true;
        GlmtGrid.PageSize = Convert.ToInt32(golomtPageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("GOLOMT PAGE SIZE CHANGED {0}", golomtPageSize.SelectedItem.Text);

    }
    protected void TDBGrid_SelectedIndexChanged(object sender, EventArgs e) {
      if (TDBPageSize.SelectedItem.Text == "All") {

        TDBGrid.AllowPaging = false;
      } else {
        TDBGrid.AllowPaging = true;
        TDBGrid.PageSize = Convert.ToInt32(TDBPageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("TDB PAGE SIZE CHANGED {0}", TDBPageSize.SelectedItem.Text);

    }
    protected void stateStGrid_Sorting(object sender, GridViewSortEventArgs e) {
      grdJSON2Grid.AllowPaging = false;
      grdJSON2Grid.DataSource = stSt;
      grdJSON2Grid.DataBind();
      DataTable dt = new DataTable();
      dt.Columns.AddRange(new DataColumn[5] {new DataColumn("Amount",typeof(double)),
                        new DataColumn("Balance",typeof(double)),
                        new DataColumn("TxnDesc",typeof(string)),
                        new DataColumn("TxnDate",typeof(string)),
                        new DataColumn("JrNo", typeof(long))});

      foreach (GridViewRow row in grdJSON2Grid.Rows) {
        DataRow dr = dt.NewRow();
        for (int j = 0; j < grdJSON2Grid.Columns.Count; j++) {
          String boundFields = String.Empty;
          DataControlField field = grdJSON2Grid.Columns[j];
          BoundField bfield = field as BoundField;
          boundFields = bfield.DataField;
          if (row.Cells[j].Text.Equals("&nbsp;")) {
            dr[bfield.DataField] = DBNull.Value;
          } else if (row.Cells[j].Text.Replace(",", "").Replace(".", "").All(char.IsDigit)) {
            if (bfield.HeaderText == "Journal" || bfield.HeaderText == "Related Account") {
              bfield.DataFormatString = "{0:D}";
            } else {
              bfield.DataFormatString = "{0:n}";
            }
            System.Diagnostics.Debug.WriteLine("help");

            System.Diagnostics.Debug.WriteLine(Convert.ToDouble(row.Cells[j].Text.Replace(",", "")));
            dr[bfield.DataField] = Convert.ToDouble(row.Cells[j].Text.Replace(",", ""));
          } else {
            dr[bfield.DataField] = row.Cells[j].Text;
          }
          //System.Diagnostics.Debug.WriteLine(row.Cells[j].Text);
        }

        dt.Rows.Add(dr);
      }
      DataSet ds = new DataSet();
      DataTable dtGridData = grdJSON2Grid.DataSource as DataTable;
      if (dt != null) {
        DataView dvSortedView = new DataView(dt);
        dvSortedView.Sort = e.SortExpression + " " + getSortDirectionString(e.SortDirection);

        grdJSON2Grid.AllowPaging = true;
        Session["tableSortedView"] = dvSortedView;
        grdJSON2Grid.DataSource = dvSortedView;
        grdJSON2Grid.DataBind();
      }
    }
    protected void GlmtGrid_Sorting(object sender, GridViewSortEventArgs e) {
      GlmtGrid.AllowPaging = false;
      GlmtGrid.DataSource = lstGlmt;
      GlmtGrid.DataBind();
      DataTable dt = new DataTable();
      dt.Columns.AddRange(new DataColumn[5] {new DataColumn("amountMoneyFormat",typeof(double)),
                        new DataColumn("ntrybalance",typeof(double)),
                        new DataColumn("txAddInf",typeof(string)),
                        new DataColumn("txDt",typeof(string)),
                        new DataColumn("ntryRef", typeof(string))});

      foreach (GridViewRow row in GlmtGrid.Rows) {
        DataRow dr = dt.NewRow();
        for (int j = 0; j < GlmtGrid.Columns.Count; j++) {
          String boundFields = String.Empty;
          DataControlField field = GlmtGrid.Columns[j];
          BoundField bfield = field as BoundField;
          boundFields = bfield.DataField;
          if (row.Cells[j].Text.Equals("&nbsp;")) {
            dr[bfield.DataField] = DBNull.Value;
          } else if (row.Cells[j].Text.Replace(",", "").Replace(".", "").All(char.IsDigit)) {
            if (bfield.HeaderText == "Journal" || bfield.HeaderText == "Related Account") {
              bfield.DataFormatString = "{0:D}";
            } else {
              bfield.DataFormatString = "{0:n}";
            }
            System.Diagnostics.Debug.WriteLine("help");

            System.Diagnostics.Debug.WriteLine(Convert.ToDouble(row.Cells[j].Text.Replace(",", "")));

            dr[bfield.DataField] = Convert.ToDouble(row.Cells[j].Text.Replace(",", ""));
          } else {
            dr[bfield.DataField] = row.Cells[j].Text;
          }
          //System.Diagnostics.Debug.WriteLine(row.Cells[j].Text);
        }

        dt.Rows.Add(dr);
      }
      DataSet ds = new DataSet();
      DataTable dtGridData = GlmtGrid.DataSource as DataTable;
      if (dt != null) {
        DataView dvSortedView = new DataView(dt);
        dvSortedView.Sort = e.SortExpression + " " + getSortDirectionString(e.SortDirection);

        GlmtGrid.AllowPaging = true;
        Session["glmtSortedView"] = dvSortedView;
        GlmtGrid.DataSource = dvSortedView;
        GlmtGrid.DataBind();
      }
    }
    protected void TDBGrid_Sorting(object sender, GridViewSortEventArgs e) {
      TDBGrid.AllowPaging = false;
      TDBGrid.DataSource = stTDB;
      TDBGrid.DataBind();
      DataTable dt = new DataTable();
      dt.Columns.AddRange(new DataColumn[5] {new DataColumn("amountMoneyFormat",typeof(double)),
                        new DataColumn("ntrybalance",typeof(double)),
                        new DataColumn("txAddInf",typeof(string)),
                        new DataColumn("txDt",typeof(string)),
                        new DataColumn("ntryRef", typeof(string))});

      foreach (GridViewRow row in TDBGrid.Rows) {
        DataRow dr = dt.NewRow();
        for (int j = 0; j < TDBGrid.Columns.Count; j++) {
          String boundFields = String.Empty;
          DataControlField field = TDBGrid.Columns[j];
          BoundField bfield = field as BoundField;
          boundFields = bfield.DataField;
          if (row.Cells[j].Text.Equals("&nbsp;")) {
            dr[bfield.DataField] = DBNull.Value;
          } else if (row.Cells[j].Text.Replace(",", "").Replace(".", "").All(char.IsDigit)) {
            if (bfield.HeaderText == "Journal" || bfield.HeaderText == "Related Account") {
              bfield.DataFormatString = "{0:D}";
            } else {
              bfield.DataFormatString = "{0:n}";
            }
            System.Diagnostics.Debug.WriteLine("help");

            System.Diagnostics.Debug.WriteLine(Convert.ToDouble(row.Cells[j].Text.Replace(",", "")));

            dr[bfield.DataField] = Convert.ToDouble(row.Cells[j].Text.Replace(",", ""));
          } else {
            dr[bfield.DataField] = row.Cells[j].Text;
          }
          //System.Diagnostics.Debug.WriteLine(row.Cells[j].Text);
        }

        dt.Rows.Add(dr);
      }
      DataSet ds = new DataSet();
      DataTable dtGridData = TDBGrid.DataSource as DataTable;
      if (dt != null) {
        DataView dvSortedView = new DataView(dt);
        dvSortedView.Sort = e.SortExpression + " " + getSortDirectionString(e.SortDirection);

        TDBGrid.AllowPaging = true;
        Session["TDBSortedView"] = dvSortedView;
        TDBGrid.DataSource = dvSortedView;
        TDBGrid.DataBind();
      }
    }
    protected void xacStatement_Click(object sender, EventArgs e) {
      if (!xacPassword.Text.Equals("xacpasscode")) {
        string script = "alert('wrong pass');";
        System.Web.UI.ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Test", script, true);
        return;
      }
      stXac = (List<XacStatementsResDtl>)XacbankStatement();
      xacGrid.DataSource = stXac;
      xacGrid.DataBind();
    }
    private object XacbankStatement() {

      string startDate = xacDateFr.Text;
      string endDate = xacDateTo.Text;
      SyncBankAndBranchService serviceObj = new SyncBankAndBranchService();
      JsonResponse response = serviceObj.GetXacBankStatement(startDate, endDate);
      return response.Data;
    }
    protected void makeTran_Click(object sender, EventArgs e) {
      SendTransactionServices _tpSend = new SendTransactionServices();
      SendmnTranMdl sndMdl = new SendmnTranMdl();
      sndMdl.amount = Convert.ToInt32(tranAmt.Text);
      sndMdl.fromAccount = fromToFrst.SelectedValue.Split(':')[0];
      sndMdl.toAccount = fromToScnd.SelectedValue.Split(':')[0];
      if (!sendmnAccounts.Contains(sndMdl.toAccount))
        return;
      sndMdl.bankFlag = fromToFrst.SelectedValue.Split(':')[1];
      string frstFlag = fromToFrst.SelectedValue.Split(':')[1];
      string scndFlag = fromToScnd.SelectedValue.Split(':')[1];
      sndMdl.betweenKhan = (frstFlag.Equals("KHN") && scndFlag.Equals("KHN")) ? "DOM" : "INT";
      JsonResponse jsresp = _tpSend.InterbankTransfer(sndMdl);
      GetStatic.AlertMessage(this, jsresp.ResponseCode);
      Response.Redirect("KhaanbankStatement.aspx");
    }

    protected void golomtPageSize_SelectedIndexChanged(object sender, EventArgs e) {
      if (golomtPageSize.SelectedItem.Text == "All") {

        GlmtGrid.AllowPaging = false;
      } else {
        GlmtGrid.AllowPaging = true;
        GlmtGrid.PageSize = Convert.ToInt32(golomtPageSize.SelectedItem.Text);
      }
      System.Diagnostics.Debug.WriteLine("GOLOMT PAGE SIZE CHANGED {0}", golomtPageSize.SelectedItem.Text);
    }
  }
}