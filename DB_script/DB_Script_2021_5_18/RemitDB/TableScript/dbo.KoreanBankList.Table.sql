USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KoreanBankList]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KoreanBankList](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[BankName] [varchar](100) NOT NULL,
	[BankNameUnicode] [nvarchar](100) NULL,
	[bankCode] [nvarchar](30) NULL,
	[IsActive] [bit] NULL,
	[AGENTID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
