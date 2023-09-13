using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common {
  public class ErrorJosn {
    public string Message { get; set; }
  }

  public class Data {
    public string Name { get; set; }
    public string Message { get; set; }
  }

  public class JsonResponse {
    public string TokenNo { get; set; }
    public string ResponseCode { get; set; }
    public string Msg { get; set; }
    public string Id { get; set; }
    public string Extra { get; set; }
    public string Extra1 { get; set; }
    public object Data { get; set; }
    public string ErrorCode { get; set; }
    public string Extra2 { get; set; }
    public void SetResponse(string responseCode, string msg, string id = null, string extra = null, string extra1 = null) {
      ResponseCode = responseCode;
      Msg = msg;
      Id = id;
      Extra = extra;
      Extra1 = extra1;
    }
  }
}
