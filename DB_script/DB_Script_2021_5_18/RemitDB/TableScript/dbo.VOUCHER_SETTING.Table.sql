USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[VOUCHER_SETTING]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VOUCHER_SETTING](
	[id] [int] NULL,
	[V_TYPE] [varchar](100) NULL,
	[V_CODE] [varchar](5) NULL,
	[Approval_mode] [varchar](50) NULL,
	[created_by] [varchar](100) NULL,
	[created_date] [datetime] NULL,
	[modified_by] [varchar](100) NULL,
	[modified_date] [datetime] NULL
) ON [PRIMARY]
GO
