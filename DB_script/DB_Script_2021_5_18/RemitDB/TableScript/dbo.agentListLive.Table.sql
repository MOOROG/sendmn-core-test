USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentListLive]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentListLive](
	[agent_id] [float] NULL,
	[agent_name] [nvarchar](255) NULL,
	[agent_short_name] [nvarchar](255) NULL,
	[agent_address] [float] NULL,
	[agent_address2] [nvarchar](255) NULL,
	[agent_email] [nvarchar](255) NULL,
	[agent_city] [nvarchar](255) NULL,
	[agent_phone] [nvarchar](255) NULL,
	[agent_fax] [nvarchar](255) NULL,
	[agent_contact_person] [nvarchar](255) NULL,
	[agent_create_date] [nvarchar](255) NULL,
	[agent_create_by] [nvarchar](255) NULL,
	[agent_modify_by] [nvarchar](255) NULL,
	[agent_modify_date] [datetime] NULL,
	[agent_status] [nvarchar](255) NULL,
	[map_code] [float] NULL,
	[map_code2] [float] NULL,
	[TDS_PCNT] [float] NULL,
	[AGENT_TYPE] [nvarchar](255) NULL,
	[AGENT_IME_CODE] [float] NULL,
	[AGENTZONE] [nvarchar](255) NULL,
	[AGENTDISTRICT] [nvarchar](255) NULL,
	[AGENT_CONTACTPERSON_MOBILE] [nvarchar](255) NULL,
	[PANNUMBER] [float] NULL,
	[REGNUMBER] [nvarchar](255) NULL,
	[BANKCODE] [nvarchar](255) NULL,
	[BANKBRANCH] [nvarchar](255) NULL,
	[BANKACCOUNTNUMBER] [nvarchar](255) NULL,
	[CONSTITUTION] [nvarchar](255) NULL,
	[RECEIVING_CURRANCY] [nvarchar](255) NULL,
	[AGENT_REGION] [nvarchar](255) NULL,
	[tid] [nvarchar](255) NULL
) ON [PRIMARY]
GO
