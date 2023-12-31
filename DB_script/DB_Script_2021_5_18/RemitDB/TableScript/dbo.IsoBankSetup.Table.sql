USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[IsoBankSetup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IsoBankSetup](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[bankId] [bigint] NULL,
	[bankName] [varchar](200) NULL,
	[branchName] [varchar](200) NULL,
	[bankCode] [varchar](50) NULL,
	[agentCode] [varchar](50) NULL,
	[userName] [varchar](50) NULL,
	[pwd] [varchar](50) NULL,
	[accountNo] [varchar](100) NULL,
	[accountName] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[isActive] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
