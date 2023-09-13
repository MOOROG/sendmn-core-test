using System.Web.UI.WebControls;

namespace Swift.web.Library
{
    public class StaticDataDdl : RemittanceLibrary
    {
        public void SetStaticDdl(ref DropDownList ddl, string typeId, string valueToBeSelected, string label)
        {
            SetStaticDdl(ref ddl, typeId, valueToBeSelected, label, "");
        }

        public void SetStaticDdl(ref DropDownList ddl, string typeId, string valueToBeSelected, string label, string valueId)
        {
            SetDDL(ref ddl, "EXEC proc_staticDataValue 'c'," + FilterString(typeId) + ",@valueId = " + FilterString(valueId), "valueId", "detailTitle", valueToBeSelected, label);
        }

        public void SetStaticDdl(ref DropDownList ddl, string typeId)
        {
            SetStaticDdl(ref ddl, typeId, "", "");
        }

        public void SetStaticDdl2(ref DropDownList ddl, string typeId, string valueToBeSelected, string label)
        {
            SetStaticDdl2(ref ddl, typeId, valueToBeSelected, label, "");
        }

        public void SetStaticDdl2(ref DropDownList ddl, string typeId, string valueToBeSelected, string label, string valueId)
        {
            SetDDL2(ref ddl, "EXEC proc_staticDataValue 'c'," + FilterString(typeId) + ",@valueId = " + FilterString(valueId), "detailTitle", valueToBeSelected, label);
        }

        public void SetStaticDdl2(ref DropDownList ddl, string typeId)
        {
            SetStaticDdl2(ref ddl, typeId, "", "");
        }

        public void SetStaticDdl3(ref DropDownList ddl, string typeId, string valueToBeSelected, string label)
        {
            SetStaticDdl3(ref ddl, typeId, valueToBeSelected, label, "");
        }

        public void SetStaticDdl3(ref DropDownList ddl, string typeId, string valueToBeSelected, string label, string valueId)
        {
            SetDDL3(ref ddl, "EXEC proc_staticDataValue 'c'," + FilterString(typeId) + ",@valueId = " + FilterString(valueId), "valueId", "detailTitle", valueToBeSelected, label);
        }

        public void SetStaticDdl3(ref DropDownList ddl, string typeId)
        {
            SetStaticDdl3(ref ddl, typeId, "", "");
        }

        public void SelectByTextDdl(ref DropDownList ddl, string text)
        {
            ListItem li = ddl.Items.FindByText(text);
            if (li != null)
            {
                li.Selected = true;
            }
        }

        public void SetStaticDdlTitle(ref DropDownList ddl, string typeId, string valueToBeSelected, string label)
        {
            SetDDL(ref ddl, "EXEC proc_staticDataValue 'c1'," + FilterString(typeId), "detailTitle", "detailDesc", valueToBeSelected, label);
        }
    }
}