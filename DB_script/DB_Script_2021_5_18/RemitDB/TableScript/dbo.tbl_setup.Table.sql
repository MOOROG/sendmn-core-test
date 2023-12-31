USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tbl_setup]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_setup](
	[baisakh] [int] NULL,
	[jestha] [int] NULL,
	[ashadh] [int] NULL,
	[shrawan] [int] NULL,
	[bhadra] [int] NULL,
	[ashwin] [int] NULL,
	[kartik] [int] NULL,
	[mangshir] [int] NULL,
	[paush] [int] NULL,
	[magh] [int] NULL,
	[falgun] [int] NULL,
	[chaitra] [int] NULL,
	[GMT_Value] [int] NULL,
	[smsMsgs] [varchar](500) NULL,
	[smsmsgr] [varchar](500) NULL,
	[signature] [varchar](500) NULL,
	[smsmsgO] [varchar](200) NULL,
	[fiscalYear] [varchar](20) NULL,
	[rowId] [int] NULL,
	[engFrom] [date] NULL,
	[engTo] [date] NULL
) ON [PRIMARY]
GO
