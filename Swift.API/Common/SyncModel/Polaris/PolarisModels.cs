using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SyncModel.Polaris {
  public class PolarisModels {
    public string txnAcntCode { get; set; } //Дебет дотоодын дансны дугаар
    public string txnAmount { get; set; } //Дебет дотоодын данснаас зарлагадах дүн
    public string rate { get; set; } //Зарлага гаргах ханш
    public string contAcntCode { get; set; } //Дотоодын дансны дугаар
    public string contAmount { get; set; } //Орлого хийж байгаа дүн
    public string contRate { get; set; } //Орлого хийсэн ханш
    public string rateTypeId { get; set; } //Ханшийн төрлийн код
    public string tCustType { get; set; } //Гүйлгээ хийлгэж байгаа харилцагчийн төрөл 0 – Хувь хүн 1 – Байгууллага
    public string txnDesc { get; set; } // Гүйлгээний утга
    public string tcustRegister { get; set; } //Гүйлгээ хийлгэж байгаа харилцагчийн регистр
    public string tcustRegisterMask { get; set; } //Регистрийн маск
    public string isPreview { get; set; } //Гүйлгээний бичилт харах /1-харах, 0-гүйлгээ/
    public string isPreviewFee { get; set; } //Шимтгэлийн бичилт харах /1-харах, 0-гүйлгээ /
    public string isTmw { get; set; }
  }

  public class RemainingList {
    public string account { get; set; }
    public string description { get; set; }
    public string tranDate { get; set; }
  }
}
