USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ALL_COMMISSION_FROM_AGENT_SYSTEM]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALL_COMMISSION_FROM_AGENT_SYSTEM](
	[UPLOADLOGID] [varchar](6) NOT NULL,
	[SC] [varchar](7) NOT NULL,
	[FX] [varchar](21) NOT NULL,
	[NEW_CUST] [varchar](4) NOT NULL,
	[IS_CANCEL] [varchar](1) NOT NULL
) ON [PRIMARY]
GO
