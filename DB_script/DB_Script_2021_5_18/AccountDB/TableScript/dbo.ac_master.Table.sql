USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[ac_master]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ac_master](
	[acct_id] [int] IDENTITY(100000,1) NOT NULL,
	[acct_num] [varchar](20) NOT NULL,
	[acct_name] [varchar](500) NULL,
	[gl_code] [varchar](10) NULL,
	[agent_id] [int] NULL,
	[branch_id] [int] NULL,
	[acct_ownership] [varchar](50) NULL,
	[dr_bal_lim] [money] NULL,
	[lim_expiry] [datetime] NULL,
	[acct_rpt_code] [varchar](50) NULL,
	[acct_type_code] [varchar](50) NULL,
	[frez_ref_code] [varchar](20) NULL,
	[frez_remarks] [varchar](200) NULL,
	[acct_opn_date] [datetime] NULL,
	[acct_cls_flg] [varchar](20) NULL,
	[acct_cls_date] [datetime] NULL,
	[clr_bal_amt] [money] NULL,
	[system_reserved_amt] [money] NULL,
	[system_reserver_remarks] [varchar](200) NULL,
	[lien_amt] [money] NULL,
	[lien_remarks] [varchar](500) NULL,
	[utilised_amt] [money] NULL,
	[available_amt] [money] NULL,
	[ac_currency] [varchar](500) NULL,
	[usd_amt] [money] NULL,
	[flc] [varchar](500) NULL,
	[flc_amt] [money] NULL,
	[ac_group] [varchar](50) NULL,
	[ac_sub_group] [varchar](50) NULL,
	[created_by] [varchar](50) NULL,
	[created_date] [datetime] NULL,
	[modified_by] [varchar](200) NULL,
	[modified_date] [datetime] NULL,
	[company_id] [int] NULL,
	[bill_by_bill] [varchar](50) NULL
) ON [PRIMARY]
GO
