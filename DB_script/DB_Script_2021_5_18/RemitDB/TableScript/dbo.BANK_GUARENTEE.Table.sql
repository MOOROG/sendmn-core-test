USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BANK_GUARENTEE]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BANK_GUARENTEE](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[date] [datetime] NOT NULL,
	[depositAmount] [money] NOT NULL,
	[holdRate] [decimal](10, 2) NOT NULL,
	[pendingAmount] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
