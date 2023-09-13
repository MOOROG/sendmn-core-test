<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SwiftTextBoxCustom.ascx.cs" Inherits="Swift.web.Component.AutoCompleteCustom.SwiftTextBoxCustom" %>
<asp:HiddenField ID = "aValue" runat = "server" />
<asp:TextBox ID = "aText" placeholder="Type to Search.." runat = "server" CssClass="form-control" ></asp:TextBox>
<asp:TextBox ID = "aSearch" runat = "server" CssClass="form-control" style ="background-color:#fff;display:none;position:relative;z-index:999;" ></asp:TextBox>
  <div class="form-group row"><label class="col-lg-2 col-md-3 control-label" for="">Country: </label>
     </div>                               
<asp:DropDownList ID="aCustom" runat="server" CssClass="form-control"></asp:DropDownList>
<script language = "javascript" type ="text/javascript">
    <% =InitFunction() %>
</script>