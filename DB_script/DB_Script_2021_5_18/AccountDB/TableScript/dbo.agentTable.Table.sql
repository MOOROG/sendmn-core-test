USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[agentTable]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentTable](
	[agent_id] [int] IDENTITY(1001,1) NOT FOR REPLICATION NOT NULL,
	[agent_name] [varchar](200) NULL,
	[agent_short_name] [varchar](50) NULL,
	[agent_address] [varchar](500) NULL,
	[agent_address2] [varchar](500) NULL,
	[agent_email] [varchar](100) NULL,
	[agent_city] [varchar](100) NULL,
	[agent_phone] [varchar](50) NULL,
	[agent_fax] [varchar](20) NULL,
	[agent_contact_person] [varchar](50) NULL,
	[agent_create_date] [varchar](50) NULL,
	[agent_create_by] [varchar](20) NULL,
	[agent_modify_by] [varchar](50) NULL,
	[agent_modify_date] [datetime] NULL,
	[agent_status] [varchar](1) NULL,
	[map_code] [varchar](50) NULL,
	[map_code2] [varchar](50) NULL,
	[TDS_PCNT] [money] NULL,
	[AGENT_TYPE] [varchar](50) NULL,
	[AGENT_IME_CODE] [varchar](50) NULL,
	[AGENTZONE] [varchar](25) NULL,
	[AGENTDISTRICT] [varchar](25) NULL,
	[AGENT_CONTACTPERSON_MOBILE] [varchar](50) NULL,
	[PANNUMBER] [varchar](50) NULL,
	[REGNUMBER] [varchar](50) NULL,
	[BANKCODE] [varchar](100) NULL,
	[BANKBRANCH] [varchar](100) NULL,
	[BANKACCOUNTNUMBER] [varchar](50) NULL,
	[CONSTITUTION] [varchar](150) NULL,
	[RECEIVING_CURRANCY] [varchar](50) NULL,
	[AGENT_REGION] [varchar](200) NULL,
	[tid] [varchar](200) NULL,
	[central_sett] [varchar](1) NULL,
	[central_sett_code] [varchar](20) NULL,
	[IsMainAgent] [varchar](1) NULL,
	[todaysSend] [money] NULL,
	[todaysPaid] [money] NULL,
	[todaysCancel] [money] NULL,
	[AcDepositBank] [varchar](20) NULL,
	[todaysEP] [money] NULL,
	[todaysPO] [money] NULL,
	[commissionDeduction] [money] NULL,
	[ACCOUNTHOLDERNAME] [varchar](100) NULL,
	[agent_country] [varchar](50) NULL,
 CONSTRAINT [PK_agentdetail] PRIMARY KEY CLUSTERED 
(
	[agent_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_agentTable] UNIQUE NONCLUSTERED 
(
	[agent_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
