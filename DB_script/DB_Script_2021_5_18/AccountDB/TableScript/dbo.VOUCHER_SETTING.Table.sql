USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[VOUCHER_SETTING]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VOUCHER_SETTING](
	[V_TYPE] [varchar](100) NULL,
	[V_CODE] [varchar](5) NULL,
	[Approval_mode] [varchar](50) NULL,
	[created_by] [varchar](100) NULL,
	[created_date] [datetime] NULL,
	[modified_by] [varchar](100) NULL,
	[modified_date] [datetime] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
