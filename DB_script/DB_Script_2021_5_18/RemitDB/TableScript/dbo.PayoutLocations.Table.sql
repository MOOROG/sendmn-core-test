USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[PayoutLocations]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayoutLocations](
	[Id] [int] IDENTITY(1001,1) NOT NULL,
	[agentCode] [varchar](50) NULL,
	[Branch] [varchar](100) NULL,
	[agentAddress] [varchar](200) NULL,
	[agentDistrict] [varchar](100) NULL,
	[agentState] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[Contact] [varchar](50) NULL,
	[agentMobile2] [varchar](50) NULL,
	[agentPhone1] [varchar](50) NULL,
	[agentPhone2] [varchar](50) NULL,
 CONSTRAINT [PK_PayoutLocations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
