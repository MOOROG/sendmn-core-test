USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[AgentBankMapping]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AgentBankMapping](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[superAgentId] [varchar](50) NULL,
	[bankpartnerId] [varchar](50) NULL,
	[bankpartnerName] [varchar](150) NULL,
	[bankId] [varchar](50) NULL,
	[bankName] [varchar](150) NULL,
	[bankCountryName] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [varchar](50) NULL,
	[isActive] [char](1) NULL,
	[isDelete] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
