using Newtonsoft.Json.Linq;
using Swift.API.Common.SyncModel.Bank;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel.Polaris {
  public class PolarisDictionary {
    Dictionary<string, Dictionary<string, string>> dictMain = new Dictionary<string, Dictionary<string, string>>();
    public Dictionary<string, Dictionary<string, string>> AcctDictionary() {
      Dictionary<string, string> dict = new Dictionary<string, string>();

      dict.Add("S1"+ Utility.ReadWebConfig("currencyUSA", ""), "107417111100200001");
      dict.Add("S1RUB", "107417111300160001");
      dict.Add("S1EURO", "107417111200120001");
      dict.Add("S1EUR", "107417111200120001");
      dict.Add("S2"+ Utility.ReadWebConfig("currencyUSA", ""), "17400111142001");
      dict.Add("S2RUB", "107411420300160001");
      dict.Add("S5"+ Utility.ReadWebConfig("currencyUSA", ""), "107417110600100001");
      dict.Add("S5EURO", "107417110700120001");
      dict.Add("S5EUR", "107417110700120001");
      dict.Add("BD2"+ Utility.ReadWebConfig("currencyUSA", ""), "107411420400170001");
      dict.Add("BD2EURO", "107411420500120001");
      dict.Add("BD2EUR", "107411420500120001");
      dict.Add("BD2RUB", "107411420600140001");
      dict.Add("BD5EURO", "107417111500120001");
      dict.Add("BD5EUR", "107417111500120001");
      dict.Add("BD5"+ Utility.ReadWebConfig("currencyUSA", ""), "107417111400170001");
      dict.Add("CP"+ Utility.ReadWebConfig("currencyUSA", ""), "107417111910170001");
      dict.Add("CPEUR", "107417112010120001");
      dict.Add("CPEURO", "107417112010120001");
      dict.Add("CPRUB", "107417112110140001");
      dict.Add("BPUSD", "17400111711003");
      dict.Add("BPEURO", "17400121711002");
      dict.Add("BPEUR", "17400121711002");
      dictMain.Add("5176019572:17400001121002", dict); //5176019572-ЗАРДАЛ
      dictMain.Add("5163322299:17400001121005", dict); //5163322299
      dictMain.Add("5163260456:17400001121004", dict); //5163260456
      return dictMain;
    }
    public Dictionary<string, string> Acct5176019572() {
      Dictionary<string, string> dict = new Dictionary<string, string>();
      dict.Add("E1", "107452490200000001");
      dict.Add("E2", "17400005251001");
      dict.Add("E3", "17400005239001");
      dict.Add("E4", "17400005245001");
      dict.Add("E5", "17400005259001");
      dict.Add("E6", "17400005254001");
      dict.Add("E7", "17400005252001");
      dict.Add("E8", "107453060000000001");
      dict.Add("E9", "107451040000000001");
      dict.Add("E10", "17400005244001");
      dict.Add("E11", "107452500000000001");
      dict.Add("E12", "107452470000000001");
      dict.Add("E13", "17400005221001");
      dict.Add("E14", "17400005101001");
      dict.Add("E15", "107452580100000001");
      dict.Add("E16", "17400005228001");
      dict.Add("E17", "107452130000000001");
      dict.Add("E18", "17400005302001");
      dict.Add("E19", "17400005303001");
      dict.Add("E20", "17400005258001");
      dict.Add("E21", "17400005258002");
      dict.Add("E22", "17400005253001");
      dict.Add("E23", "17400005241001");
      dict.Add("qpay", "17400001121002"); //collect
      dict.Add("shim", "17400005230001"); //collect

      //dictMain.Add("5176019572:17400001121002", dict);
      //dictMain.Add("", dict);

      return dict;
    }
    public Dictionary<string, string> Acct8601() {
      Dictionary<string, string> dict = new Dictionary<string, string>();
      dict.Add("5163358601", "107411210230000001");
      return dict;
    }
  }
}
