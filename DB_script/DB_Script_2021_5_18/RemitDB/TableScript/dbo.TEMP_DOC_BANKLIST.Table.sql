USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_DOC_BANKLIST]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_DOC_BANKLIST](
	[bank_id] [int] IDENTITY(1,2) NOT NULL,
	[bank_name] [varchar](50) NULL,
	[isDisable] [char](1) NULL,
	[Ext_AgentCode] [varchar](50) NULL
) ON [PRIMARY]
GO
