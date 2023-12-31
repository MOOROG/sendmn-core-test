USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[tran_masterDetail]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_masterDetail](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[ref_num] [varchar](50) NULL,
	[tran_particular] [nvarchar](500) NULL,
	[tran_rate] [money] NULL,
	[tran_rmks] [varchar](500) NULL,
	[billdate] [datetime] NULL,
	[party] [int] NULL,
	[otherinfo] [varchar](52) NULL,
	[tran_type] [varchar](20) NULL,
	[company_id] [int] NULL,
	[tranDate] [datetime] NULL,
	[voucher_image] [varchar](200) NULL
) ON [PRIMARY]
GO
