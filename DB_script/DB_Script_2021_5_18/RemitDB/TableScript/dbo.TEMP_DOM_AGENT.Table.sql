USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_DOM_AGENT]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_DOM_AGENT](
	[agentCode] [int] IDENTITY(1,2) NOT NULL,
	[ContactName1] [varchar](50) NULL,
	[Post1] [varchar](50) NULL,
	[email1] [varchar](50) NULL,
	[ContactName2] [varchar](50) NULL,
	[Post2] [varchar](50) NULL,
	[email2] [varchar](50) NULL,
	[CompanyName] [varchar](100) NOT NULL,
	[LicNo] [varchar](50) NULL,
	[AgentType] [varchar](50) NULL,
	[Address] [varchar](100) NULL,
	[City] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Phone1] [varchar](50) NULL,
	[Phone2] [varchar](50) NULL,
	[Fax] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[CurrentBalance] [money] NULL,
	[CurrencyType] [varchar](50) NULL,
	[DateOfJoin] [datetime] NULL,
	[AgentCan] [varchar](50) NOT NULL,
	[accessed] [varchar](50) NOT NULL,
	[remarks] [varchar](255) NULL,
	[sending_commission] [float] NULL,
	[receiving_commission] [float] NULL,
	[cType] [varchar](50) NULL,
	[limit] [money] NULL,
	[limitPerTran] [money] NULL,
	[GMT_Value] [int] NULL,
	[district_code] [int] NOT NULL,
	[BranchCodeChar] [varchar](50) NOT NULL,
	[rCType] [varchar](50) NULL,
	[CurrentCommission] [money] NULL,
	[start_working_hour] [int] NULL,
	[end_working_hour] [int] NULL,
	[view_report_only] [varchar](3) NULL,
	[ext_limit] [money] NULL,
	[last_trnsDate] [datetime] NULL,
	[today_sentAmt] [money] NULL,
	[mobile_no] [varchar](20) NULL,
	[comm_account] [char](1) NULL,
	[disable_payment] [char](1) NULL,
	[disable_send] [char](1) NULL,
	[bank_id] [int] NULL
) ON [PRIMARY]
GO
