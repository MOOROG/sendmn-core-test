using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.KFTC
{
    public interface IKFTCAccountCancel
    {
        DbResult CancelAccount(DataTable dt);
    }
}
