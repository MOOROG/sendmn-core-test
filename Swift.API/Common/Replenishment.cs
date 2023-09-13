using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.API.Common {
  public class ReplenishmentModel {
    public string flag { get; set; }
    public string user { get; set; }
    public string receiverUser { get; set; }
    public string topUp { get; set; }
    public string remove { get; set; }
    public string closeBalance { get; set; }
    public string account { get; set; }
    public string currency { get; set; }
  }
}
