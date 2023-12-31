USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[moneyGramMod]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[moneyGramMod](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agent] [varchar](50) NULL,
	[controlNo] [varchar](50) NULL,
	[recFullName] [varchar](200) NULL,
	[sendFullName] [varchar](200) NULL,
	[recContactNo] [varchar](200) NULL,
	[amount] [money] NULL,
	[tranDate] [datetime] NULL,
	[location] [int] NULL,
	[address] [varchar](max) NULL,
	[sessionId] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[modType] [varchar](1) NULL,
 CONSTRAINT [PK_moneyGramMod] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
