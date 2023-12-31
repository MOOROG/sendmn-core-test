USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[DUMP_COMPILE_REPORT]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DUMP_COMPILE_REPORT](
	[Bank_ID] [varchar](20) NULL,
	[Branch_Code] [varchar](20) NULL,
	[agent_name] [varchar](200) NULL,
	[BANKCODE] [varchar](50) NOT NULL,
	[BANKBRANCH] [varchar](50) NOT NULL,
	[BANKACCOUNTNUMBER] [varchar](50) NOT NULL,
	[DR] [money] NOT NULL,
	[CR] [money] NOT NULL,
	[reportJobId] [int] NULL
) ON [PRIMARY]
GO
