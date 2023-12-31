USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[temp_voucher_edit]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_voucher_edit](
	[tran_id] [int] IDENTITY(1,1) NOT NULL,
	[acc_num] [varchar](25) NULL,
	[agent_id] [int] NULL,
	[branch_id] [int] NULL,
	[del_flg] [char](1) NULL,
	[entry_user_id] [varchar](20) NULL,
	[gl_sub_head_code] [varchar](10) NULL,
	[module_id] [varchar](5) NULL,
	[part_tran_srl_num] [varchar](4) NULL,
	[part_tran_type] [varchar](2) NULL,
	[ref_num] [varchar](20) NULL,
	[rpt_code] [varchar](25) NULL,
	[tran_amt] [money] NULL,
	[fl_currency] [varchar](5) NULL,
	[flc_rate] [decimal](18, 6) NULL,
	[usd_amt] [money] NULL,
	[usd_rate] [decimal](18, 6) NULL,
	[tran_date] [datetime] NULL,
	[tran_particular] [varchar](500) NULL,
	[tran_rmks] [varchar](200) NULL,
	[vfd_date] [datetime] NULL,
	[vfd_user_id] [varchar](15) NULL,
	[billdate] [datetime] NULL,
	[billno] [varchar](50) NULL,
	[party] [int] NULL,
	[otherinfo] [varchar](52) NULL,
	[tran_type] [varchar](20) NULL,
	[created_date] [datetime] NULL,
	[company_id] [int] NULL,
	[sessionID] [varchar](50) NULL,
	[RunningBalance] [money] NULL
) ON [PRIMARY]
GO
