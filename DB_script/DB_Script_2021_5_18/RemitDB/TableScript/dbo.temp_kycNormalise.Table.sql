USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[temp_kycNormalise]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_kycNormalise](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[institute] [varchar](100) NULL,
	[address] [varchar](150) NULL,
	[designation] [varchar](50) NULL,
	[anualIncome] [money] NULL,
	[accountType] [varchar](50) NULL,
	[remarks] [varchar](150) NULL,
	[userName] [varchar](30) NULL,
	[sessionId] [varchar](60) NULL,
	[valueType] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
